function Get-JitTreeDefaultTheme() { 
    @{
        DefaultColor          = $Host.UI.RawUI.ForegroundColor
        DisplayHintForeground = $Host.UI.RawUI.ForegroundColor
        DirectoryForeground   = $Host.UI.RawUI.ForegroundColor
        FileForeground        = $Host.UI.RawUI.ForegroundColor
    }
}

function Get-JitTreeDarkTheme() { 
    @{
        DefaultColor          = $Host.UI.RawUI.ForegroundColor
        DisplayHintForeground = [System.ConsoleColor]::DarkGray
        DirectoryForeground   = [System.ConsoleColor]::Green
        FileForeground        = $Host.UI.RawUI.ForegroundColor
    }
}

function Get-JitTreeLightTheme() { 
    @{
        DefaultColor          = $Host.UI.RawUI.ForegroundColor
        DisplayHintForeground = [System.ConsoleColor]::DarkGray
        DirectoryForeground   = [System.ConsoleColor]::Green
        FileForeground        = $Host.UI.RawUI.ForegroundColor
    }
}

$exportModuleMemberParams = @{
    Function = @(
        'Get-JitTreeDefaultTheme',
        'Get-JitTreeDarkTheme',
        'Get-JitTreeLightTheme'
    )
    Variable = @()
}

Export-ModuleMember @exportModuleMemberParams