# Handles everything related to loading in bootanimation.zip
#—————————————————————————————————————————————————————————————————————————————+—————————————————————

# Filepicker dialog
$wpf.Button_Filename.Add_Click({
    $Dialog = [Microsoft.Win32.OpenFileDialog]::New()
    $Dialog.Filter = 'Archives (.zip)|*.zip'
    if ($Dialog.ShowDialog()) {
        $wpf.TextBox_Filename.Text = $Dialog.Filename
    }
})

# Import file
$wpf.Button_Import.Add_Click({
    if (Test-Path $wpf.TextBox_Filename.Text) {
        # Unzip
        $TempZip = "$baseLocation\tempZip"
        Remove-Item $TempZip -Recurse
        Expand-Archive $wpf.TextBox_Filename.Text $TempZip

        # Show desc.txt content
        $Desc = (Get-Content $TempZip\desc.txt -Raw)
        $wpf.TextBox_desc.Text = $desc
    }
})
