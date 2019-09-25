# JIT-SemVer
A PowerShell productivity scripts to help manage [Semantic Versioning 2.0.0](https://semver.org/) for any software that follows the git version practice.

# Purpose 
Automation requires a step to version code prior to release a software in a set stage. For example, iterating over alpha to beta to rc to release. Automation also depends on scripts that can be run via command line. 

## Prerequisite
A repository that is Git based and setup to use tagging for version management. 

## Installation


## How to find current version
See the current version
```powershell
PS> Get-SemVer

# output: 1.0.0-alpha.1
```

# Contributors
## Getting started
It is really simple! Clone this repo then dive in. Each folder is a tooling. Below each tooling is the src folder with all the source code, and a test folder for tests related to the tooling.

## Testing
For testing, make sure to install the [Pester](https://github.com/pester/Pester) module.
```powershell
PS> Install-Module Pester -Scope CurrentUser -Force
```
