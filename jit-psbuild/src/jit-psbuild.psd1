@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'jit-psbuild.psm1'
    # Version number of this module.
    ModuleVersion     = '1.0.0'
    # ID used to uniquely identify this module
    GUID              = '807249d0-2ebf-4d0a-978a-ad321165e378'
    # Author of this module
    Author            = 'Wael Rabadi, and contributors'
    # Copyright statement for this module
    Copyright         = '(c) 2019-2019 Wael Rabadi, and contributors'
    # Description of the functionality provided by this module
    Description       = 'Provides PowerShell Module capabilities to build and deploy using jit-semver version management.'
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Functions to export from this module
    FunctionsToExport = @(
        'Get-DefaultSrcPath',
        'Get-DefaultPSDistPath',
        'Build-PSModule',
        'Set-PSModuleVersion'
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
            Tags         = @('git', 'jit-semver', "powershell", "psmodule")

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/rabadiw/ps1/blob/master/LICENSE.txt'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/rabadiw/ps1/tree/master/jit-psbuild'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/rabadiw/ps1/blob/master/jit-psbuild/CHANGELOG.md'

            # OVERRIDE THIS FIELD FOR PUBLISHED RELEASES - LEAVE AT 'alpha' FOR CLONED/LOCAL REPO USAGE
            Prerelease   = 'alpha'
        }
    }
}
