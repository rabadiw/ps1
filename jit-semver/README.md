# JIT-SemVer
A PowerShell productivity scripts to help manage [Semantic Versioning 2.0.0](https://semver.org/) for any software that follows the git version practice.

# Purpose 
Management of software release requires a step to apply a version prior to distribution. Along with automation, the preferred approach to versioning is to enable the pipeline to manage the application of the version as a step in the pipeline. A common example is the iterative progression from alpha to beta to rc to release. Continuous Deliver (CI) tools today heavily use the command line, and, as such, depend on scripts that can be run via the commandline. 

## Prerequisite
A repository that is Git based and setup to use tagging for version management. This is not a hard rule, but stated to note that it is the common usecase used to design JIT-SemVer.

## Installation

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
1.0.0-alpha.1
```

## How to set version
To increment version to the next value, Set-SemVer takes a semverb parameter with options of Major|Minor|Patch|Build. The parameter -SemVerb default value is patch.

Upon initial setting, the following will set the version to `v1.0.0-alpha.1`. The first 2 statements in the output are informational as no tag has been found. The `-Forece` parameter will still apply the tag and ignore any outstanding commits. Therefore, it is important to commit your changes and avoid using the `-Forece` paramater.

```powershell
PS> Set-SemVer        
No tags were found. See 'git tag' for instructions on how to add a tag.
Defaulting to 1.0.0-alpha.
Success! Version updated to git tag 'v1.0.0-alpha'.
```

Given a version of 1.0.0-alpha. Here's what each `Set-SemVer` would produce. 

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

Increment version by patch but also provide a prefix and message. This will tag git with `jit-semver/v1.0.0-alpha.1`.
```powershell
PS> Set-SemVer -WhatIf -Message "A description for the tag" -Prefix "jit-semver/"
What if: Performing the operation "Set-SemVer" on target "1.0.0-alpha".
What if: git tag 'jit-semver/v1.0.0-alpha.1' -m 'A description for the tag'
```

You also have the ability to test conditions using -WhatIf parameter.
```powershell
PS> set-semver -semver "1.0.0-alpha.1+101" -SemVerb build -WhatIf                                         
What if: Performing the operation "Set-SemVer" on target "1.0.0-alpha.1+101".
What if: git tag 1.0.0-alpha.1+102
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
