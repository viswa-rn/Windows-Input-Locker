$EnterKey = $Host.UI.RawUI.ReadKey("IncludeKeyUp")
Write-Host "Enter the password"
$KeysDownAtTheMoment = New-Object System.Collections.Generic.HashSet[int]
$Password = @()


$FirstTime = $true
while ($true) {
    if(!$FirstTime -and $KeysDownAtTheMoment.Count -eq 0){
        break
    }
    $FirstTime = $false

    $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyUp, IncludeKeyDown")
    if($key.KeyDown){
        Write-Host $key
        if(!($KeysDownAtTheMoment.Contains($key.VirtualKeyCode))){
            $KeysDownAtTheMoment.Add($key.VirtualKeyCode)
            $Password += $KeysDownAtTheMoment
        }
    }
    else{
        Write-Host $key
        if($KeysDownAtTheMoment.Contains($key.VirtualKeyCode)){
            $KeysDownAtTheMoment.Remove($key.VirtualKeyCode)
            $Password += $KeysDownAtTheMoment

        }
        else{
            Write-Host "Something is terribly wrong"
        }
    }
    foreach($keydown in $KeysDownAtTheMoment){
        Write-Host $keydown
    }
}

# $key = $Host.UI.RawUI.ReadKey("IncludeKeyDown, IncludeKeyUp")
# $key