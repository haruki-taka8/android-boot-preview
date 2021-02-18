# Handles everything related to previewing the animation
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Set-PreviewBackground {
    $ScreenRatio = $wpf.TextBox_ScreenWidth.Text / $wpf.TextBox_ScreenHeight.Text
    $wpf.Grid_PreviewBackground.Height = $wpf.Grid_PreviewBackground.ActualWidth / $ScreenRatio
}

function Update-GUI {
    $wpf.ABP.Dispatcher.Invoke("Render",[action][scriptblock]{})
}

$wpf.Button_Update.Add_Click({
    if (($wpf.TextBox_ScreenWidth.Text -match '^\d+$') -and
        ($wpf.TextBox_ScreenWidth.Text -match '^\d+$')) 
    {Set-PreviewBackground}
})

$wpf.ABP.Add_SizeChanged({Set-PreviewBackground})

$wpf.Button_Play.Add_Click({
    # Set image size
    $wpf.Image_Preview.Width = $wpf.Grid_PreviewBackground.ActualWidth * ($desc.Width / $wpf.TextBox_ScreenWidth.Text)
    $k = 0

    # Foreach part
    for ($i = 0; $i -le $desc.Animation.Count-1; $i++) {
        $wpf.TextBlock_Part.Text = $i
        
        # Repeat part if needed
        for ($j = 0; $j -le $desc.Animation[$i].Repeat-1; $j++) {
            
            # Foreach frame
            (Get-ChildItem "$TempZip\part$i\*.png").FullName.ForEach({
                $wpf.Image_Preview.Source = $_
                $wpf.TextBlock_Frame.text = $k
                Update-GUI
                Start-Sleep -Milliseconds $desc.Interval
                ++ $k
            })
        }
    }
})
