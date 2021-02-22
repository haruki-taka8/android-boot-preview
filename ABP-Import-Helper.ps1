# 0 = $tempLocation
# 1 = $File
# 2 = $Folder

if (Test-Path $args[0]) {
    Remove-Item $args[0] -Recurse -Force
}

if (($args[1] -ne '') -and (Test-Path $args[1])) {
    # Extract .zip
    Expand-Archive $args[1] $args[0] -Force

} elseif (($args[2] -ne '') -and (Test-Path $args[2])) {
    # Extract folder
    Copy-Item $args[2] $args[0] -Recurse
}

'' | Set-Content "$($args[0])\import.dat"
