#—————————————————————————————————————————————————————————————————————————————+—————————————————————# Import file
Param (
    [Parameter()][String] $InPath,
    [Parameter()][Int] $ScreenW,
    [Parameter()][Int] $ScreenH,
    [Parameter()][Int] $BootTime,
    [Parameter()][Int] $Repeat
)

# Variables
# $script:ffmpegLocation = 'E:\Path\ffmpeg-4.3.2-2021-02-20-essentials_build\bin\ffmpeg.exe'
$script:ffmpegLocation = 'INSERT-PATH-TO-FFMPEG\ffmpeg.exe'
$script:tempLocation = "$PSScriptRoot\Temp\"

if ($null -eq $InPath) {
    & '.\ABP-UILoader.ps1'

} else {
     & '.\ABP-CLI.ps1' `
        -InPath   $InPath `
        -ScreenW  $ScreenW `
        -ScreenH  $ScreenH `
        -BootTime $BootTime `
        -Repeat   $Repeat
}