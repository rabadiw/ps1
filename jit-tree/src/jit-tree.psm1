. $PSScriptRoot\MessageFunctions.ps1
. $PSScriptRoot\ColorTheme.ps1

$JitTreeSettings = @{
    ColorTheme = Get-JitTreeDarkTheme
}

function Write-Tree {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Default",
            ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [Alias("p")][string]
        $Path = (Get-Location),

        [Parameter(Mandatory = $false, ParameterSetName = "Default",
            ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Specifies, as an int, the depth to list, default -1 (all depths).")]
        [Alias("d")][int]
        $Depth = -1,

        [Parameter(Mandatory = $false, ParameterSetName = "Default",
            HelpMessage = "Specifies, as a string array, a property or property that this cmdlet excludes from the operation. The value of this parameter qualifies the Path parameter. Enter a path element or pattern, such as *.txt or A*. Wildcard characters are accepted.")]
        [Alias("e")][string[]]
        $Exclude,

        [Parameter(Mandatory = $false, ParameterSetName = "Default",
            HelpMessage = "List files in output")]
        [Alias("f")][switch]$File,

        [Parameter(Mandatory = $false,
            ParameterSetName = "Default",
            HelpMessage = "Gets files and folders with the specified attributes. This parameter supports all attributes and lets you specify complex combinations of attributes.")]
        [Alias("a")][System.Management.Automation.FlagsExpression[System.IO.FileAttributes]]
        $Attributes,

        [Parameter(Mandatory = $false, ParameterSetName = "Default",
            HelpMessage = "Display filesystem entry metadata.")]
        [Alias("m")][switch]
        $DisplayHint
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

    function Write-DisplayHintHeader() {
        if ($DisplayHint.IsPresent) {
            $text = "$("Mode".PadRight(5, ' ')), $("LastWriteTime".PadRight(19, ' ')), $("Length".PadLeft(9, ' ')), Name"
            $data = Format-MessageData -MessageData $text -ForegroundColor $JitTreeSettings.ColorTheme.DisplayHintForeground
            Write-Information -MessageData $data -InformationAction Continue
        }
    }

    function Write-Line($path, $level, $bars, $isLastItem, $count, $isContainer) {
        $prefix = ""
        for ($i = 0; $i -lt $level; $i++) {
            if ($bars -contains $i) { $prefix += "│   " }
            else { $prefix += "   " }
        }

        if ($isLastItem) { $prefix += "└───" }
        else { $prefix += "├───" }
        $itemMsg = "$($path.Name)"
        if ($isContainer) {
            $itemMsg += [IO.Path]::DirectorySeparatorChar
        }

        if ($DebugPreference.value__) {
            $lastMsg = ("Not-Last", "Last")
            $debugMsg = "[$level|$($bars -join ', ')|$($lastMsg[$isLastItem])]  ".PadRight(30, ' ')
        }
        if ($DisplayHint) {
            $normalizedSize = ConvertTo-ReadableSize $count
            $hintMsg = "$($path.Mode), $($path.LastWriteTime.ToString("yyyy-MM-dd hh:mm tt")), $($normalizedSize.PadLeft(9, ' ')), "
        }

        if ($debugMsg) {
            Write-Information `
                -MessageData (Format-MessageData -MessageData $debugMsg -ForegroundColor $JitTreeSettings.ColorTheme.DisplayHintForeground -NoNewline) `
                -InformationAction Continue
        }

        if ($hintMsg) {
            Write-Information `
                -MessageData (Format-MessageData -MessageData $hintMsg -ForegroundColor $JitTreeSettings.ColorTheme.DisplayHintForeground -NoNewline) `
                -InformationAction Continue
        }

        if ($itemMsg) {
            Write-Information `
                -MessageData (Format-MessageData -MessageData $prefix -NoNewline) `
                -InformationAction Continue

            $fg = [System.ConsoleColor]($JitTreeSettings.ColorTheme.FileForeground, $JitTreeSettings.ColorTheme.DirectoryForeground)[$isContainer]
            Write-Information `
                -MessageData (Format-MessageData -MessageData $itemMsg -ForegroundColor $fg) `
                -InformationAction Continue
        }
    }

    function ConvertTo-ReadableSize {
        [OutputType([string])]
        param(
            [int]$Size
        )

        if ($Size -eq 0) { return "$Size B" }

        $rtn = switch -Regex ([math]::truncate([math]::log($Size, 1024))) {
            '^0' { "$Size B" }
            '^1' { "{0:n2} KB" -f ($Size / 1KB) }
            '^2' { "{0:n2} MB" -f ($Size / 1MB) }
            '^3' { "{0:n2} GB" -f ($Size / 1GB) }
            '^4' { "{0:n2} TB" -f ($Size / 1TB) }
            Default { "{0:n2} PB" -f ($Size / 1pb) }
        }

        return $rtn
    }

    function GetChildItemCountOrFileLength {

        [OutputType([int])]
        param( )

        if ($_.Attributes.HasFlag([System.IO.FileAttributes]::Directory)) {
            if ($File.IsPresent) {
                return  $_.GetFileSystemInfos().Count
            }
            else {
                return $_.GetDirectories().Count
            }
        }
        return $_.Length
    }

    class TreeItem {
        [ValidateNotNullOrEmpty()][System.IO.FileSystemInfo]$Path
        [ValidateNotNullOrEmpty()][System.IO.FileSystemInfo]$LastItem
        [ValidateNotNullOrEmpty()][int]$Length
    }

    function Get-TreeItems {

        [OutputType([TreeItem[]])]
        param(
            [string]$Path
        )

        $getHashArgs = @{
            Path       = $Path
            Attributes = $Attributes
            Exclude    = $Exclude
            Directory  = $true
        }

        if ($File.IsPresent) {
            $getHashArgs.Directory = $false
            $getHashArgs.File = $false
        }

        $fsitems = Get-ChildItem @getHashArgs | Sort-Object -Property PSIsContainer, PSParentPath -Descending

        return @($fsitems | ForEach-Object {
                [TreeItem]@{
                    Path     = $_
                    LastItem = $fsitems | Select-Object -Last 1
                    Length   = (GetChildItemCountOrFileLength $_)
                }
            })
    }

    function Walk-Tree {
        [CmdletBinding()]
        param (

            # Specifies a path to one or more locations.
            [Parameter(Mandatory = $true,
                Position = 0,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true)]
            [ValidateNotNullOrEmpty()]
            [System.IO.FileSystemInfo]
            $Path,

            [Parameter(Mandatory = $true,
                Position = 1,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true,
                HelpMessage = "Last child item of container.")]
            [System.IO.FileSystemInfo]$LastItem,

            [Parameter(Mandatory = $true,
                Position = 2,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true,
                HelpMessage = "Count of container items or length of file.")]
            [int]$Length,

            [Parameter(Mandatory = $true,
                HelpMessage = "Path to one or more locations.")]
            [ValidateNotNullOrEmpty()]
            [Alias("p")][string]
            $RootPath,

            [Parameter()][int]$Depth = 0,
            [Parameter()][int[]]$Bars = 0
        )

        begin {
            $itDepth = 0
            $rootDepth = ($RootPath | Select-String -Pattern $([regex]::escape([IO.Path]::DirectorySeparatorChar)) -AllMatches).Matches.Count

            function Get-ItDepth {
                return (
                    $Path.PSParentPath -replace "Microsoft.PowerShell.Core\\FileSystem::", "" |
                    Select-String -Pattern $([regex]::escape([IO.Path]::DirectorySeparatorChar)) -AllMatches
                ).Matches.Count - $rootDepth
            }
            function Test-LastItem {
                return $LastItem.FullName -eq $Path.FullName
            }
        }

        process {
            $itDepth = Get-ItDepth

            Write-Line -path $Path -level $itDepth -bars $Bars -isLast $(Test-LastItem) -count $Length -isContainer $Path.PSIsContainer

            if ($Path.PSIsContainer -and ($Depth -eq -1 -or $itDepth -lt ($Depth - 1))) {
                $isLastItem = $LastItem.FullName -eq $Path.FullName
                $subBar = [int[]]$Bars
                $level = $itDepth
                if (-not($isLastItem) ) {
                    if ($null -eq $subBar) {
                        $subBar = [int[]]($level)
                    }
                    else {
                        $subBar = $subBar + $level
                    }
                }

                Get-TreeItems -Path $Path | Walk-Tree -Depth $Depth -RootPath $RootPath -Bars $subBar
            }
        }

        end { }
    }

    # Guard path
    if (-Not(Test-Path $Path)) {
        Write-Information -MessageData (Format-ErrorMessage "Not a valid path $Path") -InformationAction Continue
        break
    }

    # root path
    $rootPath = Resolve-Path -Path $Path
    Write-Output $rootPath.Path

    Write-DisplayHintHeader

    # init root
    Get-TreeItems -path $rootPath | Walk-Tree -Depth $Depth -RootPath $rootPath
}

function Write-TreeShort {
    Write-Tree -Depth 1 -File
}

function Write-TreeLong {
    Write-Tree -Depth 1 -DisplayHint -File
}

$exportModuleMemberParams = @{
    Function = @(
        'Write-Tree'
    )
    Variable = @(
        'JitTreeSettings'
    )
    Alias    = @()
}

Export-ModuleMember @exportModuleMemberParams
