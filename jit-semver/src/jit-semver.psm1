. $PSScriptRoot\TestFunctions.ps1

function ConvertTo-SemVer {
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)][string]$Version = (git describe --tags)
    )
    [regex]$rx = "(?<prefix>.+)?(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)-?(?<pre>[a-zA-Z]+)?\.?(?<prepatch>\d+)?\+?(?<build>\d+)?"
    $curver = $rx.Match($Version)

    @{
        Major    = [int]$curver.Groups["major"].Value
        Minor    = [int]$curver.Groups["minor"].Value
        Patch    = [int]$curver.Groups["patch"].Value
        Pre      = [string]$curver.Groups["pre"].Value
        PrePatch = [int]$curver.Groups["prepatch"].Value
        Build    = [int]$curver.Groups["build"].Value
        Prefix   = [string]$curver.Groups["prefix"].Value
    }
}

function Format-SemVerString {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][hashtable]$Version,
        [Parameter(Mandatory = $false)][switch]$IncludePrefix
    )

    $prevalue = if ($Version.pre -ne "") { "-$($Version.pre)" }
    $prepatchvalue = if ($Version.prepatch -ne "") { ".$($Version.prepatch)" }
    $buildvalue = if ($Version.build -ne "") { "+$($Version.build)" }
    if (-Not($IncludePrefix)) {
        $Version.Prefix = ""
    }
    "$($Version.Prefix)$($Version.major).$($Version.minor).$($Version.patch)${prevalue}${prepatchvalue}${buildvalue}"
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
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$Prefix
    )
    $Version = $null
    # TBD value
    #   if (Test-SemVerOverride) {
    #     $Version = (Get-SemVerOverride).Version | ConvertTo-SemVer
    #   }

    if ((Test-SemVer -ShowMessage)) {
        # value of (git describe --tags)
        $Version = ConvertTo-SemVer
    }
    else {
        # default
        Write-Warning "Defaulting to 1.0.0-alpha."
        $Version = ConvertTo-SemVer -Version "1.0.0-alpha"
    }

    if ($IncludePrefix) {
        if (Test-String $Prefix) {
            $Version.Prefix = $Prefix
        }
    }

    $Version | Format-SemVerString -IncludePrefix:$IncludePrefix
}

function Set-SemVer {
    [cmdletbinding(SupportsShouldProcess = $true)]

    param(
        [Parameter(Mandatory = $false)][ValidateSet("major", "minor", "patch", "build")][string]$SemVerb = $null,
        [Parameter(Mandatory = $false)][string]$Version = (Get-SemVer -IncludePrefix),
        [Parameter(Mandatory = $false)][string]$Message = "",
        [Parameter(Mandatory = $false)][string]$Prefix = "",
        [Parameter(Mandatory = $false)][switch]$Force = $false
    )

    ($major, $minor, $patch, $pre, $prepatch, $build, $verPrefix) = ConvertTo-SemVer -Version $Version |
        ForEach-Object { ($_.Major, $_.Minor, $_.Patch, $_.Pre, $_.PrePatch, $_.Build, $_.Prefix) }
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

    $prefixString = $Prefix
    if (-Not(Test-String $prefixString)) {
        $prefixString = $verPrefix
    }

    # new semver
    $nextsemver = @{
        Major    = $major
        Minor    = $minor
        Patch    = $patch
        Pre      = $pre
        PrePatch = $prepatch
        Build    = $build
        Prefix   = $prefixString
    } | Format-SemVerString -IncludePrefix

    $setcmdPattern = "git tag '{0}'{1}"
    $msgString = ""
    if (Test-String $Message) {
        $msgString = " -m '${Message}'"
    }
    $setcmd = [scriptblock]::Create($setcmdPattern -f ($nextsemver, $msgString))

    if ($PSCmdlet.ShouldProcess($Version, "Set-SemVer")) {
        # Ensure no outstanding git commits
        if ($Force -or (Test-GitState -ShowMessage)) {
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
        'Test-String',
        'Test-GitState'
    )
    Variable = @()
}

Export-ModuleMember @exportModuleMemberParams
