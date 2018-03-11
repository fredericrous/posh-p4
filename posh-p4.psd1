﻿#
# Module manifest for module 'posh-p4'
#
# Generated by: Zougi
#
# Generated on: 2/29/2016
#

@{

# Script module or binary module file associated with this manifest
RootModule = 'posh-p4.psm1'

# Version number of this module.
ModuleVersion = '1.5'

# ID used to uniquely identify this module
GUID = 'ab9ca7f0-544c-417d-b037-3475e18233fb'

# Author of this module
Author = 'Zougi'

# Copyright statement for this module
Copyright = 'MS-PL'

# Description of the functionality provided by this module
Description = 'Perforce PowerShell integration. Prompt info and command line autocompletion'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Functions to export from this module
FunctionsToExport = @( 
        'TabExpansion',
        'Write-P4Prompt')

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all files packaged with this module
FileList = @('P4Prompt.ps1', 'P4TabExpansion.ps1')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('perforce', 'git', 'versioning', 'autocomplete', 'prompt', 'version', 'control', 'helix', 'vcs')

        # A URL to the license for this module.
        LicenseUri = 'https://opensource.org/licenses/MS-PL'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/Zougi/posh-p4'

    } # End of PSData hashtable

} # End of PrivateData hashtable

}

