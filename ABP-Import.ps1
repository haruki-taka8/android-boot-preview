# Handles everything related to loading in bootanimation.zip
#—————————————————————————————————————————————————————————————————————————————+—————————————————————

# .zip Filepicker dialog
$wpf.Button_Filename.Add_Click({
    $Dialog = [Microsoft.Win32.OpenFileDialog]::New()
    $Dialog.Filter = 'Archives (.zip)|*.zip'
    if ($Dialog.ShowDialog()) {
        $wpf.TextBox_Filename.Text = $Dialog.Filename
        $wpf.TextBox_Foldername.Text = ''
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
$wpf.Button_Import.Add_Click({
    $Extracted    = $false
    Set-Progress 0 'Extracting boot animation'
    if (($wpf.TextBox_Filename.Text -ne '') -and (Test-Path $wpf.TextBox_Filename.Text)) {
        # Extract .zip
        $Extracted = $true
        Remove-Item $tempLocation -Recurse -Force
        Expand-Archive $wpf.TextBox_Filename.Text $tempLocation -Force

    } elseif (($wpf.TextBox_Foldername.Text -ne '') -and (Test-Path $wpf.TextBox_Foldername.Text)) {
        # Extract folder
        $Extracted = $true
        Remove-Item $tempLocation -Recurse -Force
        Copy-Item $wpf.TextBox_Foldername.Text $tempLocation -Recurse
    }

    if ($Extracted) {
        Set-Progress 50 'Comprehending desc.txt'
        $wpf.TextBox_Desc.Text = Get-Content $tempLocation\desc.txt -Raw
        # Prepare $desc variable from desc.txt
        $script:desc = [PSCustomObject] @{}
        
        <# Fill $desc with data from desc.txt
            .Text = Raw content
            .Width
            .Height
            .FPS
            .<Ratio (W/H)>
            .<FrameInterval>
            .Animation
                .Type
                .Count
                .Pause
                .Path
                .[#RGBHex]
                .<PartTime>
        #>
        $FirstLine = (Get-Content $tempLocation\desc.txt -First 1).Split(' ')
        $desc | Add-Member NoteProperty Width  $FirstLine[0]
        $desc | Add-Member NoteProperty Height $FirstLine[1]
        $desc | Add-Member NoteProperty FPS    $FirstLine[2]
        $desc | Add-Member NoteProperty Animation ([System.Collections.ArrayList] @())

        $desc | Add-Member NoteProperty Interval (1000/$desc.FPS)
        $desc | Add-Member NoteProperty Ratio ($desc.Width/$desc.Height)

        $i = 0
        (Get-Content $tempLocation\desc.txt | Select-Object -Skip 1).ForEach({
            $ThisLine = $_.Split(' ')

            $desc.Animation.Add(
                [PSCustomObject] @{
                    Type     = $ThisLine[0]
                    Repeat   = $ThisLine[1]
                    Pause    = $ThisLine[2]
                    Path     = $ThisLine[3]
                    RGBHex   = $ThisLine.Where{$_[0] -eq '#'}
                    PartTime = ((Get-ChildItem "$tempLocation\part$($i)\").Count+1) / $desc.FPS
                }
            )
            $i++
        })
    }

    Set-Progress 100 'Import done'
})