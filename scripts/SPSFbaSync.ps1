<#
  .SYNOPSIS
    Syncs user info (email/name properties) from a SQL Membership Provider (FBA) database
    to SharePoint 2016 User Profile Service, and optionally to the User Information List (SPUser).

  .DESCRIPTION
    - Reads from dbo.vw_aspnet_MembershipUsers to get UserName and Email.
    - Builds the FBA claim (i:0#.f|<membershipProvider>|<userName>).
    - Updates UPS properties (WorkEmail, PreferredName, FirstName, LastName).
    - Optionally updates the User Information List (SPUser) via Set-SPUser.

  .PARAMETER ConfigFile
  Need parameter ConfigFile, example:
  PS D:\> E:\SCRIPT\SPSFbaSync.ps1 -ConfigFile 'contoso-PROD.json'

  .PARAMETER Action
  Use the Action parameter equal to Install if you want to add the SPSFbaSync script in taskscheduler
  InstallAccount parameter need to be set
  PS D:\> E:\SCRIPT\SPSFbaSync.ps1 -Action Install -InstallAccount (Get-Credential)

  Use the Action parameter equal to Uninstall if you want to remove the SPSFbaSync script from taskscheduler
  PS D:\> E:\SCRIPT\SPSFbaSync.ps1 -Action Uninstall

  .PARAMETER InstallAccount
  Need parameter InstallAccount when you use the Action Install parameter
  PS D:\> E:\SCRIPT\SPSFbaSync.ps1 -Install -InstallAccount (Get-Credential) -ConfigFile 'contoso-PROD.json'
  The account must have the following rights:
    - Local Admin on the server where the script will be executed
    - Farm Admin and Full control on User Profile Service Application
    - SQL Reader on the Membership database

  .EXAMPLE
  SPSFbaSync.ps1 -Action Install -InstallAccount (Get-Credential) -ConfigFile 'contoso-PROD.json'
  SPSFbaSync.ps1 -Action Uninstall -ConfigFile 'contoso-PROD.json'
  SPSFbaSync.ps1 -ConfigFile 'contoso-PROD.json'

  .NOTES
  FileName:	SPSFbaSync.ps1
  Author:		Jean-Cyril DROUHIN
  Date:		September 03, 2025
  Version:	1.0.0

  .LINK
  https://spjc.fr/
  https://github.com/luigilink/SPSFbaSync
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
  [Parameter(Position = 0, Mandatory = $true)]
  [ValidateScript({ (Test-Path $_) -and ($_ -like '*.json') })]
  [System.String]
  $ConfigFile, # Path to the JSON config file

  [Parameter(Position = 1)]
  [validateSet('Install', 'Uninstall', 'Default', IgnoreCase = $true)]
  [System.String]
  $Action = 'Default', # Install, Uninstall or Default (run the sync)

  [Parameter(Position = 2)]
  [System.Management.Automation.PSCredential]
  $InstallAccount # Credential for the InstallAccount (when Action is Install)
)

#region Initialization
# Clear the host console
Clear-Host

# Set the window title
$Host.UI.RawUI.WindowTitle = "SPSFbaSync script running on $env:COMPUTERNAME"

# Define the path to the helper module
$script:HelperModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'modules'

# Import the helper module
try {
  Import-Module -Name (Join-Path -Path $script:HelperModulePath -ChildPath 'util.psm1') -Force
}
catch {
  # Handle errors during Import of helper module
  Write-Error -Message @"
Failed to import helper module from path: $($script:HelperModulePath)
Exception: $_
"@
  Exit
}

# Ensure the script is running with administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  Throw "Administrator rights are required. Please re-run this script as an Administrator."
}

# Load the configuration file
try {
  if (Test-Path $ConfigFile) {
    $jsonEnvCfg = Get-Content $ConfigFile | ConvertFrom-Json
    $Application = $jsonEnvCfg.ApplicationName
    $Environment = $jsonEnvCfg.ConfigurationName
    $SiteUrl = $jsonEnvCfg.SiteUrl
    $SqlConnectionString = $jsonEnvCfg.SqlConnectionString
    $MembershipProviderName = $jsonEnvCfg.MembershipProviderName
    $SqlQuery = $jsonEnvCfg.SqlQuery
    $CreateIfMissing = $jsonEnvCfg.CreateIfMissing
    $UpdateSiteUserInfo = $jsonEnvCfg.UpdateSiteUserInfo
    $IncludeLockedOut = $jsonEnvCfg.IncludeLockedOut
    $IncludeNotApproved = $jsonEnvCfg.IncludeNotApproved
  }
  else {
    Throw "Configuration file '$ConfigFile' not found."
  }
}
catch {
  Write-Error "Failed to load configuration file: $_"
  Exit
}

