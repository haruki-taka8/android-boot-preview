# Handles everything related to generating the preview
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
function New-Preview {
    param (
        [Parameter(Mandatory)][Int] $ScreenW,
        [Parameter(Mandatory)][Int] $ScreenH,
        [Parameter(Mandatory)][Int] $BootTime,
        [Parameter(Mandatory)][Int] $RepeatCount
    )

    # Generate animation per line
    # Generated files
    # 0         = completed version of part
    # 0_front   = unscaled part
    # 0_front_2 = unscaled, repeated part

    $OverlayX = ($ScreenW - $desc.Width) / 2
    $OverlayY = ($ScreenH - $desc.Height) / 2
    $i = 0
    $desc.Animation.ForEach({
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
        $RequiredRepeat = $_.Repeat
        if ($RequiredRepeat -eq 0) {
            $RequiredRepeat = $RepeatCount
        }

        # Set Animation.FullTime (include PAUSE & REPEAT)
        $_.FullTime = $_.PartTime*$RequiredRepeat + $_.Pause/$desc.FPS 

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
        if ($null -eq $_.RGBHex[0]) {
            $RequiredColor = '#000000'
        } else {
            $RequiredColor = $_.RGBHex[0]
        }

        & $ffmpegLocation `
            -f lavfi `
            -i color=$($RequiredColor):s=$($ScreenW)x$($ScreenH) `
            -i "$tempLocation\$($i)_front_2.avi" `
            -filter_complex "[0:v][1:v] overlay=$($OverlayX):$($OverlayY)" `
            -t $_.FullTime `
            "$tempLocation\$($i).avi"

        # Remove unused $i_front_*.avi
        Remove-Item "$TempLocation\$($i)_front*.avi" -Force
        $i++
    })

    # Process BOOTTIME
    $PreviousPosition = $i = 0

    $desc.Animation.ForEach({
        if (($PreviousPosition + $_.FullTime*1000) -gt $BootTime) {
            $ToCut = $false
            if (($_.Type -ieq 'c') -and ($_.Repeat -eq 0)) {
                # Infinite C loop: round to nearest PartTime
                $Cutoff = [Math]::Round(($BootTime - $PreviousPosition) / ($_.PartTime*1000)) * $_.PartTime*1000
                $ToCut  = $true
            } elseif ($_.Type -ieq 'p') {
                # P loop
                $Cutoff = $BootTime - $PreviousPosition
                $ToCut  = $true
            }
            if ($ToCut) {
                if ($CutOff -gt 0) {
                    $Cutoff = [Timespan]::FromMilliseconds($CutOff).ToString('hh\:mm\:ss\.ff')
                    & $ffmpegLocation `
                        -i "$tempLocation\$($i).avi" `
                        -ss '00:00:00.00' `
                        -to $CutOff `
                        -c copy `
                        "$tempLocation\$($i)_2.avi" | Out-Null

                    Remove-Item "$tempLocation\$($i).avi" -Force
                    Rename-Item "$tempLocation\$($i)_2.avi" "$($i).avi" -Force
                } else {
                    Remove-Item "$tempLocation\$($i).avi" -Force
                }
            }
        }
        $PreviousPosition += $_.FullTime*1000 # ms
        $i++
    })

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
}
