# Stuff that gets called everywhere
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Update-GUI {
    $wpf.ABP.Dispatcher.Invoke(
        [Windows.Threading.DispatcherPriority]::Background, [action]{})
}

function Set-Progress ([Int] $Percentage, [String] $Text) {
    $wpf.Progress_Status.Value = $Percentage
    if ($null -ne $Event) {
        $wpf.TextBlock_Status.Text = $Text
    }
    Update-GUI
}
