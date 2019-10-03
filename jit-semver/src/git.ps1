function Get-GitVersionHistory {
    (git tag)
}

function Get-GitVersion {
    (git describe --tags)
}

function Get-GitTree {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )
    # only directories and return the hash of KV
    git ls-tree -d HEAD | Where-Object { $_ -match $Name } |
    ForEach-Object { ,($_ -split "\s") } |
    ForEach-Object { @{ $_[3] = $_[2] } }
}

function Get-GitChangeSummary {
    param(
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()][string]$Version=(Get-SemVer)
    )
    $logpath = Split-Path -Path $PSScriptRoot -Parent
    $content = Get-Content -Path (Join-Path $logpath -ChildPath CHANGELOG.md) -Raw
    $ver = [regex]::Escape($Version)
    [regex]$rx = "(?s)##\s+?$ver[^\n]*(?<log>.*)---"
    $rx.Match($content).Groups["log"].Value.Trim()
}
