# Handles everything related to previewing the animation
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function Set-PreviewBackground {
    $ScreenRatio = $wpf.TextBox_ScreenWidth.Text / $wpf.TextBox_ScreenHeight.Text
    $wpf.Grid_PreviewBackground.Height = $wpf.Grid_PreviewBackground.ActualWidth / $ScreenRatio
    $wpf.Image_Preview.Width = $wpf.Grid_PreviewBackground.ActualWidth * ($desc.Width / $wpf.TextBox_ScreenWidth.Text)
    
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
    $k = 0
    # Foreach part
    for ($i = 0; $i -le $desc.Animation.Count-1; $i++) {
        $wpf.TextBlock_Part.Text = $i
        
        # Repeat part if needed
        $RepeatCount = $desc.Animation[$i].Repeat-1
        if ($RepeatCount -lt 0) {
            if ($wpf.TextBox_RepeatWhen0.Text -match '^\d$') {
                $RepeatCount = [Int] ($wpf.TextBox_RepeatWhen0.Text)-1
            } else {
                $wpf.TextBox_RepeatWhen0.Text = 2
                $RepeatCount = 2
            }
        }
        for ($j = 0; $j -le $RepeatCount; $j++) {
            
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
