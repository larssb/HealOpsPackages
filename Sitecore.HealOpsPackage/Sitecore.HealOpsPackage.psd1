@{
    # Version number of this module.
    ModuleVersion = '1.1.2'

    # ID used to uniquely identify this module
    GUID = '164b9439-949a-41d8-87f8-bfcf6a6b2b20'

    # Author of this module
    Author = 'Lars S. Bengtsson | https://github.com/larssb | https://bengtssondd.it'

    # Copyright statement for this module
    Copyright = 'Lars S. Bengtsson | (https://github.com/larssb), licensed under the MIT License.'

    # Description of the functionality provided by this module
    Description = 'A HealOps package that tests and repairs components of a Sitecore installation infrastructure.'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @(
        "dbatools"
    )

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = '*'

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = '*'

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = '*'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = 'HealOpsPackage', 'Sitecore', 'HealOps'

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'Improved the performance of the Sitecore.Log.Stats file drastically.'

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}