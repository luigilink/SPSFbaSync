# Pester tests for the SPSFbaSync HTML sync report (Export-SPSFbaSyncReport).

BeforeAll {
    $repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $script:moduleManifest = Join-Path -Path $repoRoot -ChildPath 'src/Modules/SPSFbaSync.Common/SPSFbaSync.Common.psd1'
    Import-Module -Name $script:moduleManifest -Force -DisableNameChecking

    $script:sampleRows = @(
        [pscustomobject]@{ Login = 'i:0#.f|fba|alice'; UserName = 'alice'; Email = 'alice@contoso.com'; Status = 'Updated'; Notes = '' }
        [pscustomobject]@{ Login = 'i:0#.f|fba|bob'; UserName = 'bob'; Email = 'bob@contoso.com'; Status = 'NoChange'; Notes = '' }
        [pscustomobject]@{ Login = 'i:0#.f|fba|carol'; UserName = 'carol'; Email = 'carol@contoso.com'; Status = 'Error'; Notes = 'boom & <bad>' }
    )
}

AfterAll {
    Remove-Module -Name 'SPSFbaSync.Common' -Force -ErrorAction SilentlyContinue
}

Describe 'Export-SPSFbaSyncReport' {

    BeforeEach {
        $script:out = Join-Path -Path $TestDrive -ChildPath ("report-{0}.html" -f ([guid]::NewGuid().ToString('N')))
    }

    It 'writes an HTML file and returns its path' {
        $p = Export-SPSFbaSyncReport -Result $script:sampleRows -OutputPath $script:out -Application 'contoso' -Environment 'PROD' -Version '2.1.0'
        $p | Should -Be $script:out
        $script:out | Should -Exist
    }

    It 'is a self-contained document (no external CSS/JS/CDN)' {
        Export-SPSFbaSyncReport -Result $script:sampleRows -OutputPath $script:out | Out-Null
        $html = Get-Content -Path $script:out -Raw
        $html | Should -Match '<!DOCTYPE html>'
        $html | Should -Not -Match 'http[s]?://[^"]*\.(css|js)'
        $html | Should -Not -Match '<link '
    }

    It 'renders the interactive table with the expected id' {
        Export-SPSFbaSyncReport -Result $script:sampleRows -OutputPath $script:out | Out-Null
        (Get-Content -Path $script:out -Raw) | Should -Match 'id="sps-report"'
    }

    It 'HTML-encodes dangerous values (no injection)' {
        Export-SPSFbaSyncReport -Result $script:sampleRows -OutputPath $script:out | Out-Null
        $html = Get-Content -Path $script:out -Raw
        $html | Should -Match 'boom &amp; &lt;bad&gt;'
        $html | Should -Not -Match 'boom & <bad>'
    }

    It 'reflects the metadata passed in' {
        Export-SPSFbaSyncReport -Result $script:sampleRows -OutputPath $script:out -Application 'contoso' -Environment 'PROD' -Version '2.1.0' | Out-Null
        $html = Get-Content -Path $script:out -Raw
        $html | Should -Match 'contoso'
        $html | Should -Match 'PROD'
        $html | Should -Match '2\.1\.0'
    }

    It 'handles an empty result set gracefully' {
        Export-SPSFbaSyncReport -Result @() -OutputPath $script:out | Out-Null
        (Get-Content -Path $script:out -Raw) | Should -Match 'No users were processed'
    }

    It 'supports reading from a results JSON file (InputFile)' {
        $json = Join-Path -Path $TestDrive -ChildPath ("result-{0}.json" -f ([guid]::NewGuid().ToString('N')))
        [pscustomobject]@{ UserProfileInformation = $script:sampleRows } | ConvertTo-Json | Set-Content -Path $json
        $p = Export-SPSFbaSyncReport -InputFile $json -OutputPath $script:out
        $script:out | Should -Exist
        (Get-Content -Path $script:out -Raw) | Should -Match 'alice@contoso.com'
    }

    It 'throws when the InputFile does not exist' {
        $missing = Join-Path -Path $TestDrive -ChildPath 'nope.json'
        { Export-SPSFbaSyncReport -InputFile $missing -OutputPath $script:out } | Should -Throw
    }
}

Describe 'Backup-SPSJsonFile' {

    BeforeEach {
        $script:tempRoot = Join-Path -Path $TestDrive -ChildPath ([guid]::NewGuid().ToString('N'))
        $null = New-Item -Path $script:tempRoot -ItemType Directory -Force
        $script:history = Join-Path -Path $script:tempRoot -ChildPath 'history'
    }

    It 'returns $null when there is nothing to archive' {
        $missing = Join-Path -Path $script:tempRoot -ChildPath 'CONTOSO-PROD.json'
        Backup-SPSJsonFile -Path $missing -HistoryFolder $script:history | Should -BeNullOrEmpty
    }

    It 'copies the existing file into the history folder with a timestamp' {
        $src = Join-Path -Path $script:tempRoot -ChildPath 'CONTOSO-PROD.json'
        Set-Content -Path $src -Value '{}'
        $backup = Backup-SPSJsonFile -Path $src -HistoryFolder $script:history -TimeStamp '20260710-1200'
        $backup | Should -Exist
        (Split-Path -Path $backup -Leaf) | Should -Be 'CONTOSO-PROD-20260710-1200.json'
        $src | Should -Exist
    }
}
