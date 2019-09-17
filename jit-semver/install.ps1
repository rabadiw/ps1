param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

$installDir = Split-Path $MyInvocation.MyCommand.Path -Parent

Import-Module $installDir\src\jit-semver.psd1 -Force
