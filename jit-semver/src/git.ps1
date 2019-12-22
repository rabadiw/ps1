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
    ForEach-Object { , ($_ -split "\s") } |
    ForEach-Object { @{ $_[3] = $_[2] } }
}

function Get-SemVerChangeSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()][string]$Version = (Get-SemVer),

        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to changelog file.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ChangeLogPath = (Get-ChildItem (git rev-parse --show-toplevel) "CHANGELOG.md"),

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Pattern to match the log header.")]
        [ValidateNotNullOrEmpty()]
        [scriptblock]
        $HeaderPatternScript = { DefaultLogHeaderPattern $Version },

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Pattern to match the log content.")]
        [ValidateNotNullOrEmpty()]
        [scriptblock]$ContentPatternScript = { DefaultLogContentPattern }
    )
    if (-Not(Test-String $ChangeLogPath) -or -Not(Test-Path $ChangeLogPath)) {
        Write-Error "ChangeLog file not found at $ChangeLogPath." -ErrorAction Stop
    }
    $content = Get-Content -Path $ChangeLogPath -Raw
    [regex]$rx = "(?s)$(Invoke-Command $HeaderPatternScript)$(Invoke-Command $ContentPatternScript)"
    Write-Verbose "Pattern used $rx"
    $matches = $rx.Match($content)
    return @{
        Header  = $matches.Groups["header"].Value.Trim();
        Content = $matches.Groups["log"].Value.Trim();
    }
}

function DefaultLogHeaderPattern {
    param(
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()][string]$Version = (Get-SemVer)
    )
    $ver = [regex]::Escape($Version)
    "(?<header>##\s+${ver}.*?\n)"
}

function DefaultLogContentPattern { "(?<log>.*?)-{3}" }
