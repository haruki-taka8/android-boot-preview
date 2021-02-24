# Handles everything related to loading in bootanimation.zip
#—————————————————————————————————————————————————————————————————————————————+—————————————————————

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

# Import file
$wpf.Button_Goto2.Add_Click({
    $wpf.TabControl_Main.SelectedIndex = 2
    Update-GUI

    # Call helper
    Start-Job -FilePath .\ABP-Import-Helper.ps1 -ArgumentList `
        $tempLocation,
        $wpf.TextBox_Filename.Text,
        $wpf.TextBox_Foldername.Text

    # Watch file change
    do {
        Update-GUI
        Start-Sleep 1
    } until (Test-Path "$tempLocation\import.dat")

    <# Fill $desc with data from desc.txt
    .Width
    .Height
    .FPS
    .Animation
        .Type
        .Count
        .Pause
        .Path
        .[#RGBHex]
        .<PartTime>  <-- Duration without Pause (seconds)
        .<FullTime> <-- Duration w/ Repeat & Pause (seconds)
    #>
    $script:desc = [PSCustomObject] @{}
    $FirstLine = (Get-Content $tempLocation\desc.txt -First 1).Split(' ')
    $desc | Add-Member NoteProperty Width  $FirstLine[0]
    $desc | Add-Member NoteProperty Height $FirstLine[1]
    $desc | Add-Member NoteProperty FPS    $FirstLine[2]
    $desc | Add-Member NoteProperty Animation ([System.Collections.ArrayList] @())
    (Get-Content $tempLocation\desc.txt | Select-Object -Skip 1).ForEach({
        $ThisLine = $_.Split(' ')
        $desc.Animation.Add(
            [PSCustomObject] @{
                Type     = $ThisLine[0]
                Repeat   = $ThisLine[1]
                Pause    = $ThisLine[2]
                Path     = $ThisLine[3]
                RGBHex   = $ThisLine.Where{$_[0] -eq '#'}
                PartTime = ((Get-ChildItem "$tempLocation\$($ThisLine[3])\").Count+1) / $desc.FPS
                FullTime = 0
            }
        )
    })
    $wpf.TabControl_Main.SelectedIndex = 3
})
