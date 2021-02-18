Add-Type -AssemblyName PresentationFramework, PresentationCore
$wpf = [Hashtable]::Synchronized(@{})
[xml] $xaml = Get-Content $PSScriptRoot\GUI.xaml
$reader = New-Object System.Xml.XmlNodeReader $xaml
$wpf.Window = [Windows.Markup.XamlReader]::Load($reader)
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
    ForEach({$wpf.Add($_, $wpf.Window.FindName($_))})

Import-Module "$PSScriptRoot\ABP-Import.ps1", "$PSScriptRoot\ABP-Control.ps1"
$wpf.Window.Add_Closing({
    Remove-Module 'ABP-*'
})

$wpf.Window.ShowDialog() | Out-Null


# $newRunspace = [RunspaceFactory]::CreateRunspace()
# $newRunspace.ApartmentState = 'STA'
# $newRunspace.ThreadOptions = 'ReuseThread'
# $newRunspace.Open()
# $newRunspace.SessionStateProxy.SetVariable('wpf',$wpf)
# $psCmd = [PowerShell]::Create().AddScript({  
    
#     $wpf.Error = $Error
# })
# $psCmd.Runspace = $newRunspace
# $data = $psCmd.BeginInvoke()