# Define variables
$SPSFbaSyncVersion = '1.0.0'
$getDateFormatted = Get-Date -Format yyyy-MM-dd_H-mm
$spsFbaSyncFileName = "$($Application)-$($Environment)_$($getDateFormatted)"
$currentUser = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name
$pathLogsFolder = Join-Path -Path $PSScriptRoot -ChildPath 'Logs'
$pathResultFolder = Join-Path -Path $PSScriptRoot -ChildPath 'Results'

# Initialize logs and results folders
if (-Not (Test-Path -Path $pathLogsFolder)) {
  New-Item -ItemType Directory -Path $pathLogsFolder -Force
}
if (-Not (Test-Path -Path $pathResultFolder)) {
  New-Item -ItemType Directory -Path $pathResultFolder -Force
}

# Define log and result file paths
$pathLogFile = Join-Path -Path $pathLogsFolder -ChildPath ($spsFbaSyncFileName + '.log')
$resultFile = Join-Path -Path $pathResultFolder -ChildPath ($spsFbaSyncFileName + '.csv')
$DateStarted = Get-Date
$psVersion = $PSVersionTable.PSVersion.ToString()

# Start transcript to log the output
Start-Transcript -Path $pathLogFile -IncludeInvocationHeader
$VerbosePreference = 'Continue'

# Output the script information
Write-Output '-----------------------------------------------'
Write-Output "| SPSFbaSync Script - v$SPSFbaSyncVersion"
Write-Output "| Started on - $DateStarted by $currentUser"
Write-Output "| PowerShell Version - $psVersion"
Write-Output '-----------------------------------------------'
#endregion

#region Main Process

# 0. Set power management plan to "High Performance"
Write-Verbose -Message "Setting power management plan to 'High Performance'..."
Start-Process -FilePath "$env:SystemRoot\system32\powercfg.exe" -ArgumentList '/s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' -NoNewWindow

