. $PSScriptRoot\MessageFunctions.ps1

function Get-PSBuildSrcPath {
    Get-ChildItem . -Directory -Filter src | Select-Object -First 1
}

function Get-PSBuildDistPath {
    $srcPath = Get-PSBuildSrcPath
    if ($srcPath -and (Test-Path $srcPath)) {
        $moduleName = (Get-ChildItem $srcPath -Filter *.psd1 | Select-Object -First 1).BaseName
        Join-Path -Path (Split-Path -Parent $srcPath) -ChildPath "dist/$moduleName"
    }
}

function Build-PSModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][ValidateNotNull()][scriptblock]$SrcPathScript = { Get-PSBuildSrcPath },
        [Parameter(Mandatory = $false)][ValidateNotNull()][scriptblock]$DistPathScript = { Get-PSBuildDistPath }
    )
    $srcPath = Invoke-Command -ScriptBlock $SrcPathScript
    $distPath = Invoke-Command -ScriptBlock $DistPathScript

    if (-Not($srcPath) -or -Not(Test-Path $srcPath)) {
        Write-Information -MessageData (Format-ErrorMessage "Source path not found '$srcPath'.") -InformationAction Continue
        break
    }
    if (-Not($distPath)) {
        Write-Information -MessageData (Format-ErrorMessage "Destination path is not valid.") -InformationAction Continue
        break
    }
    if (Test-Path $distPath) {
        # clear dist content
        Remove-Item $distPath -Force -Recurse
        Write-Verbose "Removed $distPath."
    }

    Copy-Item $srcPath $distPath -Recurse -InformationAction Continue
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
        [ValidateNotNullOrEmpty()]
        [string]
        $Path = (Get-PSBuildDistPath),
        # Version to set for the module.
        [Parameter(Mandatory = $false)][string]$Version = (Get-SemVer -ExcludePrefix)
    )
    if (-Not(Test-Path $Path)) {
        Write-Error "PSModule path not found $Path." -ErrorAction Stop
    }

    $psd1 = Get-ChildItem $Path -Filter *.psd1 | Select-Object -First 1
    if (-Not(Test-Path $psd1)) {
        Write-Error "No PSD1 file found within $Path." -ErrorAction Stop
    }
    # Ensure PSD1 is setup correctly
    ($ver, $pre) = $Version -split '-'

    # update version and clear Prerelease value
    Update-ModuleManifest -Path $psd1 -ModuleVersion $ver -Prerelease " "

    # set Prerelease value, if any
    if (Test-String $pre) {
        $prever = $pre -replace "\.", ""
        Update-ModuleManifest -Path $psd1 -Prerelease $prever
        Write-Verbose "Updated Prereelease to '${prever}' for '${psd1}'."
    }
}

$exportModuleMemberParams = @{
    Function = @(
        'Build-PSModule',
        'Set-PSModuleVersion',
        'Get-PSBuildDistPath',
        'Get-PSBuildSrcPath'
    )
    Variable = @()
}

Export-ModuleMember @exportModuleMemberParams
