. $PSScriptRoot\TestFunctions.ps1

function ConvertTo-SemVer {
  param(
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)][string]$semver = (git describe --tags)
  )
  [regex]$rx = "(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)-?(?<pre>[a-zA-Z]+)?\.?(?<prepatch>\d+)?\+?(?<build>\d+)?"
  $curver = $rx.Match($semver)

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
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][hashtable]$semver
  )

  $prevalue = if ($semver.pre -ne "") { "-$($semver.pre)" }
  $prepatchvalue = if ($semver.prepatch -ne "") { ".$($semver.prepatch)" }
  $buildvalue = if ($semver.build -ne "") { "+$($semver.build)" }
  "$($semver.major).$($semver.minor).$($semver.patch)${prevalue}${prepatchvalue}${buildvalue}"
}

function Get-SemVerOverride {
  Get-Content ./.semver.yml |
  ForEach-Object { , ($_ -split ':') } |
  ForEach-Object { @{ $_[0] = $_[1].Trim() } }
}

function Get-SemVer {
  $semver = $null
  # TBD value
  #   if (Test-SemVerOverride) {
  #     $semver = (Get-SemVerOverride).Version | ConvertTo-SemVer
  #   }

  if (Test-SemVer) {
    # value of (git describe --tags)
    $semver = ConvertTo-SemVer
  }
  else {
    # default
    $semver = ConvertTo-SemVer -semver "1.0.0-alpha.0"
  }

  $semver | Format-SemVerString
}

function Set-SemVer {
  [cmdletbinding(SupportsShouldProcess = $true)]

  param(
    [Parameter(Mandatory = $false)][ValidateSet("major", "minor", "patch", "build")][string]$semverb = $null,
    [Parameter(Mandatory = $false)][string]$semver = (Get-SemVer)
  )

  ($major, $minor, $patch, $pre, $prepatch, $build) = ConvertTo-SemVer -semver $semver | ForEach-Object { ($_.Major, $_.Minor, $_.Patch, $_.Pre, $_.PrePatch, $_.Build) }
  switch ($semverb) {
    "major" {
      if (Test-String $pre) {
        switch ($pre.ToLower()) {
          "alpha" {
            $pre = "beta"
            $prepatch = ""
          }
          "beta" {
            $pre = "rc"
            $prepatch = ""
          }
          Default {
            $pre = ""
            $prepatch = ""
          }
        }
      }
      else {
        $major++
        $minor = $patch = 0
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
        $prepatch++
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

  $setcmd = {
    param(
      [Parameter(Mandatory)][string]$semver
    )
    git tag $semver
  }

  if ($PSCmdlet.ShouldProcess($semver, "Set-SemVer")) {
    # Ensure no outstanding git commits
    if (Test-GitState) {
      Invoke-Command -ScriptBlock $setcmd -ArgumentList $nextsemver
      Write-Host -ForegroundColor Green "Success! Version updated to $pkgsemver"
    }
  }
  else {
    Write-Output "What if: git tag $nextsemver"
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
