@{
    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'd1b04f62-83c7-453b-8f10-ed87de946d8a'

    # Author of this module
    Copyright = 'Lars S. Bengtsson | (https://github.com/larssb), licensed under the MIT License.'

    # Copyright statement for this module
    Copyright = '(C) Lars Bengtsson | larssb on GitHub. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Tests and repairs HTTP endpoints of varying kind.'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @(
        "FranzJaegerClient"
    )

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @()

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}