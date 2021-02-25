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
    $wpf.StackPanel_BigFile.Visibility = 'Hidden'
    Update-GUI

    $ZipLocation = $wpf.TextBox_Filename.Text
    $FolderLocation = $wpf.TextBox_Foldername.Text

    if (Test-Path $tempLocation) {Remove-Item $tempLocation -Recurse -Force}

    # I hate Test-Path because it makes r/badcode.
    if (($ZipLocation -ne '') -and (Test-Path $ZipLocation)) {
        Test-Path $ZipLocation
        if ((Get-ChildItem $ZipLocation).Length -gt 42MB) {
            $wpf.StackPanel_BigFile.Visibility = 'Visible'
        }
        Expand-Archive $ZipLocation $tempLocation -Force
    }
    
    if (($FolderLocation -ne '') -and (Test-path $FolderLocaion)) {
        Test-Path $FolderLocation
        if ((Get-ChildItem $FolderLocation).Length -gt 42MB) {
            $wpf.StackPanel_BigFile.Visibility = 'Visible'
        }
        Copy-Item $FolderLocation $tempLocation -Recurse
    }

    if (Test-Path "$tempLocation\desc.txt") {
        <# Populate $desc with data from desc.txt
            .Width    .Height    .FPS
            .Animation
                .Type    .Count    .Pause    .Path    .[#RGBHex]
                         .PartTime <- Duration w/o Pause (s)
                         .FullTime <- Duration w/ Repeat & Pause (s)
        #>
        $script:desc = [PSCustomObject] @{}
        $FirstLine = (Get-Content $tempLocation\desc.txt -First 1).Split(' ')
        $desc | Add-Member NoteProperty Width  $FirstLine[0]
        $desc | Add-Member NoteProperty Height $FirstLine[1]
        $desc | Add-Member NoteProperty FPS    $FirstLine[2]
        $desc | Add-Member NoteProperty Animation ([System.Collections.ArrayList] @())

        (Get-Content $tempLocation\desc.txt | Select-Object -Skip 1).ForEach({
            $ThisLine = $_.Split(' ')

            $desc.Animation.Add([PSCustomObject] @{
                Type     = $ThisLine[0]
                Repeat   = $ThisLine[1]
                Pause    = $ThisLine[2]
                Path     = $ThisLine[3]
                RGBHex   = $ThisLine.Where{$_[0] -eq '#'}
                PartTime = (Get-ChildItem "$tempLocation\$($ThisLine[3])\").Count / $desc.FPS
                FullTime = 0
            })
        })

        $wpf.TabControl_Main.SelectedIndex = 3
        Update-GUI
    }
})