@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'jit-semver.psm1'
    # Version number of this module.
    ModuleVersion     = '1.0.0'
    # ID used to uniquely identify this module
    GUID              = '469426b5-5d82-4d00-8293-a6fe544dbb0b'
    # Author of this module
    Author            = 'Wael Rabadi, and contributors'
    # Copyright statement for this module
    Copyright         = '(c) 2019-2019 Wael Rabadi, and contributors'
    # Description of the functionality provided by this module
    Description       = 'Provides Semantic Version capabilities to manage your project version using git tag.'
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Functions to export from this module
    FunctionsToExport = @(
        'Get-SemVer',
        'Get-SemVerNext',
        'Set-SemVer',
        'ConvertTo-SemVer',
        'Format-SemVerString',
        'Test-String',
        'Test-GitState',
        'Get-SemVerChangeSummary'
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
            Tags         = @('git', 'jit-semver', 'powershell', 'semantic-versioning')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/rabadiw/ps1/blob/master/LICENSE.txt'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/rabadiw/ps1/tree/master/jit-semver'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/rabadiw/ps1/blob/master/jit-semver/CHANGELOG.md'

            # OVERRIDE THIS FIELD FOR PUBLISHED RELEASES - LEAVE AT 'alpha' FOR CLONED/LOCAL REPO USAGE
            Prerelease   = 'alpha'
        }
    }
}
