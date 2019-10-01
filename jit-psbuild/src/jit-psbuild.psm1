function Get-DefaultSrcPath {
    Join-Path (Split-Path -Parent $PSScriptRoot) -ChildPath "src"
}

function Get-DefaultPSDistPath {
    $srcPath = Get-DefaultSrcPath
    $moduleName = ( Get-ChildItem $srcPath -Filter *.psd1 | Select-Object -First 1).BaseName
    Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "dist/$moduleName"
}

function Build-PSModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$srcPath = (Get-DefaultSrcPath),
        [Parameter(Mandatory = $false)][string]$distPath = (Get-DefaultPSDistPath)
    )
    if (-Not(Test-Path $srcPath)) {
        Write-Error "Source path not found '$srcPath'." -ErrorAction Stop
    }
    if (Test-Path $distPath) {
        Remove-Item $distPath -Force -Recurse
        Write-Information "Removed $distPath." -InformationAction Continue
    }

    Copy-Item $srcPath $distPath -Recurse

    @{
        SourcePath = $srcPath;
        BuildPath  = $distPath
    }
}

function Set-PSModuleVersion {
    [CmdletBinding()]
    param (
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $false,
            Position = 0,
            ParameterSetName = "PSModule",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to PSModule.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path = (Get-DefaultPSDistPath)
    )
    if (-Not(Test-Path $Path)) {
        Write-Error "PSModule path not found $Path." -ErrorAction Stop
    }

    $psd1 = Get-ChildItem $Path -Filter *.psd1 | Select-Object -First 1
    if (-Not(Test-Path $psd1)) {
        Write-Error "No PSD1 file found within $Path." -ErrorAction Stop
    }
    # Ensure PSD1 is setup correctly
    ($ver, $pre) = (Get-SemVer) -split '-'

    # update version and clear Prerelease value
    Update-ModuleManifest -Path $psd1 -ModuleVersion $ver -Prerelease " "

    # set Prerelease value, if any
    if (Test-String $pre) {
        $prever = $pre -replace "\.", ""
        Update-ModuleManifest -Path $psd1 -Prerelease $prever
        Write-Information "Updated Prereelease to '${prever}' for '${psd1}'."
    }
}

$exportModuleMemberParams = @{
    Function = @(
        'Get-DefaultSrcPath',
        'Get-DefaultPSDistPath',
        'Build-PSModule',
        'Set-PSModuleVersion'
    )
    Variable = @()
}

Export-ModuleMember @exportModuleMemberParams
