# Pester tests for SPSFbaSync.ps1
# Resolve repo root - works on CI/CD (GitHub Actions) and local runs

BeforeAll {
    $repoRoot = Split-Path -Path $PSScriptRoot -Parent
    $script:scriptPath = Join-Path -Path $repoRoot -ChildPath 'src/SPSFbaSync.ps1'
    $script:scriptContent = Get-Content -Path $script:scriptPath -Raw -ErrorAction SilentlyContinue
    $script:configExample = Join-Path -Path $repoRoot -ChildPath 'src/Config/CONTOSO-PROD.example.psd1'
}

Describe 'SPSFbaSync.ps1 File Existence' {

    It 'SPSFbaSync.ps1 exists' {
        $script:scriptPath | Should -Exist
    }

    It 'is a PowerShell script file' {
        (Get-Item $script:scriptPath).Extension | Should -Be '.ps1'
    }

    It 'has valid PowerShell syntax' {
        $parseErrors = $null
        $tokens = $null
        $null = [System.Management.Automation.Language.Parser]::ParseInput(
            $script:scriptContent, [ref]$tokens, [ref]$parseErrors)
        $parseErrors | Should -BeNullOrEmpty
    }
}

Describe 'SPSFbaSync.ps1 Metadata' {

    It 'Should contain a SYNOPSIS' {
        $script:scriptContent | Should -Match '\.SYNOPSIS'
    }

    It 'Should contain a DESCRIPTION' {
        $script:scriptContent | Should -Match '\.DESCRIPTION'
    }

    It 'Should contain an EXAMPLE' {
        $script:scriptContent | Should -Match '\.EXAMPLE'
    }

    It 'Should declare an Author in NOTES' {
        $script:scriptContent | Should -Match 'Author:\s*luigilink'
    }

    It 'Should source its Version from the SPSFbaSync.Common manifest' {
        $script:scriptContent | Should -Match 'Version:\s*Defined by the SPSFbaSync\.Common module manifest'
    }

    It 'Should require PowerShell 5.1 or higher' {
        $script:scriptContent | Should -Match '#requires\s+-Version\s+5\.1'
    }

    It 'Should read its version from Get-Module at runtime' {
        $script:scriptContent | Should -Match "Get-Module -Name 'SPSFbaSync\.Common'"
    }

    It 'Should import the SPSFbaSync.Common manifest' {
        $script:scriptContent | Should -Match 'SPSFbaSync\.Common\\SPSFbaSync\.Common\.psd1'
    }

    It 'Should load config via Import-PowerShellDataFile' {
        $script:scriptContent | Should -Match 'Import-PowerShellDataFile'
    }

    It 'Should not carry over the SPSUpdate "cumulative update" wording' {
        $script:scriptContent | Should -Not -Match 'cumulative update'
    }
}

