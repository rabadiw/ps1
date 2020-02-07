# PowerShell does not have the ability to reference a shared library outside of import-module
# work around, maintian a script to do it for us

$destinations = ("..\jit-psbuild\src", "..\jit-semver\src", "..\jit-tree\src")
$destinations | ForEach-Object { Copy-Item -Path $PSScriptRoot\* -Exclude share.ps1  -Destination (Resolve-Path (Join-Path $PSScriptRoot $_)) -Verbose }
