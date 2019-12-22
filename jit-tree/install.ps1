param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

$psd1 = Get-ChildItem -Path (join-path $PSScriptRoot -ChildPath src) `
    -Filter *.psd1 -File -Recurse | Select-Object -First 1

# Expect .\src\jit-tree.psd1
Import-Module $psd1 -Force
