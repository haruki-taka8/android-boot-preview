<#
    Cloned from SammyKrosoft/Powershell/How-To-Load-WPF-Form-XAML.ps1
    Modified & used under the MIT License (https://github.com/SammyKrosoft/PowerShell/blob/master/LICENSE.MD)
#>
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# VARIABLES
# $ffmpegLocation = 'E:\Path\ffmpeg-4.3.2-2021-02-20-essentials_build\bin\ffmpeg.exe'
$ffmpegLocation = 'INSERT-PATH-TO-FFMPEG\ffmpeg.exe'
$TempLocation = "$PSScriptRoot\Temp\"

# Basic settings
Set-Location $PSScriptRoot
Add-Type -AssemblyName PresentationFramework, PresentationCore, System.Windows.Forms

# Load a WPF GUI from a XAML file
[Xml] $xaml = Get-Content GUI.xaml
$tempform = [Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::New($xaml))
$wpf = [Hashtable]::Synchronized(@{})
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
    ForEach({$wpf.Add($_, $tempform.FindName($_))})

# Import GUI Control functions
function Update-GUI {
    $wpf.ABP.Dispatcher.Invoke(
        [Windows.Threading.DispatcherPriority]::Background, [action]{})
}

Import-Module "$PSScriptRoot\ABP-Import.ps1",
              "$PSScriptRoot\ABP-Generate.ps1"

$wpf.Button_Goto1.Add_Click({$wpf.TabControl_Main.SelectedIndex = 1})
$wpf.Button_Play.Add_Click({
    $wpf.Media_Preview.LoadedBehavior = "Manual"
    $wpf.Media_Preview.UnloadedBehavior = "Manual"
    $wpf.Media_Preview.Play()
})


# Cleanup on close
$wpf.ABP.Add_Closing({Remove-Module 'ABP-*'})

# Load WPF >> Using method from https://gist.github.com/altrive/6227237
$wpf.ABP.Dispatcher.InvokeAsync({$wpf.ABP.ShowDialog()}).Wait() | Out-Null
