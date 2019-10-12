. $PSScriptRoot\TestFunctions.ps1
. $PSScriptRoot\git.ps1

function ConvertTo-SemVer {
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()][string]$Version
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
        [Parameter(Mandatory = $false)][switch]$ExcludePrefix,
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$Filter
    )
    $ver = $null
    # TBD value
    #   if (Test-SemVerOverride) {
    #     $Version = (Get-SemVerOverride).Version | ConvertTo-SemVer
    #   }

    if ((Test-SemVer -ShowMessage)) {
        if (Test-String $Filter) {
            $ver = Get-GitVersionHistory | Where-Object { $_ -match $Filter } | Sort-Object -Bottom 1
            if (-Not(Test-String $ver)) {
                Write-Error "Failed to find '${Filter}'." -ErrorAction Stop
            }
        }
        else {
            # value of (git describe --tags)
            $ver = Get-GitVersion
        }
    }
    else {
        # default
        Write-Warning "Defaulting to v1.0.0-alpha."
        $ver = "v1.0.0-alpha"
    }

    ConvertTo-SemVer -Version $ver | Format-SemVerString -IncludePrefix:(-Not($ExcludePrefix))
}

function Get-SemVerNext {
    param(
        [Parameter(Mandatory = $false)][ValidateSet("major", "minor", "patch", "build")][string]$SemVerb = $null,
        [Parameter(Mandatory = $false)][string]$Version = (Get-SemVer),
        [Parameter(Mandatory = $false)][string]$Prefix = ""
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

    $prefixString = $verPrefix
    if (Test-String $Prefix) {
        $prefixString = $Prefix
    }

    # new semver
    @{
        Major    = $major
        Minor    = $minor
        Patch    = $patch
        Pre      = $pre
        PrePatch = $prepatch
        Build    = $build
        Prefix   = $prefixString
    } | Format-SemVerString -IncludePrefix
}

function Set-SemVer {
    [cmdletbinding(SupportsShouldProcess = $true)]

    param(
        [Parameter(Mandatory = $false)][string]$Version = (Get-SemVerNext),
        [Parameter(Mandatory = $false)][string]$Message = "",
        [Parameter(Mandatory = $false)][string]$Tree = "",
        [Parameter(Mandatory = $false)][switch]$Force = $false
    )

    $setcmdPattern = "git tag '{0}'{1}{2}"
    $msgString = ""
    # if(-Not(Test-String $Message)){
    #     # derive from CHANGELOG.md
    #     $Message = Get-GitChangeSummary -Version $Version
    # }
    if (Test-String $Message) {
        $msgString = " -m '$($Message)'"
    }
    $setcmd = [scriptblock]::Create($setcmdPattern -f ($Version, $msgString, " ${Tree}".TrimEnd()))

    if ($PSCmdlet.ShouldProcess($Version, "Set-SemVer")) {
        # Ensure no outstanding git commits
        if ($Force -or (Test-GitState -ShowMessage)) {
            Invoke-Command -ScriptBlock $setcmd
            Write-Verbose "Success! Version updated to $($setcmd)."
        }
    }
    else {
        Write-Information "What if: $setcmd" -InformationAction Continue
    }
}

$exportModuleMemberParams = @{
    Function = @(
        'Get-SemVer',
        'Get-SemVerNext',
        'Set-SemVer',
        'ConvertTo-Semver',
        'Format-SemVerString',
        'Test-String',
        'Test-GitState',
        'Get-SemVerChangeSummary'
    )
    Variable = @()
}

Export-ModuleMember @exportModuleMemberParams
