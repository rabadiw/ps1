function  Format-MessageData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Object]$MessageData,
        [System.ConsoleColor]$ForegroundColor = $Host.UI.RawUI.ForegroundColor,
        [System.ConsoleColor]$BackgroundColor = $Host.UI.RawUI.BackgroundColor,
        [Switch]$NoNewline
    )
    [System.Management.Automation.HostInformationMessage]@{
        Message         = $MessageData
        ForegroundColor = $ForegroundColor
        BackgroundColor = $BackgroundColor
        NoNewline       = $NoNewline.IsPresent
    }
}

function Format-InformationMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Object]$MessageData
    )
    Format-MessageData -MessageData "INFO: $MessageData"
}

function Format-WarningMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Object]$MessageData
    )
    Format-MessageData -MessageData "WARNING: $MessageData" -ForegroundColor Yellow
}

function Format-ErrorMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Object]$MessageData
    )
    Format-MessageData -MessageData "ERROR: $MessageData" -ForegroundColor Red
}



function Get-DefaultTheme() { 
    @{
        defaultColor  = $Host.UI.RawUI.ForegroundColor
        displayHintFg = $Host.UI.RawUI.ForegroundColor
        directoryFg   = $Host.UI.RawUI.ForegroundColor
        fileFg        = $Host.UI.RawUI.ForegroundColor
    }
}

function Get-DarkTheme() { 
    @{
        defaultColor  = $Host.UI.RawUI.ForegroundColor
        displayHintFg = [System.ConsoleColor]::DarkGray
        directoryFg   = [System.ConsoleColor]::Green
        fileFg        = $Host.UI.RawUI.ForegroundColor
    }
}

function Get-LightTheme() { 
    @{
        defaultColor  = $Host.UI.RawUI.ForegroundColor
        displayHintFg = [System.ConsoleColor]::DarkGray
        directoryFg   = [System.ConsoleColor]::Green
        fileFg        = $Host.UI.RawUI.ForegroundColor
    }
}