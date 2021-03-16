Param (
    [Parameter(Mandatory)][String] $InPath,
    [Parameter(Mandatory)][Int] $ScreenW,
    [Parameter(Mandatory)][Int] $ScreenH,
    [Parameter(Mandatory)][Int] $BootTime,
    [Parameter(Mandatory)][Int] $Repeat
)

# Basic settings
$script:ffmpegLocation = 'INSERT-PATH-TO-FFMPEG\ffmpeg.exe'
# $script:ffmpegLocation = 'E:\Path\ffmpeg-4.3.2-2021-02-20-essentials_build\bin\ffmpeg.exe'
$script:tempLocation = "$PSScriptRoot\Temp\"
Set-Location $PSScriptRoot

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

# Output
Clear-Host
Write-Host "The preview is ready at $PSScriptRoot\Temp\result.avi"
Write-Host
Exit-PSSession