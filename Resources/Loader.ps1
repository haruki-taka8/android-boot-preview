<#
    Cloned from SammyKrosoft/Powershell/How-To-Load-WPF-Form-XAML.ps1
    Modified & used under the MIT License (https://github.com/SammyKrosoft/PowerShell/blob/master/LICENSE.MD)
#>
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# Import the base fuction & Initialize
$baseLocation = Get-Location
if (Test-path "$baseLocation\Resources") {
	$baseLocation = Join-Path $baseLocation 'Resources'
}
$PSDefaultParameterValues = @{'*:Encoding' = 'UTF8'}

# Import-Module "$baseLocation\Functions\SF7N-Base.ps1"
Add-Type -AssemblyName PresentationFramework, PresentationCore

# Load a WPF GUI from a XAML file
[Xml] $xaml = Get-Content "$baseLocation\GUI.xaml"
$tempform = [Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::New($xaml))
$wpf = @{}
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
    ForEach({$wpf.Add($_, $tempform.FindName($_))})

# Import GUI Control functions
Import-Module "$baseLocation\ABP-Import.ps1",
              "$baseLocation\ABP-Control.ps1"

# Cleanup on close
$wpf.ABP.Add_Closing({
    $wpf.Image_Preview.Source = $null
    Remove-Module 'ABP-*'
})

# Load WPF >> Using method from https://gist.github.com/altrive/6227237
$wpf.ABP.Dispatcher.InvokeAsync({$wpf.ABP.ShowDialog()}).Wait() | Out-Null
