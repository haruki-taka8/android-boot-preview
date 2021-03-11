# Handles everything related to loading in bootanimation.zip
#—————————————————————————————————————————————————————————————————————————————+—————————————————————# Import file
function Import-BootAnimation {
    param (
        [Parameter()][String] $ZipLocation,
        [Parameter()][String] $FolderLocation
    )

    if (Test-Path $tempLocation) {Remove-Item $tempLocation -Recurse -Force}

    # I hate Test-Path because it makes r/badcode.
    if (($ZipLocation -ne '') -and (Test-Path $ZipLocation)) {
        Expand-Archive $ZipLocation $tempLocation -Force

    } elseif (($FolderLocation -ne '') -and (Test-path $FolderLocaion)) {
        Copy-Item $FolderLocation $tempLocation -Recurse
    }

    if (Test-Path "$tempLocation\desc.txt") {
        <# Populate $desc with data from desc.txt
            .Width    .Height    .FPS
            .Animation
                .Type    .Count    .Pause    .Path    .[#RGBHex]
                .PartTime <- Duration w/o Pause (s)
                .FullTime <- Duration w/ Repeat & Pause (s)
        #>
        $script:desc = [PSCustomObject] @{}
        $FirstLine = (Get-Content $tempLocation\desc.txt -First 1).Split(' ')
        $desc | Add-Member NoteProperty Width  $FirstLine[0]
        $desc | Add-Member NoteProperty Height $FirstLine[1]
        $desc | Add-Member NoteProperty FPS    $FirstLine[2]
        $desc | Add-Member NoteProperty Animation ([System.Collections.ArrayList] @())

        (Get-Content $tempLocation\desc.txt | Select-Object -Skip 1).ForEach({
            $ThisLine = $_.Split(' ')

            $desc.Animation.Add([PSCustomObject] @{
                Type     = $ThisLine[0]
                Repeat   = $ThisLine[1]
                Pause    = $ThisLine[2]
                Path     = $ThisLine[3]
                RGBHex   = $ThisLine.Where{$_[0] -eq '#'}
                PartTime = (Get-ChildItem "$tempLocation\$($ThisLine[3])\").Count / $desc.FPS
                FullTime = 0
            })
        })

    }
}
