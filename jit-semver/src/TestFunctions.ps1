<#
.SYNOPSIS
    Test if string is a valid string.
.INPUTS
    String or $null
.OUTPUTS
    True if string is not null.
#>
function Test-String {
    param (
        [Parameter(Mandatory = $false, Position = 0)][string]$Value
    )

    return -Not([System.String]::IsNullOrWhiteSpace($Value))
}

<#
.SYNOPSIS
    Test git repo has any changes or state is dirty.
.INPUTS
    None
.OUTPUTS
    True if git changes were not found.
#>
function Test-GitState {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)][switch]$ShowMessage = $false
    )
    $hasDiff = ( git diff-index HEAD -- ).Count -gt 0
    if ($hasDiff -and $ShowMessage) {
        Write-Warning "You have uncommitted git changes." 
    }
    -Not($hasDiff)
}

<#
.SYNOPSIS
    Test git has tags.
.INPUTS
    None
.OUTPUTS
    True if git has tags.
#>
function Test-SemVer {

    param(
        # If specified, show help message if missing tags.
        [Parameter(Mandatory = $false, Position = 0)][switch]$ShowMessage = $false
    )

    $hasVer = ( git tag ).Count -gt 0
    if ($ShowMessage -and -Not($hasVer)) {
        Write-Warning "No version found. See 'Set-SemVer' for instructions on how to tag a version."
    }
    return $hasVer
}

<#
.SYNOPSIS
    Test config override.
.INPUTS
    None
.OUTPUTS
    True if .semver.[yaml|yml] exists.
#>
function Test-SemVerOverride {
    if (Test-Path ./.semver.yml) {
        Write-Warning "Please rename .semver.yml to .semver.yaml."
    }
    (Test-Path ./.semver.yml, ./.semver.yaml1 | Where-Object { $_ -eq $true }).Count -gt 0
}

<#
.SYNOPSIS
    ???
#>
function Test-Function {
    param(
        [Parameter(Mandatory)][scriptblock]$fun,
        [Parameter(Mandatory)][string]$msg
    )

    $result = $fun.Invoke()
    -Not($result) | Where-Object { Write-Error $msg }
    return $result
}


