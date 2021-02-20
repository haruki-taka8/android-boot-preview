# Handles everything related to generating the preview
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
$wpf.Button_Generate.Add_Click({
    # TODO: Input validation
    Set-Progress 0 'Calculating helper variables'
    $ScreenW = $wpf.TextBox_ScreenW.Text
    $ScreenH = $wpf.TextBox_ScreenH.Text
    $OverlayX = ($ScreenW - $desc.Width) / 2
    $OverlayY = ($ScreenH - $desc.Height) / 2

    # Generate animation per line
    $script:i = 0
    $desc.Animation.ForEach({
        Set-Progress (100*($i+1)/($desc.Animation.Count+2)) 'Generating animation per part'

        # Generate overlay
        '#' | Out-File $tempLocation\partList.txt -Encoding ASCII
        (Get-ChildItem "$tempLocation\$($_.Path)\*.png").FullName.ForEach({
            "file `'$_`'" | Out-File $tempLocation\partList.txt -Append -Encoding ASCII
        })

        & $ffmpegLocation `
            -f concat `
            -safe 0 `
            -r $desc.FPS `
            -i "$tempLocation\partList.txt" `
            -r $desc.FPS `
            "$tempLocation\$($i)_front.avi"

        # Process REPEAT
        $RequiredRepeat = $desc.Animation[$i].Repeat
        if ($RequiredRepeat -eq 0) {
            $RequiredRepeat = $wpf.TextBox_Repeat.Text
        }

        Clear-Content $tempLocation\partList.txt
        for ($j = 0; $j -lt $RequiredRepeat; $j++) {
            "file `'$tempLocation\$($i)_front.avi`'" | Out-File $tempLocation\partList.txt -Append -Encoding ASCII
        }

        & $ffmpegLocation `
            -f concat `
            -safe 0 `
            -i "$tempLocation\partList.txt" `
            "$tempLocation\$($i)_front_2.avi"

        # Append overlay to background
        if ($null -eq $desc.Animation[$i].RGBHex[0]) {
            $script:RequiredColor = '#000000'
        } else {
            $script:RequiredColor = $desc.Animation[$i].RGBHex[0]
        }

        # Set Animation.FullTime (include PAUSE & REPEAT)
        $desc.Animation[$i].FullTime = $desc.Animation[$i].PartTime*$RequiredRepeat +$desc.Animation[$i].Pause/$desc.FPS 

        & $ffmpegLocation `
            -f lavfi `
            -i color=$($RequiredColor):s=$($ScreenW)x$($ScreenH) `
            -i "$tempLocation\$($i)_front_2.avi" `
            -filter_complex "[0:v][1:v] overlay=$($OverlayX):$($OverlayY)" `
            -t $desc.Animation[$i].FullTime `
            "$tempLocation\$($i).avi"

        # Remove unused $i_front_*.avi
        Remove-Item "$TempLocation\$($i)_front*.avi" -Force
        $i++
    })

    # Process BOOTTIME
    $script:CurrentPosition = 0 # ms
    $script:PreviousPosition = 0 # ms
    $script:Cutoff = 0
    $script:i = 0

    $desc.Animation.ForEach({
        $CurrentPosition += $desc.Animation[$i].FullTime*1000 # ms

        if ($CurrentPosition -gt $wpf.TextBox_Boot.Text) {

            if (($desc.Animation[$i].Type -ieq 'c') -and ($desc.Animation[$i].Repeat -eq 0)) {
                # Process Infinite C loop
                $script:Cutoff = [Math]::Round(($wpf.TextBox_Boot.Text - $PreviousPosition) / ($desc.Animation[$i].PartTime*1000)) * $desc.Animation[$i].PartTime*1000
                $script:Cutoff = [Math]::Max(0, $Cutoff)
                $script:Cutoff = [Timespan]::FromMilliseconds($CutOff).ToString('hh\:mm\:ss\.ff')

                & $ffmpegLocation `
                    -i "$tempLocation\$($i).avi" `
                    -ss '00:00:00' `
                    -to $CutOff `
                    -c copy `
                    "$tempLocation\$($i)_2.avi"

                Copy-Item "$tempLocation\$($i)_2.avi" "$tempLocation\$($i).avi" -Force
                Remove-Item "$tempLocation\$($i)_2.avi" -Force

            } elseif ($desc.Animation[$i].Type -ieq 'p') {
                # Process P loop
                $script:Cutoff = [Math]::Max(0, $wpf.TextBox_Boot.Text - $PreviousPosition)
                $script:Cutoff = [Timespan]::FromMilliseconds($CutOff).ToString('hh\:mm\:ss\:ff')

                & $ffmpegLocation `
                    -i "$tempLocation\$($i).avi" `
                    -ss '00:00:00' `
                    -to $CutOff `
                    -c copy `
                    "$tempLocation\$($i)_2.avi"

                Copy-Item "$tempLocation\$($i)_2.avi" "$tempLocation\$($i).avi" -Force
                Remove-Item "$tempLocation\$($i)_2.avi" -Force
            }
        }

        $PreviousPosition += $desc.Animation[$i].FullTime*1000 # ms
        $i++
    })

    # Slow down
    # Look at the time up on the wall
    # The clock is tellin' it all wrong
    # You got to slow down
    Start-Sleep 2

    # Combine each part
    Clear-Content $tempLocation\partList.txt
    (Get-ChildItem "$tempLocation\*.avi").FullName.ForEach({
        "file `'$_`'" | Out-File $tempLocation\partList.txt -Append -Encoding ASCII
    })

    & $ffmpegLocation `
            -f concat `
            -safe 0 `
            -i "$tempLocation\partList.txt" `
            "$tempLocation\result.avi"

    Set-Progress 100 'Generation done'
})
# D:\Themes\Mass Android Theming\E257\bootanimation
