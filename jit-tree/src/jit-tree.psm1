. $PSScriptRoot\MessageFunctions.ps1

function Write-Tree {
    [CmdletBinding()]
    param (
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Default",
            ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path = (Get-Location),

        [Parameter(Mandatory = $false, ParameterSetName = "Default",
            ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Specifies, as an int, the depth to list, default -1 (all depths).")]
        [int]
        $Depth = -1,

        [Parameter(Mandatory = $false, ParameterSetName = "Default",
            HelpMessage = "Specifies, as a string array, a property or property that this cmdlet excludes from the operation. The value of this parameter qualifies the Path parameter. Enter a path element or pattern, such as *.txt or A*. Wildcard characters are accepted.")]
        [string[]]$Exclude,

        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Default",
            HelpMessage = "List files in output")]
        [switch]
        $File,


        [Parameter(Mandatory = $false,
            ParameterSetName = "Default",
            HelpMessage = "Gets files and folders with the specified attributes. This parameter supports all attributes and lets you specify complex combinations of attributes.")]
        [System.Management.Automation.FlagsExpression[System.IO.FileAttributes]]$Attributes,

        [Parameter(Mandatory = $false, ParameterSetName = "Default",
            HelpMessage = "Display filesystem entry metadata.")]
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

    function Write-Line($dir, $level, $bars, $isLast, $count, $isDir) {
        $prefix = ""
        for ($i = 0; $i -lt $level; $i++) {
            if ($bars -contains $i) { $prefix += "│  " }
            else { $prefix += "   " }
        }

        if ($isLast) { $prefix += "└──" }
        else { $prefix += "├──" }
        $itemMsg = "$prefix$($dir.Name)"
        if ($isDir) {
            $itemMsg += [IO.Path]::DirectorySeparatorChar
        }        

        if ($DebugPreference.value__) {
            $lastMsg = ("Not-Last", "Last")
            $debugMsg = "[$level|$($bars -join ', ')|$($lastMsg[$isLast])]  ".PadRight(20, ' ')
        }
        if ($DisplayHint) {
            $hintMsg = "[$($dir.Mode), $($dir.LastWriteTime.ToString("yyyy-MM-dd hh:mm tt")), $($count.ToString().PadLeft(8, ' '))]  "
        }

        Write-Output "${debugMsg}${hintMsg}${itemMsg}"
    }

    function GetChildDirectory {

        [OutputType([System.IO.FileSystemInfo[]])]
        param(
            [string]$path
        )
        
        Get-ChildItem $path -Directory -Exclude $Exclude -Attributes $Attributes | Sort-Object -Property Name -Descending
    }

    function GetChildFile {
        
        [OutputType([System.IO.FileSystemInfo[]])]
        param(
            [string]$path
        )

        return Get-ChildItem $path -File -Exclude $Exclude -Attributes $Attributes | Sort-Object -Property Name -Descending
    }

    function GetChildItemCountOrFileLength {
        
        [OutputType([int])]
        param(
            [string]$path
        )

        if ($_.Attributes.HasFlag([System.IO.FileAttributes]::Directory)) {
            return  $_.GetDirectories().Count 
        }
        return $_.Length  
    }

    function LoadFSItems {

        param (
            [string]$path,
            [int]$level,
            [int[]]$subBar
        )

        $fsitems = @()
        if ($File.IsPresent) {
            $fsitems += GetChildFile -path $path
        }
        $fsitems += GetChildDirectory -path $path
        
        $rtn = @($fsitems | ForEach-Object { 
                @{
                    dir           = $_; 
                    isLast        = $false; 
                    childDirCount = (GetChildItemCountOrFileLength $_); 
                    treeLevel     = $level; 
                    treeBarLevel  = $subBar;
                    isDir         = $_.Attributes.HasFlag([System.IO.FileAttributes]::Directory)
                } })
        
        # set $isLast to true for 1st item (note: decending order)
        if ($rtn.Length -gt 0) {
            $rtn[0].isLast = $true 
        }

        return $rtn
    }

    # Guard path
    if (-Not(Test-Path $Path)) {
        Write-Information -MessageData (Format-ErrorMessage "Not a valid path $Path") -InformationAction Continue
        break
    }
    # root path
    $rootPath = Resolve-Path -Path $Path
    Write-Output $rootPath.Path

    if ($DisplayHint.IsPresent) {
        Write-Output "Columns: [Mode, LastWriteTime, Length, Name]"
    }

    # iterate the tree
    $dir = New-Object -TypeName System.Collections.Stack

    # init root
    LoadFSItems -path $rootPath | ForEach-Object { $dir.Push($_) }

    while ($dir.Count -gt 0) {
        
        $dirEntry = $dir.Pop()

        $currentDir = $dirEntry.dir
        $isLast = $dirEntry.isLast
        $count = $dirEntry.childDirCount
        $level = $dirEntry.treeLevel
        $bars = $dirEntry.treeBarLevel
        $isDir = $dirEntry.isDir

        # adhere to depth
        if (($Depth -ne -1) -and ($level -gt $Depth - 1)) { continue }

        Write-Line -dir $currentDir -level $level -bars $bars -isLast $isLast -count $count -isDir $isDir
        
        if ($isDir) { 
            $subBar = [int[]]$bars
            if (-not($isLast) ) {
                if ($null -eq $subBar) {
                    $subBar = [int[]]($level)
                }
                else {
                    $subBar = $subBar + $level
                }
            }
           
            LoadFSItems -path $currentDir -level ($level + 1) -subBar $subBar | ForEach-Object { $dir.Push($_) }
        }
    }
}

$exportModuleMemberParams = @{
    Function = @(
        'Write-Tree'
    )
    Variable = @()
}

Export-ModuleMember @exportModuleMemberParams
