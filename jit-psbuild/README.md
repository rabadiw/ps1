# JIT-PSBuild
A PowerShell productivity module to help manage building and managing the distribution version using the `JIT-SemVer` PowerShell Module.

## How to setup a delpoy script 
Here's an example looking at the deploy of JIT-PSBuild.

```powershell
function Deploy-JitPSBuild {

    # path to NuGetAPI Key
    $NuGetApiKeyPath = "..\.psgkey"

    # ... from the jit-psbuild module
    $distPath = (Build-PSModule).DistPath
    # .. from the jit-psbuild module
    Set-PSModuleVersion -Path $distPath

    # ... from the PowerShell team
    Publish-Module -Path $distPath -NuGetApiKey (get-content $NuGetApiKeyPath) -Verbose
}

function Set-JitPSBuildVer {

    param(
        [switch]$WhatIf = $false, 
        [switch]$Force = $false, 
        [switch]$Verbose = $false)

    $semverprefix = "jit-psbuild"
    # .. from the jit-semver module
    $semver = Get-SemVerNext -Version (Get-SemVer -Filter $semverprefix) -Prefix "$semverprefix/v"

    # .. from the jit-semver module
    Set-SemVer `
        -Version $semver `
        -Message (Get-SemVerChangeSummary -Version $semver | Select-Object -ExpandProperty Content) `
        -Verbose:$Verbose `
        -WhatIf:$WhatIf
}
```

To sync the tagged version with Github, use the following command `PS> git push origin (Get-SemVer)`. You can also add the command to your deploy script.