# 1. Handle Action parameter (Install, Uninstall, Default)
switch ($Action) {
  'Uninstall' {
    # Remove scheduled Task for Update Full Script
    try {
      Write-Output 'Removing Scheduled Task SPSFbaSync in SharePoint Task Path'
      Remove-SPSScheduledTask -Name 'SPSFbaSync'
    }
    catch {
      # Handle errors during Remove scheduled Task for Update Full Script
      Write-Error -Message @"
Failed to Remove Scheduled Task SPSFbaSync in SharePoint Task Path
Exception: $_
"@
    }
  }
  'Install' {
    # Check UserName and Password if Install parameter is used
    if (-not($PSBoundParameters.ContainsKey('InstallAccount'))) {
      Write-Warning -Message ('SPSFbaSync: Install parameter is set. Please set also InstallAccount ' + `
          "parameter. `nSee https://github.com/luigilink/SPSFbaSync/wiki for details.")
      Stop-Transcript
      exit
    }
    else {
      $UserName = $InstallAccount.UserName
      $Password = $InstallAccount.GetNetworkCredential().Password
      $currentDomain = 'LDAP://' + ([ADSI]'').distinguishedName
      Write-Output "Checking Account `"$UserName`" ..."
      $dom = New-Object System.DirectoryServices.DirectoryEntry($currentDomain, $UserName, $Password)
      if ($null -eq $dom.Path) {
        Write-Warning -Message "Password Invalid for user:`"$UserName`""
        Stop-Transcript
        exit
      }
      else {
        # Add scheduled Task for Update Full Script
        try {
          # Initialize ActionArguments parameter
          $ActionArguments = "-ExecutionPolicy Bypass -File `"$($fullScriptPath)`" -ConfigFile `"$($ConfigFile)`" -Verbose"
          Write-Output 'Adding Scheduled Task SPSFbaSync in SharePoint Task Path'
          Add-SPSScheduledTask -Name 'SPSFbaSync' `
            -Description 'Scheduled Task for Update SharePoint Server after installation of cumulative update' `
            -ActionArguments $ActionArguments `
            -ExecuteAsCredential $InstallAccount
        }
        catch {
          # Handle errors during Add scheduled Task for Update Full Script
          Write-Error -Message @"
Failed to Add Scheduled Task SPSFbaSync in SharePoint Task Path
Exception: $_
"@
          Stop-Transcript
          exit
        }
      }
    }
  }
  Default {
    # Validate critical parameters
    if ([string]::IsNullOrWhiteSpace($SiteUrl)) {
      Write-Error -Message "SiteUrl is not defined in the configuration file."
      Stop-Transcript
      Exit
    }
    if ([string]::IsNullOrWhiteSpace($SqlConnectionString)) {
      Write-Error -Message "SqlConnectionString is not defined in the configuration file."
      Stop-Transcript
      Exit
    }
    if ([string]::IsNullOrWhiteSpace($MembershipProviderName)) {
      Write-Error -Message "MembershipProviderName is not defined in the configuration file."
      Stop-Transcript
      Exit
    }
    # 1. Load SharePoint Powershell Snapin or Import-Module
    try {
      $installedVersion = Get-SPSInstalledProductVersion
      Write-Output "Installed SharePoint Product Version: $($installedVersion)"
      if ($installedVersion.ProductMajorPart -eq 15 -or $installedVersion.ProductBuildPart -le 12999) {
        if ($null -eq (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue)) {
          Write-Verbose -Message "Loading SharePoint PowerShell snap-in..."
          Add-PSSnapin Microsoft.SharePoint.PowerShell
        }
      }
      else {
        Write-Verbose -Message "Importing SharePointServer Module..."
        Import-Module SharePointServer -Verbose:$false -WarningAction SilentlyContinue
      }
    }
    catch {
      # Handle errors during retrieval of Installed Product Version
      Write-Error -Message @"
Failed to load SharePoint snapin/module for $($env:COMPUTERNAME)
Exception: $_
"@
      Stop-Transcript
      Exit
    }

    # 2. Add-Type for SharePoint Client assemblies
    try {
      Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
      Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
      Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
    }
    catch {
      Write-Error -Message @"
Failed to load SharePoint/Server assemblies on $($env:COMPUTERNAME)
Exception: $($_.Exception.Message)
"@
      Stop-Transcript
      Exit
    }

    # 3 Build default SQL if none provided
    if ([string]::IsNullOrWhiteSpace($SqlQuery)) {
      $where = @()

      if (-not $IncludeNotApproved) { $where += "IsApproved = 1" }
      if (-not $IncludeLockedOut) { $where += "IsLockedOut = 0" }

      $whereClause = ""
      if ($where.Count -gt 0) {
        $whereClause = "WHERE " + ($where -join " AND ")
      }

      $SqlQuery = @"
SELECT  UserName,
        Email
FROM    dbo.vw_aspnet_MembershipUsers
$whereClause
"@
    }
    Write-Verbose -Message @"
Using this SQL query for SPSFbaSync:
$SqlQuery
"@

    # 4 Query membership database
    Write-Verbose -Message "Connecting to SQL and executing query with connection string: $SqlConnectionString"
    $dt = New-Object System.Data.DataTable
    $conn = New-Object System.Data.SqlClient.SqlConnection $SqlConnectionString
    try {
      $cmd = $conn.CreateCommand()
      $cmd.CommandText = $SqlQuery
      $conn.Open()
      $da = New-Object System.Data.SqlClient.SqlDataAdapter $cmd
      [void]$da.Fill($dt)
    }
    catch {
      Write-Error -Message @"
Failed to connect to SQL instance
SQL Connection String: $SqlConnectionString
Exception: $($_.Exception.Message)
"@
      Stop-Transcript
      Exit
    }
    finally {
      if ($conn.State -ne 'Closed') { $conn.Close() }
      $conn.Dispose()
    }
    if ($dt.Rows.Count -eq 0) {
      Write-Warning "No rows returned from SQL. Check your query/filters. Script will exit."
      Stop-Transcript
      Exit
    }

    # 5. Get SharePoint Site collecion and User Profile Manager context
    Write-Verbose -Message "Connecting to SharePoint site: $SiteUrl"
    try {
      $site = Get-SPSite $SiteUrl -ErrorAction SilentlyContinue
      if ($null -eq $site) {
        Write-Warning "Site collection not found at URL: $SiteUrl. Please check the SiteUrl parameter in the configuration file."
        Stop-Transcript
        Exit
      }
      else {
        $context = [Microsoft.Office.Server.ServerContext]::GetContext($site)
        $upm = New-Object Microsoft.Office.Server.UserProfiles.UserProfileManager($context)
      }
    }
    catch {
      Write-Error -Message @"
Failed accessing SharePoint site or User Profile Service Application at URL: $SiteUrl
Exception: $($_.Exception.Message)
"@
      Stop-Transcript
      Exit
    }
    $log = New-Object System.Collections.Generic.List[psobject]

    function Set-IfChanged {
      param(
        [Microsoft.Office.Server.UserProfiles.UserProfile]$Profile,
        [string]$PropertyInternalName,
        [string]$NewValue
      )
      $current = [string]$Profile[$PropertyInternalName].Value
      if ([string]::IsNullOrWhiteSpace($NewValue)) { return $false }
      if ($current -ne $NewValue) {
        $Profile[$PropertyInternalName].Value = $NewValue
        return $true
      }
      return $false
    }

    try {
      foreach ($row in $dt.Rows) {
        $userName = [string]$row.UserName
        $email = [string]$row.Email
        $first = if ($dt.Columns.Contains("FirstName")) { [string]$row.FirstName }  else { $null }
        $last = if ($dt.Columns.Contains("LastName")) { [string]$row.LastName }   else { $null }
        $display = if ($dt.Columns.Contains("DisplayName") -and $row.DisplayName) { [string]$row.DisplayName } else { $userName }

        # FBA claim format: i:0#.f|<membershipProvider>|<userName>
        $login = "i:0#.f|$MembershipProviderName|$userName"

        $status = "Skipped"
        $notes = ""

        try {
          $profile = $null
          if ($upm.UserExists($login)) {
            $profile = $upm.GetUserProfile($login)
          }
          elseif ($CreateIfMissing) {
            if ($PSCmdlet.ShouldProcess($login, "Create UPS profile")) {
              $profile = $upm.CreateUserProfile($login)
            }
          }
          else {
            $status = "MissingProfile"
            $notes = "UPS profile not found; use -CreateIfMissing to auto-provision."
          }

          if ($profile -ne $null) {
            $changed = $false
            $changed = (Set-IfChanged -Profile $profile -PropertyInternalName "WorkEmail"     -NewValue $email) -or $changed
            $changed = (Set-IfChanged -Profile $profile -PropertyInternalName "FirstName"     -NewValue $first) -or $changed
            $changed = (Set-IfChanged -Profile $profile -PropertyInternalName "LastName"      -NewValue $last) -or $changed
            $changed = (Set-IfChanged -Profile $profile -PropertyInternalName "PreferredName" -NewValue $display) -or $changed

            if ($changed) {
              if ($PSCmdlet.ShouldProcess($login, "Commit UPS changes")) {
                $profile.Commit()
                $status = "Updated"
              }
            }
            else {
              $status = "NoChange"
            }

            if ($UpdateSiteUserInfo -and $email) {
              $web = $site.RootWeb
              try {
                $spUser = $web.EnsureUser($login)
                if ($spUser -and ($spUser.Email -ne $email -or $spUser.Name -ne $display)) {
                  if ($PSCmdlet.ShouldProcess($login, "Update SPUser (UIL)")) {
                    Set-SPUser -Identity $login -Web $web.Url -Email $email -DisplayName $display -ErrorAction Stop | Out-Null
                  }
                }
              }
              catch {
                $status = "UpdatedWithUILWarning"
                $notes = "UPS ok; UIL update failed: $($_.Exception.Message)"
              }
              finally {
                if ($web) { $web.Dispose() }
              }
            }
          }
        }
        catch {
          $status = "Error"
          $notes = $_.Exception.Message
        }
        finally {
          $log.Add([pscustomobject]@{
              Login     = $login
              UserName  = $userName
              Email     = $email
              FirstName = $first
              LastName  = $last
              Display   = $display
              Status    = $status
              Notes     = $notes
            })
        }
      }
    }
    finally {
      if ($site) { $site.Dispose() }
    }

    $log | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $resultFile
    Write-Host "Completed. Result written to: $resultFile"
  }
}
#endregion

# Clean-Up
$DateEnded = Get-Date
Write-Output '-----------------------------------------------'
Write-Output "| SPSFbaSync Script Completed"
Write-Output "| Started on  - $DateStarted"
Write-Output "| Ended on    - $DateEnded"
Write-Output '-----------------------------------------------'
Stop-Transcript
$error.Clear()
Exit
