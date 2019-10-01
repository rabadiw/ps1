
function Deploy-JitSemVer {

    $NuGetApiKeyPath = "..\.psgkey"

    ($srcPath, $distPath) = Build-PSModule
    Set-PSModuleVersion -Path $distPath

    Publish-Module -Path $distPath -NuGetApiKey (get-content $NuGetApiKeyPath) -Verbose
}
