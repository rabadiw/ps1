
function Deploy-JitSemVer {

    param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

    $NuGetApiKeyPath = "..\.psgkey"

    $distPath = (Build-PSModule -Verbose:$Verbose -WhatIf:$WhatIf).DistPath
    Set-PSModuleVersion -Path $distPath -Verbose:$Verbose -WhatIf:$WhatIf

    if (Not($WhatIf)) {
        Publish-Module -Path $distPath -NuGetApiKey (get-content $NuGetApiKeyPath) -Verbose
    }
}


function Set-JitSemVer {

    param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

    Set-SemVer `
        -Message (Get-SemVerChangeSummary | Select-Object -ExpandProperty Content) `
        -Verbose:$Verbose `
        -WhatIf:$WhatIf
}
