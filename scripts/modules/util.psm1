function Get-SPSInstalledProductVersion {
    [OutputType([System.Version])]
    param ()

    $pathToSearch = 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\*\ISAPI\Microsoft.SharePoint.dll'
    $fullPath = Get-Item $pathToSearch -ErrorAction SilentlyContinue | Sort-Object { $_.Directory } -Descending | Select-Object -First 1
    if ($null -eq $fullPath) {
        Write-Error -Message 'SharePoint path {C:\Program Files\Common Files\microsoft shared\Web Server Extensions} does not exist'
    }
    else {
        return ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($fullPath.FullName)).FileVersion
    }
}

function Add-SPSScheduledTask {
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ExecuteAsCredential, # Credentials for Task Schedule

        [Parameter(Mandatory = $true)]
        [System.String]
        $ActionArguments, # Arguments for the task action

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name, # Name of the scheduled task to be added

        [Parameter()]
        [System.String]
        $Description, # Description of the scheduled task to be added

        [Parameter()]
        [System.String]
        $TaskPath = 'SharePoint' # Path of the task folder
    )

    # Initialize variables
    $TaskCmd = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' # Path to PowerShell executable
    $UserName = $ExecuteAsCredential.UserName
    $Password = $ExecuteAsCredential.GetNetworkCredential().Password

    # Connect to the local TaskScheduler Service
    $TaskSvc = New-Object -ComObject ('Schedule.service')
    $TaskSvc.Connect($env:COMPUTERNAME)

    # Check if the folder exists, if not, create it
    try {
        $TaskFolder = $TaskSvc.GetFolder($TaskPath) # Attempt to get the task folder
    }
    catch {
        Write-Output "Task folder '$TaskPath' does not exist. Creating folder..."
        $RootFolder = $TaskSvc.GetFolder('\') # Get the root folder
        $RootFolder.CreateFolder($TaskPath) # Create the missing task folder
        $TaskFolder = $TaskSvc.GetFolder($TaskPath) # Get the newly created folder
        Write-Output "Successfully created task folder '$TaskPath'"
    }

    # Retrieve the scheduled task
    $getScheduledTask = $TaskFolder.GetTasks(0) | Where-Object -FilterScript {
        $_.Name -eq $Name
    }

    if ($getScheduledTask) {
        Write-Warning -Message 'Scheduled Task already exists - skipping.' # Task already exists
    }
    else {
        Write-Output '--------------------------------------------------------------'
        Write-Output "Adding '$Name' script in Task Scheduler Service ..."

        # Get credentials for Task Schedule
        $TaskAuthor = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name # Author of the task
        $TaskUser = $UserName # Username for task registration
        $TaskUserPwd = $Password # Password for task registration

        # Add a new Task Schedule
        $TaskSchd = $TaskSvc.NewTask(0)
        $TaskSchd.RegistrationInfo.Description = "$($Description)" # Task description
        $TaskSchd.RegistrationInfo.Author = $TaskAuthor # Task author
        $TaskSchd.Principal.RunLevel = 1 # Task run level (1 = Highest)

        # Task Schedule - Modify Settings Section
        $TaskSettings = $TaskSchd.Settings
        $TaskSettings.AllowDemandStart = $true
        $TaskSettings.Enabled = $true
        $TaskSettings.Hidden = $false
        $TaskSettings.StartWhenAvailable = $true

        # Define the task action
        $TaskAction = $TaskSchd.Actions.Create(0) # 0 = Executable action
        $TaskAction.Path = $TaskCmd # Path to the executable
        $TaskAction.Arguments = $ActionArguments # Arguments for the executable

        try {
            # Register the task
            $TaskFolder.RegisterTaskDefinition($Name, $TaskSchd, 6, $TaskUser, $TaskUserPwd, 1)
            Write-Output "Successfully added '$Name' script in Task Scheduler Service"
        }
        catch {
            $catchMessage = @"
An error occurred while adding the script in scheduled task: $($Name)
ActionArguments: $($ActionArguments)
Exception: $($_.Exception.Message)
"@
            Write-Error -Message $catchMessage # Handle any errors during task registration
        }
    }
}

function Remove-SPSScheduledTask {
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name, # Name of the scheduled task to be removed

        [Parameter()]
        [System.String]
        $TaskPath = 'SharePoint' # Path of the task folder
    )

    # Connect to the local TaskScheduler Service
    $TaskSvc = New-Object -ComObject ('Schedule.service')
    $TaskSvc.Connect($env:COMPUTERNAME)

    # Check if the folder exists
    try {
        $TaskFolder = $TaskSvc.GetFolder($TaskPath) # Attempt to get the task folder
    }
    catch {
        Write-Output "Task folder '$TaskPath' does not exist."
    }

    # Retrieve the scheduled task
    $getScheduledTask = $TaskFolder.GetTasks(0) | Where-Object -FilterScript {
        $_.Name -eq $Name
    }

    if ($null -eq $getScheduledTask) {
        Write-Warning -Message 'Scheduled Task already removed - skipping.' # Task not found
    }
    else {
        Write-Output '--------------------------------------------------------------'
        Write-Output "Removing $($Name) script in Task Scheduler Service ..."
        try {
            $TaskFolder.DeleteTask($Name, $null) # Remove the task
            Write-Output "Successfully removed $($Name) script from Task Scheduler Service"
        }
        catch {
            $catchMessage = @"
An error occurred while removing the script in scheduled task: $($Name)
Exception: $($_.Exception.Message)
"@
            Write-Error -Message $catchMessage # Handle any errors during task removal
        }
    }
}

function Set-USPUserProfileProperty {
    param(
        [Parameter(Mandatory = $true)]
        [Microsoft.Office.Server.UserProfiles.UserProfile]
        $UserProfile,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PropertyInternalName,

        [Parameter()]
        [System.String]
        $DesiredValue
    )
    try {
        $currentValue = [string]$UserProfile[$PropertyInternalName].Value
        if ([string]::IsNullOrWhiteSpace($DesiredValue)) { return $false }
        if ($currentValue -ne $DesiredValue) {
            $UserProfile[$PropertyInternalName].Value = $DesiredValue
            return $true
        }
        return $false
    }
    catch {
        $catchMessage = @"
An error occurred while setting the UserProfile Property.
PropertyInternalName: $($PropertyInternalName)
CurrentValue: $($currentValue)
DesiredValue: $($DesiredValue)
Exception: $($_.Exception.Message)
"@
        Write-Error -Message $catchMessage # Handle any errors during task removal
    }
}
