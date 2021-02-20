# Handles everything related to playing the generated preview
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
$wpf.Button_Play.Add_Click({
    $wpf.Media_Preivew.LoadedBehavior = "Manual"
    $wpf.Media_Preivew.UnloadedBehavior = "Manual"
    $wpf.Media_Preview.Source = "$TempLocation\result.avi"
    $wpf.Media_Preview.Play()
})
