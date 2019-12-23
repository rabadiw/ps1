. $PSScriptRoot\MessageFunctions.ps1

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

        [Parameter(Mandatory = $false,
            ParameterSetName = "Default",
            HelpMessage = "Specifies, as a string array, a property or property that this cmdlet excludes from the operation. The value of this parameter qualifies the Path parameter. Enter a path element or pattern, such as *.txt or A*. Wildcard characters are accepted.")]
        [string[]]$Exclude,

        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [switch]$DisplayHint
    )

    # data structure - per pass collect @(depth,bars[],Last/NotLast)
    # [0||Not-Last]       ├──.git/
    # [1|0|Last]          │  └──refs/
    # [2|0|Not-Last]      │     ├──heads/
    # [2|0|Not-Last]      │     ├──remotes/
    # [3|0, 2|Last]       │     │  └──origin/
    # [2|0|Last]          │     └──tags/
    # [3|0|Not-Last]      │        ├──jit-psbuild/
    # [3|0|Last]          │        └──jit-semver/
    # [0||Last]           └──templates/

    function Write-Line($dir, $level, $bars, $isLast, $count) {
        $prefix = ""
        for ($i = 0; $i -lt $level; $i++) {
            if ($bars -contains $i) { $prefix += "│  " }
            else { $prefix += "   " }
        }

        if ($isLast) { $prefix += "└──" }
        else { $prefix += "├──" }
        $itemMsg = "$prefix$($dir.Name)/"

        if ($DebugPreference.value__) {
            $lastMsg = ("Not-Last", "Last")
            $debugMsg = "[$level|$($bars -join ', ')|$($lastMsg[$isLast])]  ".PadRight(20, ' ')
        }
        if ($DisplayHint) {
            $hintMsg = "[$($dir.Mode), $($dir.LastWriteTime.ToString("yyyy-MM-dd hh:mm tt")), $($count.ToString().PadLeft(6, ' '))]  "
        }

        Write-Output "${debugMsg}${hintMsg}${itemMsg}"
    }

    function GetChildItem($path) {
        return Get-ChildItem $path -Directory -Exclude $Exclude | Sort-Object -Property Name -Descending
    }

    # Guard path
    if (-Not(Test-Path $Path)) {
        Write-Information -MessageData (Format-ErrorMessage "Not a valid path $Path") -InformationAction Continue
        break
    }
    # root path
    $currentDir = Resolve-Path -Path $Path
    Write-Output $currentDir.Path

    if ($DisplayHint.IsPresent) {
        Write-Output "Columns: [Mode, LastWriteTime, Count, Name]"
    }

    # iterate the tree
    $dir = New-Object -TypeName System.Collections.Stack

    # setup root subdir
    $subDirs = (GetChildItem -path $currentDir)
    $subDirs | Select-Object -First 1 | ForEach-Object { $dir.Push(@( $_, $true, $subDir.Count, [int]$null, [int[]]$null)) }
    $subDirs | Select-Object -Skip 1 | ForEach-Object { $dir.Push(@( $_, $false, $subDir.Count, [int]$null, [int[]]$null)) }

    while ($dir.Count -gt 0) {
        ($currentDir, $isLast, $count, $level, $bars) = $dir.Pop()

        if (($Depth -ne -1) -and ($level -gt $Depth - 1)) { continue }

        Write-Line -dir $currentDir -level $level -bars $bars -isLast $isLast -count $count

        $subBar = [int[]]$bars
        $hasChildren = (GetChildItem -path $currentDir.FullName).Count -gt 0
        if (-not($isLast) -and $hasChildren) {
            if ($null -eq $subBar) {
                $subBar = [int[]]($level)
            }
            else {
                $subBar = $subBar + $level
            }
        }

        $subDir = (GetChildItem -path $currentDir.FullName)
        $subDir | Select-Object -First 1 | ForEach-Object { $dir.Push(@( $_, $true, $subDir.Count, [int]($level + 1), [int[]]$subBar)) }
        $subDir | Select-Object -Skip 1 | ForEach-Object { $dir.Push(@( $_, $false, $subDir.Count, [int]($level + 1), [int[]]$subBar)) }
    }
}

$exportModuleMemberParams = @{
    Function = @(
        'Write-Tree'
    )
    Variable = @()
}

Export-ModuleMember @exportModuleMemberParams
