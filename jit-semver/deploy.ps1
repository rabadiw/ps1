
function Deploy-JitSemVer {

    param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

    $NuGetApiKeyPath = "..\.psgkey"

    $distPath = (Build-PSModule).DistPath
    Set-PSModuleVersion -Path $distPath -Verbose:$Verbose

    if (-Not($WhatIf)) {
        Publish-Module -Path $distPath -NuGetApiKey (get-content $NuGetApiKeyPath) -Verbose
    }
}

function Set-JitSemVer {

    param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

    Set-SemVer `
        -Message (Get-SemVerChangeSummary -Version (Get-SemVerNext) | Select-Object -ExpandProperty Content) `
        -Verbose:$Verbose `
        -WhatIf:$WhatIf
}
