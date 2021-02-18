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
# Write-Log 'INF' 'Import GUI Control Modules'
# Import-Module "$baseLocation\Functions\SF7N-UX.ps1",
#     "$baseLocation\Functions\SF7N-Edit.ps1",
#     "$baseLocation\Functions\SF7N-Search.ps1",
#     "$baseLocation\SF7N-GUI.ps1"

# Cleanup on close
# $wpf.SF7N.Add_Closing({
#     Write-Log 'DBG'
#     Write-Log 'INF' 'Remove Modules'
#     # Remove-Module 'SF7N-*'
# })

# Load WPF >> Using method from https://gist.github.com/altrive/6227237
$wpf.ABP.Dispatcher.InvokeAsync({$wpf.ABP.ShowDialog()}).Wait() | Out-Null
