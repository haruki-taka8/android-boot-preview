# Handles everything related to generating the preview
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
$wpf.Button_Generate.Add_Click({
    # TODO: Input validation
    Set-Progress 0 'Calculating helper variables'
    $ScreenW = $wpf.TextBox_ScreenW.Text
    $ScreenH = $wpf.TextBox_ScreenH.Text
    $OverlayX = ($ScreenW - $desc.Width) / 2
    $OverlayY = ($ScreenH - $desc.Height) / 2

    # Foreach part
    Set-Progress 33 'Generating animation per part'
    for ($i = 0; $i -lt $desc.Animation.Count; $i++) {
        # Generate .avi for part
        # Generate Animation
        '#' | Out-File $tempLocation\partList.txt -Encoding ASCII
        (Get-ChildItem "$tempLocation\part$i\*.png").FullName.ForEach({
            "file `'$_`'" | Out-File $tempLocation\partList.txt -Append -Encoding ASCII
        })

        & $ffmpegLocation `
            -r 1 `
            -f concat `
            -safe 0 `
            -i "$tempLocation\partList.txt" `
            -r $desc.FPS `
            "$tempLocation\part$($i)_front.avi"

        # Add blank background
        # idk why but it has to be 2*$desc.Animation[$i].PartTime
        & $ffmpegLocation `
            -f lavfi `
            -i color=black:s=$($ScreenW)x$($ScreenH) `
            -i "$tempLocation\part$($i)_front.avi" `
            -filter_complex "[0:v][1:v] overlay=$($OverlayX):$($OverlayY)" `
            -t (2*$desc.Animation[$i].PartTime) `
            -r $desc.FPS `
            "$tempLocation\part$($i).avi"
    }

    # Merge all
    # Generate list of files to merge
    Set-Progress 66 'Merging animations'
    [System.Collections.ArrayList] $Part = @()
    $desc.Animation.ForEach({
        if ($_.Repeat -eq 0) {
            $RequiredRepeat = $wpf.TextBox_Repeat.Text
        } else {
            $RequiredRepeat = $_.Repeat
        }
        for ($i = 0; $i -lt $RequiredRepeat; $i++) {
            $Part.Add($_)
        }
    })

    '#' | Out-File $tempLocation\partList.txt -Encoding ASCII
    $Part.Path.ForEach({
        "file `'$tempLocation\$_.avi`'" | Out-File $tempLocation\partList.txt -Append -Encoding ASCII
    })

    # The moment of truth: combine everything
    & $ffmpegLocation `
            -f concat `
            -safe 0 `
            -i "$tempLocation\partList.txt" `
            "$tempLocation\result.avi"

    Set-Progress 100 'Generation done'
})

# D:\Themes\Mass Android Theming\E257\bootanimation