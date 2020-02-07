
function Deploy-JitTree {

    param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

    $NuGetApiKeyPath = "..\.psgkey"
    $semverprefix = "jit-tree"

    $distPath = Get-PSBuildDistPath
    Build-PSModule
    Set-PSModuleVersion -Version (Get-SemVer -Filter $semverprefix -ExcludePrefix) -Path $distPath -Verbose:$Verbose

    if (-Not($WhatIf)) {
        Publish-Module -Path $distPath -NuGetApiKey (get-content $NuGetApiKeyPath) -Verbose
    }
}

function Set-JitTreeTag {

    param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

    $semverprefix = "jit-tree"
    $logPath = join-path $PSScriptRoot -ChildPath CHANGELOG.md
    $semver = Get-SemVerNext -Version (Get-SemVer -Filter $semverprefix) -Prefix "$semverprefix/v"
    $msg = Get-SemVerChangeSummary -ChangeLogPath $logPath -Version $semver | Select-Object -ExpandProperty Content

    Set-SemVer `
        -Version $semver `
        -Message $msg `
        -Verbose:$Verbose `
        -WhatIf:$WhatIf
}
