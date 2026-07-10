function Add-SPSScheduledTask {
    <#
        .SYNOPSIS
        Registers the SPSFbaSync script as a Windows scheduled task.

        .DESCRIPTION
        Creates (if needed) the target Task Scheduler folder and registers a task that
        runs PowerShell with the supplied arguments under the provided credential. If a
        task with the same name already exists, it is left untouched.

        .PARAMETER ExecuteAsCredential
        Credential the task runs as.

        .PARAMETER ActionArguments
        Command-line arguments passed to powershell.exe.

        .PARAMETER Name
        Name of the scheduled task.

        .PARAMETER Description
        Optional task description.

        .PARAMETER TaskPath
        Task Scheduler folder. Defaults to 'SharePoint'.

        .EXAMPLE
        Add-SPSScheduledTask -Name 'SPSFbaSync' -ActionArguments $args -ExecuteAsCredential (Get-Credential)
    #>
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
