@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'jit-tree.psm1'
    # Version number of this module.
    ModuleVersion     = '1.0.0'
    # ID used to uniquely identify this module
    GUID              = '6402d127-28af-4a2f-9594-c00e01f3dd9a'
    # Author of this module
    Author            = 'Wael Rabadi, and contributors'
    # Copyright statement for this module
    Copyright         = '(c) 2019-2019 Wael Rabadi, and contributors'
    # Description of the functionality provided by this module
    Description       = 'Provides capabilities to list contents of directories in a tree-like format.'
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Functions to export from this module
    FunctionsToExport = @(
        'Write-Tree'
    )

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @('')

    # Aliases to export from this module
    AliasesToExport   = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    # This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('tree', 'powershell')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/rabadiw/ps1/blob/master/LICENSE.txt'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/rabadiw/ps1/tree/master/jit-tree'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/rabadiw/ps1/blob/master/jit-tree/CHANGELOG.md'

            # OVERRIDE THIS FIELD FOR PUBLISHED RELEASES - LEAVE AT 'alpha' FOR CLONED/LOCAL REPO USAGE
            Prerelease   = 'alpha'
        }
    }
}
