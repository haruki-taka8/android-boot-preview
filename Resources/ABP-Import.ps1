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

        # Identify content
        if (Test-Path "$TempZip\desc.txt") {
            $wpf.TextBlock_Status.Text = 'desc.txt: Exist'
        } else {
            $wpf.TextBlock_Status.Text = 'desc.txt: Missing'
        }

        $wpf.TextBlock_Status.Text += "`nParts: " +
                                      (Get-ChildItem $TempZip Part*).Count
    }
})