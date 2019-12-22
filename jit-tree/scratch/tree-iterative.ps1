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
        [string[]]$Exclude,

        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [switch]$DisplayHint
    )

    # data structure - per pass collect @(depth,bar[])
    # ├──.git 0 [0]
    # │  └──refs 1 [0]
    # │     ├──heads 2 [0]
    # │     ├──remotes 2 [0]
    # │     │  └──origin 3 [0,2]
    # │     └──tags 2 [0]
    # │        └──jit-semver 3 [0]

    function Write-Line($dir, $level, $bars, $isLast) {
        # Write-Output ("{0}[$level|$($bars -join ', ')] {1}" -f ('   ' * $level), $dir.Name)

        $prefix = ""
        for ($i = 0; $i -lt $level; $i++) {
            if ($bars -contains $i) { $prefix += "│  " }
            else { $prefix += "   " }
        }

        if ($isLast) { $prefix += "└──" }
        else { $prefix += "├──" }

        $dirInfo = ("[{0}, {1}] {2}/" -f $dir.Mode, $dir.LastWriteTime.ToString("s") , $dir.Name)



        if ($DebugPreference.value__) { $debugDisplay = "[$level|$($bars -join ', ')] " }
        if($DisplayHint){ $dirAttr = "[$($dir.Mode), $($dir.LastWriteTime.ToString("s"))]  "}

        #     # Write-Output (@{Depth = "$prefix $($dir.Name)"; Mode = $dir.Mode }) | select -Property Depth, Mode
        #     $col1 = "$prefix$($dir.Name)"
        #     Write-Output "[$($dir.Mode), $($dir.LastWriteTime.ToString("s"))]   $prefix$($dir.Name)/"
        # }

        Write-Output "${dirAttr} $prefix${debugDisplay}$($dir.Name)/"
    }

    function GetChildItem($path) {
        return Get-ChildItem $Path -Directory -Exclude $Exclude | Sort-Object -Property Name -Descending
    }

    # Guard path
    if (-Not(Test-Path $Path)) {
        Write-Error "Not a valid path $Path" -ErrorAction Stop
    }
    # root path
    $currentDir = Resolve-Path -Path $Path
    Write-Output $currentDir.Path

    # iterate the tree
    $dir = New-Object -TypeName System.Collections.Stack

    # setup root subdir
    $subDirs = (GetChildItem -path $currentDir)
    $lastDir = $subDirs | Select-Object -First 1
    $subDirs | ForEach-Object { $dir.Push(@( $_, ($_ -eq $lastDir), [int]$null, [int[]]$null)) }

    while ($dir.Count -gt 0) {
        ($currentDir, $isLast, $level, $bars) = $dir.Pop()

        if (($Depth -ne -1) -and ($level -gt $Depth - 1)) { continue }

        Write-Line -dir $currentDir -level $level -bars $bars -isLast $isLast

        $subDir = (GetChildItem -path $currentDir.FullName)
        $lastDir = $subDir | Select-Object -First 1
        $subDir | ForEach-Object {
            if (-Not($isLast) -and ((GetChildItem -path $currentDir.FullName).Count -gt 0)) {
                $bars += $level
            }
            $dir.Push(@( $_, ($_ -eq $lastDir), [int]($level + 1), [int[]]$bars))
        }

    }
}

Write-Tree "${PSScriptRoot}\.." -Exclude objects -DisplayHint
