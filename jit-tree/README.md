# JIT-Tree
A PowerShell productivity scripts to list contents of directories in a tree-like format.

The need to list the contents of a directory in a tree-like format is one that comes up often. This project focuses on this need and the thought of adding additional functionality not present in other offerings.

# Installation
This module has been uploaded to [PowerShell Gallery](https://www.powershellgallery.com/packages/jit-tree). Follow these steps to install.
```powershell
PS> Install-Module -Name jit-tree -Scope CurrentUser
PS> Import-Module -Name jit-tree
```

# Usage

## List current tree.

```powershell
PS> Write-Tree
C:\github.com\rabadiw\ps1\jit-tree
├──dist/
│  └──jit-tree/
├──scratch/
└──src/
```

## List current tree with directory attributes using the `-DisplayHint` flag.

```powershell
PS> Write-Tree -DisplayHint
C:\github.com\rabadiw\ps1\jit-tree
Columns: [Mode, LastWriteTime, Length, Name]
[d-----, 2019-12-20 02:34 PM,        1]  ├──dist/
[d-----, 2019-12-20 02:34 PM,        0]  │  └──jit-tree/
[d-----, 2019-12-22 02:17 PM,        0]  ├──scratch/
[d-----, 2019-12-21 09:16 PM,        0]  └──src/
```

## List current tree with directory attributes using the `-DisplayHint` flag. Include the files with the `-File` flag. Include hidden and archives with the `-Attributes` flag.

```powershell
PS> Write-Tree -DisplayHint -File -Attributes h,a,d
C:\github.com\rabadiw\ps1\jit-tree
Columns: [Mode, LastWriteTime, Length, Name]
[d-----, 2019-12-23 04:49 PM,        0]  ├──scratch\
[-a----, 2019-12-23 04:49 PM,    25571]  │  ├──ps-tree-test.txt
[-a----, 2019-12-23 04:49 PM,    19153]  │  ├──ps-tree-test_2.txt
[-a----, 2019-12-23 04:49 PM,     3750]  │  ├──tree.ps1
[-a----, 2019-12-23 04:49 PM,     5343]  │  ├──tree.txt
[-a----, 2019-12-23 04:49 PM,     5795]  │  ├──tree-from-recursive-call.txt
[-a----, 2019-12-23 04:49 PM,     3639]  │  └──tree-iterative.ps1
[d-----, 2020-02-06 11:49 PM,        0]  ├──src\
[-a----, 2019-12-23 04:49 PM,     2027]  │  ├──jit-tree.psd1
[-a----, 2020-02-06 11:49 PM,     6661]  │  ├──jit-tree.psm1
[-a----, 2019-12-23 04:49 PM,     1256]  │  └──MessageFunctions.ps1
[-a----, 2020-02-06 11:52 PM,      703]  ├──CHANGELOG.md
[-a----, 2019-12-23 05:17 PM,     1032]  ├──deploy.ps1
[-a----, 2019-12-23 04:49 PM,      272]  ├──install.ps1
[-a----, 2020-02-06 11:56 PM,     3268]  └──README.md
```

## List a specific path (in this case the parent path) with directory attributes. Note, listing shortened for prevaity.

```powershell
PS> Write-Tree -Path ../ -DisplayHint
C:\github.com\rabadiw\ps1
Columns: [Mode, LastWriteTime, Length, Name]
# ... removed for prevaity
[d-----, 2019-12-22 02:05 PM,        1]  ├──jit-tree/
[d-----, 2019-12-20 02:34 PM,        1]  │  ├──dist/
[d-----, 2019-12-20 02:34 PM,        0]  │  │  └──jit-tree/
[d-----, 2019-12-22 02:17 PM,        0]  │  ├──scratch/
[d-----, 2019-12-21 09:16 PM,        0]  │  └──src/
[d-----, 2019-12-21 09:10 PM,        0]  ├──shared/
[d-----, 2019-10-02 10:55 PM,        0]  └──templates/
```

## Same as above, but using the `-Exclude` flag.

```powershell
PS> Write-Tree -Path ../ -DisplayHint -Exclude .git,.vscode,jit-psbuild,jit-semver
C:\github.com\rabadiw\ps1
Columns: [Mode, LastWriteTime, Length, Name]
[d-----, 2019-12-22 02:05 PM,        1]  ├──jit-tree/
[d-----, 2019-12-20 02:34 PM,        1]  │  ├──dist/
[d-----, 2019-12-20 02:34 PM,        0]  │  │  └──jit-tree/
[d-----, 2019-12-22 02:17 PM,        0]  │  ├──scratch/
[d-----, 2019-12-21 09:16 PM,        0]  │  └──src/
[d-----, 2019-12-21 09:10 PM,        0]  ├──shared/
[d-----, 2019-10-02 10:55 PM,        0]  └──templates/

# or, without DisplayHint flag

PS> Write-Tree -Path ../ -Exclude .git,.vscode,jit-psbuild,jit-semver
C:\github.com\rabadiw\ps1
├──jit-tree/
│  ├──dist/
│  │  └──jit-tree/
│  ├──scratch/
│  └──src/
├──shared/
└──templates/
```

# Customization

To enable a `tl` alias with defaults to replace `Get-ChildItems` or `ls`, add the following lines to your PowerShell `$PROFILE`.

```powershell
# Add alias
Set-Alias -Name tl -Value Write-Tree
# Set defaults
$PSDefaultParameterValues.Add("tl:Depth", 1)
$PSDefaultParameterValues.Add("tl:DisplayHint", $true)
$PSDefaultParameterValues.Add("tl:File", $true)
# Add dark theme (this is the default)
$JitTreeSettings.ColorTheme = Get-JitTreeDarkTheme
```

JITTreeSettings.ColorTheme properties:
```powershell
- [System.ConsoleColor] DefaultColor         
- [System.ConsoleColor] DisplayHintForeground
- [System.ConsoleColor] DirectoryForeground  
- [System.ConsoleColor] FileForeground       
```

Color theme cmdlets:
- Get-JitTreeDarkTheme (default theme)
- Get-JitTreeLightTheme
- Get-JitTreeDefaultTheme

# Contributors
## Getting started
It is really simple! Clone this repo then dive in. Each folder is a tooling. Below each tooling is the src folder with all the source code, and a test folder for tests related to the tooling.

## Testing
For testing, make sure to install the [Pester](https://github.com/pester/Pester) module.
```powershell
PS> Install-Module Pester -Scope CurrentUser -Force
```

As of today, the tests are run manually within the Visual Studio Code editor.
