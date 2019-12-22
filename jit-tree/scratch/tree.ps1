function Write-Tree {
    [CmdletBinding()]
    param (
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $false,
            Position = 0,
            ParameterSetName = "Default",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path = (Get-Location),

        [Parameter(Mandatory = $false,
            ParameterSetName = "Default",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to one or more locations.")]
        [int]
        $Depth = -1,

        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [string[]]$Exclude
    )

    # $PathDepth = ((Resolve-Path $Path) | select-string -Pattern '[\\/]' -AllMatches).Matches.Count
    # Write-Output (Resolve-Path -Path $Path -Relative)
    # foreach ($item in (Get-ChildItem $Path -Directory -Recurse -Depth 2)) {
    #     $depth = 0
    #     $depth = ((Resolve-Path $item) | select-string -Pattern '[\\/]' -AllMatches).Matches.Count - $PathDepth - 1
    #     Write-Output "$('    '*($depth))|--$($item.Name)"
    # }

    # ├
    # ─
    # └


    function Test-ParentSingle {
        return (Get-ChildItem $_ -Directory).Count -eq 0
    }

    function Write-Tree-Recursive {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Path,
            [Parameter(Mandatory = $false)][string[]]$Exclude,
            [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][int]$PathDepth,
            [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][int]$Depth,
            [Parameter(Mandatory = $false)][int[]]$bars

        )

        # data structure - per pass collect @(depth,bar[])
        # ├──.git 0 [0]
        # │  └──refs 1 [0]
        # │     ├──heads 2 [0]
        # │     ├──remotes 2 [0]
        # │     │  └──origin 3 [0,2]
        # │     └──tags 2 [0]
        # │        └──jit-semver 3 [0]


        if (($Depth -ne -1) -and ($PathDepth -gt $Depth - 1)) { return }

        $items = @(Get-ChildItem $Path -Directory -Exclude $Exclude | Sort-Object -Property Name)
        $items | select -SkipLast 1 | % {
            if (-not(Test-ParentSingle $_)) {
                $b = $bars + $PathDepth
            }
            $prefix = ""
            for ($i = 0; $i -lt $PathDepth; $i++) {
                if ($bars -contains $i) {
                    $prefix += "│  "
                }
                else {
                    $prefix += "   "
                }
            }
            Write-Output "$prefix├──$($_.Name) $PathDepth ($bars)"
            Write-Tree-Recursive -Path $_ -PathDepth ($PathDepth + 1) -Depth $Depth -bars $b -Exclude $Exclude
        }

        # handle last differently
        $items | select -Last 1 | % {
            $prefix = ""
            for ($i = 0; $i -lt $PathDepth; $i++) {
                if ($bars -contains $i) {
                    $prefix += "│  "
                }
                else {
                    $prefix += "   "
                }
            }
            Write-Output "$prefix└──$($_.Name) $PathDepth ($bars)"
            Write-Tree-Recursive -Path $_ -PathDepth ($PathDepth + 1) -Depth $Depth -bars $bars -Exclude $Exclude
        }
    }

    # root path
    Write-Output (Resolve-Path -Path $Path -Relative)
    # children recursive
    Write-Tree-Recursive -Path $Path -PathDepth 0 -Depth $Depth -Exclude $Exclude
}

# Write-Tree "${PSScriptRoot}\.." -Exclude "objects"
