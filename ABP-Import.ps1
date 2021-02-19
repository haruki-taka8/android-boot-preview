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
                    PartTime = (Get-ChildItem "$tempLocation\part$($i)\").Count / $desc.FPS
                }
            )
            $i++
        })
    }
})



# Import file
<#
$wpf.Button_Import.Add_Click({
    if (Test-Path $TextBox_Filename.Text) {
        # Unzip
        $script:TempZip = "$PSSCriptRoot\tempZip"
        If (Test-Path $TempZip) {Remove-Item "$TempZip\*" -Recurse}
        Expand-Archive $TextBox_Filename.Text $TempZip -Force

        # Show desc.txt content
        $script:desc = [PSCustomObject] @{}
        $desc | Add-Member NoteProperty Text (Get-Content $TempZip\desc.txt -Raw)
        $TextBox_desc.Text = $desc.Text

        # Fill $desc with data from desc.txt
        #    .Text = Raw content
        #    .Width
        #    .Height
        #    .FPS
        #    .<Ratio (W/H)>
        #    .<Image prefix>
        #    .<FrameInterval>
        #    .Animation
        #        [0]
        #        .Type
        #        .Count
        #        .Pause
        #        .Path
        $FirstLine = (Get-Content $TempZip\desc.txt -First 1) -Split ' '
        $desc | Add-Member NoteProperty Width  $FirstLine[0]
        $desc | Add-Member NoteProperty Height $FirstLine[1]
        $desc | Add-Member NoteProperty FPS    $FirstLine[2]
        $desc | Add-Member NoteProperty Animation ([System.Collections.ArrayList] @())
        
        $desc | Add-Member NoteProperty Interval (1000/$desc.FPS)
        $desc | Add-Member NoteProperty Ratio ($desc.Width/$desc.Height)
        $TempPrefix = (Get-ChildItem $TempZip\part0).name | Select-Object -First 1
        $desc | Add-Member NoteProperty Prefix $TempPrefix.Substring(0, $TempPrefix.Length-5)


        (Get-Content $TempZip\desc.txt | Select-Object -Skip 1).ForEach({
            $ThisLine = $_ -Split ' '
            $desc.Animation.Add(
                [PSCustomObject] @{
                    Type   = $ThisLine[0]
                    Repeat = $ThisLine[1]
                    Pause  = $ThisLine[2]
                    Path   = $ThisLine[3]
                }
            )
        })
    }
})
#>
