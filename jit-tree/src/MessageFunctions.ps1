function Format-HostInformationMessage {
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
    Format-HostInformationMessage -MessageData "INFO: $MessageData"
}

function Format-WarningMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Object]$MessageData
    )
    Format-HostInformationMessage -MessageData "WARNING: $MessageData" -ForegroundColor Yellow
}

function Format-ErrorMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Object]$MessageData
    )
    Format-HostInformationMessage -MessageData "ERROR: $MessageData" -ForegroundColor Red
}
