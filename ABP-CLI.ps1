Param (
    [Parameter(Mandatory)][String] $InPath,
    [Parameter(Mandatory)][Int] $ScreenW,
    [Parameter(Mandatory)][Int] $ScreenH,
    [Parameter(Mandatory)][Int] $BootTime,
    [Parameter(Mandatory)][Int] $Repeat
)

# Import required modules
Import-Module "$PSScriptRoot\ABP-Generate.ps1",
              "$PSScriptRoot\ABP-Import.ps1" -Force

# Import .zip/folder
if (($InPath[-4..-1] -join '') -eq '.zip') {
    Import-BootAnimation -ZipLocation $InPath
} else {
    Import-BootAnimation -FolderLocation $InPath
}

# Generate preview
New-Preview `
    -ScreenW $ScreenW `
    -ScreenH $ScreenH `
    -BootTime $BootTime `
    -RepeatCount $Repeat