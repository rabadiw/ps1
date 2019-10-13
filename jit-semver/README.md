# JIT-SemVer
A PowerShell productivity module to help manage [Semantic Versioning 2.0.0](https://semver.org/) for any software that follows the git version practice.

# Purpose 
Management of software release requires a step to apply a version prior to distribution. Along with automation, the preferred approach to versioning is to enable the pipeline to manage the application of the version as a step in the pipeline. A common example is the iterative progression from alpha to beta to rc to release. Continuous Deliver (CI) tools today heavily use the command line, and, as such, depend on scripts that can be run via the commandline. 

## Prerequisite
A repository that is Git based and setup to use tagging for version management. This is not a hard rule, but stated to note that it is the common usecase used to design JIT-SemVer.

## Installation
This module has been uploaded to [PowerShell Gallery](https://www.powershellgallery.com/packages/jit-semver). Follow these steps to install.
```powershell
PS> Install-Module -Name jit-semver -Scope CurrentUser
PS> Import-Module -Name jit-semver
```

## Basic Semantic Versioning theory
The following is the taxonomy of versioning as noted by [Semantic Versioning 2.0.0](https://semver.org/). 
```
<valid semver> ::= <version core>
                 | <version core> "-" <pre-release>
                 | <version core> "+" <build>
                 | <version core> "-" <pre-release> "+" <build>
```

The Jit-SemVer scripts adhere to these with a couple of opinions. The pattern used to parse a said version is `<major>.<minor>.<patch>-<pre release>.<pre patch>+<build>`. This will generate the following variations: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.1+1 < 1.0.0-beta < 1.0.0-rc < 1.0.0 < 1.0.1 < 1.1.0 < 1.1.0+1 < 2.0.0`

## How to find current version
See the current version. This command will return the version based on the following order: 1) latest git tag describing the version 2) default to 1.0.0-alpha.0 for repo with no tags set

For repo without tags
```powershell
PS> Get-SemVer
v/1.0.0-alpha.1

PS> Get-SemVer -ExcludePrefix
1.0.0-alpha

# Advanced topic
# Managage multiple products in a monolithic repo
PS> Get-SemVer -Filter "jit-semver"
jit-semver/v1.0.0-alpha

PS> Get-SemVer -Filter "jit-psbuild" -Verbose
VERBOSE: Defaulting to v1.0.0-alpha.
jit-psbuild/v1.0.0-alpha
```

## How to get next version
To increment version to the next value, `Get-SemVerNext` takes a semverb parameter with options of Major|Minor|Patch|Build. The parameter -SemVerb default value is patch.

Upon initial setting, the following will set the version to `v1.0.0-alpha.1`. 

```powershell
PS> Get-SemVerNext -Verbose
WARNING: No version found. See 'Set-SemVer' for instructions on how to tag a version.
v1.0.0-alpha
```

Given a version of 1.0.0-alpha. Here's what each `Get-SemVerNext` would produce. 

```powershell
# To increment version by patch
PS> Set-SemVer -SemVerb patch
v1.0.0-alpha.1

# To increment version by minor.
# No different from patch as for pre-release they mean the same thing.
PS> Set-SemVer -SemVerb minor
v1.0.0-alpha.1

# To increment version by major.
PS> Set-SemVer -SemVerb major
v1.0.0-beta

# To increment version by build.
PS> Set-SemVer -SemVerb build
v1.0.0-alpha+1
```

## How to set version
To set the version, the `Set-SemVer` cmdlet can help and it takes a few paramters. 
- `-Version` flag takes a version input or the default value of `Get-SemVerNext`. 
- `-Title` flag takes a value to set the tag version value to or default to the `-Version` value. 
- `-Message` flag takes a message input to set the details of the tag or the default value of blank. 
- `-Force` flag will apply the version and ignore any outstanding commits. It is important to commit your changes and avoid using this flag.
- `-WhatIf` flag allows to test a condition.

Set the version by specifing the title and message.
```powershell
PS> Set-SemVer -Title "v1.0.0 Alpha" -Message "Release summary goes here" -WhatIf
What if: Performing the operation "Set-SemVer" on target "v1.0.0-alpha".
What if: git tag 'v1.0.0-alpha' -m 'v1.0.0 Alpha
Release summary goes here'
```

To manage the next version to be set.
```powershell
PS> Set-SemVer -Title "v1.0.0 Alpha" -Message "Release summary goes here" -Version (Get-SemVerNext -Version "1.0.0-alpha.1+100" -SemVerb Build -Prefix "jit-semver/v") -WhatIf
What if: Performing the operation "Set-SemVer" on target "jit-semver/v1.0.0-alpha.1+101".
What if: git tag 'jit-semver/v1.0.0-alpha.1+101' -m 'v1.0.0 Alpha
Release summary goes here'
```

## How to manage the version message or summary.
If you use a `CHANGELOG.md` file to summarize changes in your repo. The `Get-SemVerChangeSummary` cmdlet can help and it takes a few parameters.
- `-Version` takes a version input or the default value of `Get-SemVer`.
- `-ChangeLogPath` path to changelog file or defaults to git top level folder `CHANGELOG.md` file. 
- `-HeaderPatternScript` pattern ScriptBlock to match the log header.
- `-ContentPatternScript` pattern ScriptBlock to match the log content.

See [changelog-template.md](templates/changelog-template.md) for a starter template. The heaer and content patterns default to this templates structure. To use a different file structure, set those flags to the desired scriptblocks.

```powershell
PS> Get-SemVerChangeSummary
Name                           Value
----                           -----
Content                        - [FEATURE] Get-SemVer support multiple…
Header                         ## jit-semver/v1.0.0-alpha.2 - 2019-10-13

# Get only the content
PS> Get-SemVerChangeSummary | Select-Object -ExpandProperty Content
```

## Additional Functions

### ConvertTo-SemVer
```powershell
PS> "1.0.0-alpha.1+101" | ConvertTo-SemVer 

Name                           Value
----                           -----
Major                          1
Pre                            alpha
Minor                          0
Patch                          0
Build                          101
PrePatch                       1
```

### Format-SemVerString
```powershell
PS> "1.0.0-alpha.1+101" | ConvertTo-SemVer | Format-SemVerString
1.0.0-alpha.1+101
```

### Test-String - added for code readability
```powershell
PS> Test-String
False
PS> Test-String ""
False
PS> Test-String " "
False
PS> Test-String $null
False
PS> Test-String "a"  
True
```

# Contributors
## Getting started
It is really simple! Clone this repo then dive in. Each folder is a tooling. Below each tooling is the src folder with all the source code, and a test folder for tests related to the tooling.

## Testing
For testing, make sure to install the [Pester](https://github.com/pester/Pester) module.
```powershell
PS> Install-Module Pester -Scope CurrentUser -Force
```

As of today, the tests are run manually within the Visual Studio Code editor.
