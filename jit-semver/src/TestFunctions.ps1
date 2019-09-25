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
    [Parameter(Mandatory = $false)][string]$val
  )

  return -Not([System.String]::IsNullOrWhiteSpace($val))
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
  $hasDiff = (git diff-index HEAD --).Count -gt 0
  if ($hasDiff) {
    Write-Host -ForegroundColor Red "You have uncommitted changes."
  }
  return -NOT($hasDiff)
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
  $hasVer = ( git describe --tags ).Count -gt 0
  if (-Not($hasVer)) {
    Write-Host "Please add a tag. See 'git tag'."
  }
  return $hasVer
}

<#
.SYNOPSIS
    Test config override.
.INPUTS
    None
.OUTPUTS
    True if .semver.yml exists.
#>
function Test-SemVerOverride {
  Test-Path ./.semver.yml
}

function Test-Function {
  param(
    [Parameter(Mandatory)][scriptblock]$fun,
    [Parameter(Mandatory)][string]$msg
  )

  $result = $fun.Invoke()
  -Not($result) | Where-Object { Write-Host -ForegroundColor Red $msg }
  return $result
}


