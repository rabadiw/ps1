function  Format-MessageData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Object]$MessageData,
        [Alias("fg")]
        [System.ConsoleColor]$ForegroundColor = $Host.UI.RawUI.ForegroundColor,
        [Alias("bg")]
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