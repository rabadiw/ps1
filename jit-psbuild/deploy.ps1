
function Deploy-JitPSBuild {

    $NuGetApiKeyPath = "..\.psgkey"

    # hashtable to array, not needed but good to know
    # ($distPath, $srcPath) = [string[]]((Build-PSModule).Values | Out-String -Stream)
    $distPath = (Build-PSModule).DistPath
    Set-PSModuleVersion -Path $distPath

    Publish-Module -Path $distPath -NuGetApiKey (get-content $NuGetApiKeyPath) -Verbose
}
