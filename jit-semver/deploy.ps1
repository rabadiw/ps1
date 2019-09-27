function Invoke-Build {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$srcPath = (Join-Path -Path $PSScriptRoot -ChildPath "src"),
        [Parameter(Mandatory = $false)][string]$distPath = (Join-Path -Path $PSScriptRoot -ChildPath "dist\jit-semver")
    )    
    if (Test-Path $distPath) {
        Remove-Item $distPath -Force
        Write-Information "Removed $distPath." -InformationAction Continue
    }
    Copy-Item $srcPath $distPath -Recurse
}

function Set-DistVersion{
    # TODO - add special handling for powershell psd1
}

function Invoke-PushModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = "Publish", HelpMessage = "Path to module.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $distPath = (Join-Path -Path $PSScriptRoot -ChildPath "dist\jit-semver"),
        
        [Parameter(Mandatory = $false, ParameterSetName = "Publish", HelpMessage = "Path to NuGetApiKey.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $NuGetApiKeyPath = "..\.psgkey"
    )    

    if (-Not(Test-Path $NuGetApiKeyPath)) {
        Write-Error "NuGetApiKey Path not found $NuGetApiKeyPath"
        return 
    }
    Publish-Module -Path $distPath -NuGetApiKey (get-content $NuGetApiKeyPath) -Verbose
}
