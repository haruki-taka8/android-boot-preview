# Handles everything related to playing the generated preview
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
$wpf.Button_Play.Add_Click({
    $wpf.Media_Preview.LoadedBehavior = "Manual"
    $wpf.Media_Preview.UnloadedBehavior = "Manual"
    $wpf.Media_Preview.Source = "$TempLocation\result.avi"
    $wpf.Media_Preview.Play()
})
