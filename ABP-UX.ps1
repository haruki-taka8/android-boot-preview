# Handles all event handlers (hey do you handle a handler?)
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
$wpf.Button_Goto1.Add_Click({$wpf.TabControl_Main.SelectedIndex = 1})


# .zip Filepicker dialog
$wpf.Button_Filename.Add_Click({
    $Dialog = [Microsoft.Win32.OpenFileDialog]::New()
    $Dialog.Filter = 'Archives (.zip)|*.zip'
    if ($Dialog.ShowDialog()) {
        $wpf.TextBox_Foldername.Text = ''
        $wpf.TextBox_Filename.Text = $Dialog.Filename
    }
})
# Folderpicker dialog
$wpf.Button_Foldername.Add_Click({
    $Dialog = [System.Windows.Forms.FolderBrowserDialog]::New()
    if ($Dialog.ShowDialog()) {
        $wpf.TextBox_Filename.Text = ''
        $wpf.TextBox_Foldername.Text = $Dialog.SelectedPath
    }
})

$wpf.Button_Goto2.Add_Click({
    $wpf.TabControl_Main.SelectedIndex = 2
    Update-GUI

    Import-BootAnimation `
        -ZipLocation $wpf.TextBox_Filename.Text `
        -FolderLocation $wpf.TextBox_Foldername.Text

    $wpf.TabControl_Main.SelectedIndex = 3
    Update-GUI
})


$wpf.Button_Goto3.Add_Click({
    $wpf.TabControl_Main.SelectedIndex = 4
    Update-GUI

    New-Preview `
        -ScreenW $wpf.TextBox_ScreenW.Text `
        -ScreenH $wpf.TextBox_ScreenH.Text `
        -RepeatCount $wpf.TextBox_Repeat.Text `
        -BootTime $wpf.TextBox_Boot.Text

    $wpf.Media_Preview.Source = "$TempLocation\result.avi"
    $wpf.TabControl_Main.SelectedIndex = 5
    Update-GUI
})


$wpf.Button_Play.Add_Click({
    $wpf.Media_Preview.LoadedBehavior = "Manual"
    $wpf.Media_Preview.UnloadedBehavior = "Manual"
    $wpf.Media_Preview.Play()
})
