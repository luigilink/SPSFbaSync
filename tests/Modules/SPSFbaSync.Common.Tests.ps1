# Pester tests for the SPSFbaSync.Common module.
# Resolve repo root - works on both local and CI/CD.

BeforeAll {
    $repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $script:moduleRoot = Join-Path -Path $repoRoot -ChildPath 'src/Modules/SPSFbaSync.Common'
    $script:moduleManifest = Join-Path -Path $script:moduleRoot -ChildPath 'SPSFbaSync.Common.psd1'
    $script:moduleFile = Join-Path -Path $script:moduleRoot -ChildPath 'SPSFbaSync.Common.psm1'
    $script:moduleName = 'SPSFbaSync.Common'

    # Stub SharePoint cmdlets so the module can be imported on non-Windows / no-SharePoint
    # hosts. Real behaviour is exercised on a SharePoint farm; these tests only validate
    # shape & contracts.
    $spsStubs = @(
        'Get-SPServer', 'Get-SPFarm', 'Get-SPSite', 'Set-SPUser',
        'Add-PSSnapin', 'Get-PSSnapin'
    )
    foreach ($name in $spsStubs) {
        if (-not (Get-Command -Name $name -ErrorAction SilentlyContinue)) {
            $sb = [ScriptBlock]::Create("function global:$name { param() }")
            & $sb
        }
    }

    # The module is import-safe by design (the admin/powercfg/snap-in prelude lives in the
    # entry script, not the module). Surface real import errors instead of hiding them.
    Import-Module -Name $script:moduleManifest -Force -DisableNameChecking
}

AfterAll {
    Remove-Module -Name 'SPSFbaSync.Common' -Force -ErrorAction SilentlyContinue
}

Describe 'SPSFbaSync.Common Module' {

    It 'module manifest exists' {
        $script:moduleManifest | Should -Exist
    }

    It 'loader module file exists' {
        $script:moduleFile | Should -Exist
    }

    It 'loader has valid PowerShell syntax' {
        $parseErrors = $null
        $tokens = $null
        $null = [System.Management.Automation.Language.Parser]::ParseInput(
            (Get-Content -Path $script:moduleFile -Raw), [ref]$tokens, [ref]$parseErrors)
        $parseErrors | Should -BeNullOrEmpty
    }

    It 'manifest declares a ModuleVersion' {
        (Test-ModuleManifest -Path $script:moduleManifest).Version | Should -Not -BeNullOrEmpty
    }

    It 'manifest ModuleVersion is 2.0.0 or higher' {
        (Test-ModuleManifest -Path $script:moduleManifest).Version | Should -BeGreaterOrEqual ([version]'2.0.0')
    }

    It 'module loads successfully' {
        Get-Module -Name $script:moduleName | Should -Not -BeNullOrEmpty
    }
}

Describe 'SPSFbaSync.Common Public Functions' {

    $publicFunctions = @(
        'Add-SPSScheduledTask',
        'Clear-SPSLogFolder',
        'Get-SPSInstalledProductVersion',
        'Remove-SPSScheduledTask',
        'Set-SPSUserProfileProperty'
    )

    It 'exports <_>' -ForEach $publicFunctions {
        Get-Command -Name $_ -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    It 'manifest FunctionsToExport matches the exported set' {
        $expectedExports = @(
            'Add-SPSScheduledTask',
            'Clear-SPSLogFolder',
            'Get-SPSInstalledProductVersion',
            'Remove-SPSScheduledTask',
            'Set-SPSUserProfileProperty'
        ) | Sort-Object
        $exported = (Get-Module -Name $script:moduleName).ExportedFunctions.Keys | Sort-Object
        $exported | Should -Be $expectedExports
    }
}

Describe 'Clear-SPSLogFolder' {

    BeforeEach {
        $script:tempRoot = Join-Path -Path $TestDrive -ChildPath ([guid]::NewGuid().ToString('N'))
        $null = New-Item -Path $script:tempRoot -ItemType Directory -Force
    }

    It 'does nothing when Retention is 0' {
        $old = Join-Path -Path $script:tempRoot -ChildPath 'old.log'
        Set-Content -Path $old -Value 'x'
        (Get-Item $old).LastWriteTime = (Get-Date).AddDays(-400)
        Clear-SPSLogFolder -Path $script:tempRoot -Retention 0 -Extension '*.log'
        $old | Should -Exist
    }

    It 'returns silently when the path does not exist' {
        $missing = Join-Path -Path $script:tempRoot -ChildPath 'nope'
        { Clear-SPSLogFolder -Path $missing -Retention 30 } | Should -Not -Throw
    }

    It 'deletes files older than the retention window' {
        $old = Join-Path -Path $script:tempRoot -ChildPath 'old.log'
        $new = Join-Path -Path $script:tempRoot -ChildPath 'new.log'
        Set-Content -Path $old -Value 'x'
        Set-Content -Path $new -Value 'x'
        (Get-Item $old).LastWriteTime = (Get-Date).AddDays(-200)
        Clear-SPSLogFolder -Path $script:tempRoot -Retention 180 -Extension '*.log'
        $old | Should -Not -Exist
        $new | Should -Exist
    }

    It 'only targets files matching the extension filter' {
        $log = Join-Path -Path $script:tempRoot -ChildPath 'old.log'
        $json = Join-Path -Path $script:tempRoot -ChildPath 'old.json'
        Set-Content -Path $log -Value 'x'
        Set-Content -Path $json -Value 'x'
        (Get-Item $log).LastWriteTime = (Get-Date).AddDays(-200)
        (Get-Item $json).LastWriteTime = (Get-Date).AddDays(-200)
        Clear-SPSLogFolder -Path $script:tempRoot -Retention 180 -Extension '*.log'
        $log | Should -Not -Exist
        $json | Should -Exist
    }
}
