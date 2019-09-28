function Set-JitSemVerVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$srcPath = (Join-Path -Path $PSScriptRoot -ChildPath "src"),
        [Parameter(Mandatory = $false)][string]$distPath = (Join-Path -Path $PSScriptRoot -ChildPath "dist\jit-semver")
    )    
    if (-not(Test-Path $distPath)) {
        Write-Error "DistPath not found $distPath." -ErrorAction Stop
    }

    $psd1 = Get-ChildItem $distPath -Filter *.psd1 | Select-Object -First 1
    ($ver, $pre) = (Get-SemVer) -split '-'

    if (Test-String $pre) {
        $prever = $pre -replace "\.", ""
        Write-Information "Updating PreRelease to ${prever} for ${psd1}."
        Update-ModuleManifest -Path $psd1 -Prerelease $prever
    }
    
    Update-ModuleManifest -Path $psd1 -ModuleVersion $ver
}

function Build-JitSemVer {
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

function Publish-JitSemVer {
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
        Write-Error "NuGetApiKey Path not found $NuGetApiKeyPath" -ErrorAction Stop
    }

    Publish-Module -Path $distPath -NuGetApiKey (get-content $NuGetApiKeyPath) -Verbose
}

function Deploy-JitSemVer {
    
    Build-JitSemVer
    Set-JitSemVerVersion
    Publish-JitSemVer

}