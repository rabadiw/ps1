
function Deploy-JitTree {

    param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

    $NuGetApiKeyPath = "..\.psgkey"

    $distPath = Get-PSBuildDistPath
    $verNext = Get-SemVer -Filter jit-tree -ExcludePrefix
    Set-PSModuleVersion -Path $distPath -Version $verNext -Verbose:$Verbose

    if (-Not($WhatIf)) {
        Publish-Module -Path $distPath -NuGetApiKey (get-content $NuGetApiKeyPath) -Verbose
    }
}

function Set-JitTree {

    param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

    $logPath = join-path $PSScriptRoot -ChildPath CHANGELOG.md
    $verNext = Get-SemVerNext -Version (Get-SemVer -Filter jit-tree)
    $summary = Get-SemVerChangeSummary -Version $verNext -ChangeLogPath $logPath | Select-Object -ExpandProperty Content

    Set-SemVer `
        -Message $summary `
        -Version $verNext `
        -Verbose:$Verbose `
        -WhatIf:$WhatIf
}
