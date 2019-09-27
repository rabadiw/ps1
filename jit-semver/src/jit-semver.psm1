. $PSScriptRoot\TestFunctions.ps1

function ConvertTo-SemVer {
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)][string]$SemVersion = (git describe --tags)
    )
    [regex]$rx = "(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)-?(?<pre>[a-zA-Z]+)?\.?(?<prepatch>\d+)?\+?(?<build>\d+)?"
    $curver = $rx.Match($SemVersion)

    @{
        Major    = [int]$curver.Groups["major"].Value
        Minor    = [int]$curver.Groups["minor"].Value
        Patch    = [int]$curver.Groups["patch"].Value
        Pre      = [string]$curver.Groups["pre"].Value
        PrePatch = [int]$curver.Groups["prepatch"].Value
        Build    = [int]$curver.Groups["build"].Value
    }
}

function Format-SemVerString {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][hashtable]$SemVersion
    )

    $prevalue = if ($SemVersion.pre -ne "") { "-$($SemVersion.pre)" }
    $prepatchvalue = if ($SemVersion.prepatch -ne "") { ".$($SemVersion.prepatch)" }
    $buildvalue = if ($SemVersion.build -ne "") { "+$($SemVersion.build)" }
    "$($SemVersion.major).$($SemVersion.minor).$($SemVersion.patch)${prevalue}${prepatchvalue}${buildvalue}"
}

function Get-SemVerOverride {
    Get-Content ./.semver.yml |
        ForEach-Object { , ($_ -split ':') } |
        ForEach-Object { @{ $_[0] = $_[1].Trim() } }
}

function Get-SemVer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][switch]$IncludePrefix,
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$Prefix = "v"
    )
    $SemVersion = $null
    # TBD value
    #   if (Test-SemVerOverride) {
    #     $SemVersion = (Get-SemVerOverride).Version | ConvertTo-SemVer
    #   }

    if ((Test-SemVer -ShowMessage)) {
        # value of (git describe --tags)
        $SemVersion = ConvertTo-SemVer
    }
    else {
        # default
        Write-Warning "Defaulting to 1.0.0-alpha."
        $SemVersion = ConvertTo-SemVer -semver "1.0.0-alpha"
    }

    $ver = $SemVersion | Format-SemVerString
    if ($IncludePrefix) {
        $ver = "${Prefix}${ver}"
    }
    $ver
}

function Set-SemVer {
    [cmdletbinding(SupportsShouldProcess = $true)]

    param(
        [Parameter(Mandatory = $false)][ValidateSet("major", "minor", "patch", "build")][string]$SemVerb = $null,
        [Parameter(Mandatory = $false)][string]$SemVersion = (Get-SemVer),
        [Parameter(Mandatory = $false)][string]$Message = "",
        [Parameter(Mandatory = $false)][string]$Prefix = "",
        [Parameter(Mandatory = $false)][switch]$Force = $false
    )

    ($major, $minor, $patch, $pre, $prepatch, $build) = ConvertTo-SemVer -SemVersion $SemVersion | ForEach-Object { ($_.Major, $_.Minor, $_.Patch, $_.Pre, $_.PrePatch, $_.Build) }
    switch ($SemVerb) {
        "major" {
            if (Test-String $pre) {
                switch ($pre.ToLower()) {
                    "alpha" {
                        $pre = "beta"
                        $prepatch = $build = ""
                    }
                    "beta" {
                        $pre = "rc"
                        $prepatch = $build = ""
                    }
                    Default {
                        $pre = $prepatch = $build = ""
                    }
                }
            }
            else {
                $major++
                $minor = $patch = 0
                $build = ""
            }
        }
        "minor" {
            if (Test-String $pre) {
                $prepatch++
            }
            else {
                $minor++
                $patch = 0
            }
        }
        "build" {
            if (Test-String $build) {
                $build++
            }
        }
        Default {
            if (Test-String $pre) {
                # skip if initial set
                if (Test-SemVer) {
                    $prepatch++
                }
                else {
                    $prepatch = ""
                }
                $build = ""
            }
            else {
                $patch++
                $build = ""
            }
        }
    }

    # new semver
    $nextsemver = @{
        Major    = $major
        Minor    = $minor
        Patch    = $patch
        Pre      = $pre
        PrePatch = $prepatch
        Build    = $build
    } | Format-SemVerString


    $setcmdPattern = "git tag '{1}v{0}'{2}"
    $msgString = ""
    if (Test-String $Message) {
        $msgString = " -m '${Message}'"
    }
    $setcmd = [scriptblock]::Create($setcmdPattern -f ($nextsemver, $Prefix, $msgString))

    if ($PSCmdlet.ShouldProcess($SemVersion, "Set-SemVer")) {
        # Ensure no outstanding git commits
        if ($Force -or (Test-GitState)) {
            Invoke-Command -ScriptBlock $setcmd
            Write-Information "Success! Version updated to $($setcmdPattern -f ($nextsemver, $Prefix, ''))."
        }
    }
    else {
        Write-Output "What if: $setcmd"
    }
}

$exportModuleMemberParams = @{
    Function = @(
        'Get-SemVer',
        'Set-SemVer',
        'ConvertTo-Semver',
        'Format-SemVerString',
        'Test-String'
    )
    Variable = @()
}

Export-ModuleMember @exportModuleMemberParams