Describe 'SPSFbaSync.ps1 Parameters' {

    BeforeAll {
        $ast = [System.Management.Automation.Language.Parser]::ParseInput(
            $script:scriptContent, [ref]$null, [ref]$null)
        $script:paramBlock = $ast.ParamBlock
    }

    It 'Should define a param block' {
        $script:paramBlock | Should -Not -BeNullOrEmpty
    }

    It 'Should expose a mandatory ConfigFile parameter' {
        $configParam = $script:paramBlock.Parameters | Where-Object {
            $_.Name.VariablePath.UserPath -eq 'ConfigFile'
        }
        $configParam | Should -Not -BeNullOrEmpty

        $paramAttr = $configParam.Attributes | Where-Object {
            $_ -is [System.Management.Automation.Language.AttributeAst] -and
            $_.TypeName.Name -eq 'Parameter'
        }
        $mandatoryArg = $paramAttr.NamedArguments |
            Where-Object { $_.ArgumentName -eq 'Mandatory' }
        $mandatoryArg | Should -Not -BeNullOrEmpty
    }

    It 'ConfigFile should validate a .psd1 path' {
        $script:scriptContent | Should -Match "\`$_ -like '\*\.psd1'"
    }

    It 'Should expose an Action parameter limited to Install/Uninstall/Default' {
        $actionParam = $script:paramBlock.Parameters | Where-Object {
            $_.Name.VariablePath.UserPath -eq 'Action'
        }
        $actionParam | Should -Not -BeNullOrEmpty
        $script:scriptContent | Should -Match "validateSet\('Install', 'Uninstall', 'Default'"
    }

    It 'Should expose an InstallAccount parameter' {
        $installParam = $script:paramBlock.Parameters | Where-Object {
            $_.Name.VariablePath.UserPath -eq 'InstallAccount'
        }
        $installParam | Should -Not -BeNullOrEmpty
    }

    It 'Should expose a LogRetentionDays parameter' {
        $logParam = $script:paramBlock.Parameters | Where-Object {
            $_.Name.VariablePath.UserPath -eq 'LogRetentionDays'
        }
        $logParam | Should -Not -BeNullOrEmpty
    }

    It 'Should expose a HistoryRetentionDays parameter' {
        $histParam = $script:paramBlock.Parameters | Where-Object {
            $_.Name.VariablePath.UserPath -eq 'HistoryRetentionDays'
        }
        $histParam | Should -Not -BeNullOrEmpty
    }
}

Describe 'SPSFbaSync.ps1 report wiring' {

    It 'archives the previous results with Backup-SPSJsonFile' {
        $script:scriptContent | Should -Match 'Backup-SPSJsonFile'
    }

    It 'renders the report with Export-SPSFbaSyncReport' {
        $script:scriptContent | Should -Match 'Export-SPSFbaSyncReport'
    }

    It 'prunes result-history snapshots with Clear-SPSLogFolder' {
        $script:scriptContent | Should -Match "Clear-SPSLogFolder -Path \`$pathHistoryFolder"
    }

    It 'writes the results JSON under a stable (non-timestamped) name' {
        $script:scriptContent | Should -Match "\`$resultsBaseName = "
    }
}

Describe 'SPSFbaSync.ps1 behaviour wiring' {

    It 'derives the scheduled task script path from $PSCommandPath (no undefined $fullScriptPath)' {
        $script:scriptContent | Should -Match '\$fullScriptPath\s*=\s*\$PSCommandPath'
    }

    It 'uses the renamed Set-SPSUserProfileProperty helper' {
        $script:scriptContent | Should -Match 'Set-SPSUserProfileProperty'
    }

    It 'no longer references the mistyped Set-USPUserProfileProperty' {
        $script:scriptContent | Should -Not -Match 'Set-USPUserProfileProperty'
    }

    It 'prunes old transcript logs with Clear-SPSLogFolder' {
        $script:scriptContent | Should -Match "Clear-SPSLogFolder -Path \`$pathLogsFolder"
    }
}

Describe 'SPSFbaSync example configuration' {

    It 'example config file exists' {
        $script:configExample | Should -Exist
    }

    It 'is a valid PowerShell data file' {
        { Import-PowerShellDataFile -Path $script:configExample } | Should -Not -Throw
    }

    It 'declares the required top-level keys' {
        $cfg = Import-PowerShellDataFile -Path $script:configExample
        foreach ($key in @(
                'ConfigurationName', 'ApplicationName', 'WebApplicationUrl',
                'SqlConnectionString', 'SqlMembershipProviderName', 'SqlQuery',
                'CreateIfMissing', 'UpdateUserInfoList', 'IncludeLockedOut', 'IncludeNotApproved')) {
            $cfg.ContainsKey($key) | Should -BeTrue
        }
    }

    It 'exposes the boolean toggles as actual booleans' {
        $cfg = Import-PowerShellDataFile -Path $script:configExample
        foreach ($key in @('CreateIfMissing', 'UpdateUserInfoList', 'IncludeLockedOut', 'IncludeNotApproved')) {
            $cfg[$key] | Should -BeOfType [System.Boolean]
        }
    }
}
