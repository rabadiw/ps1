
function Deploy-JitPSBuild {

    param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)
    
    $NuGetApiKeyPath = "..\.psgkey"
    $semverprefix = "jit-psbuild"

    # hashtable to array, not needed but good to know
    # ($distPath, $srcPath) = [string[]]((Build-PSModule).Values | Out-String -Stream)
    $distPath = (Build-PSModule).DistPath
    Set-PSModuleVersion -Version (Get-SemVer -Filter $semverprefix -ExcludePrefix) -Path $distPath -Verbose:$Verbose

    if (-Not($WhatIf)) {
        Publish-Module -Path $distPath -NuGetApiKey (get-content $NuGetApiKeyPath) -Verbose
    }
}

function Set-JitPSBuildVer {

    param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

    $semverprefix = "jit-psbuild"
    $semver = Get-SemVerNext -Version (Get-SemVer -Filter $semverprefix) -Prefix "$semverprefix/v"
    $msg = Get-SemVerChangeSummary -ChangeLogPath ./CHANGELOG.md -Version $semver | Select-Object -ExpandProperty Content

    Set-SemVer `
        -Version $semver `
        -Message $msg `
        -Verbose:$Verbose `
        -WhatIf:$WhatIf
}
