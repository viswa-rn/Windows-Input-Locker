##########################################################################################
### BEGIN: Prompt for Entering the password and initialize some vairables ################
##########################################################################################

$Host.UI.RawUI.ReadKey("IncludeKeyUp")
Write-Host "Enter the password"
$KeysDownAtTheMoment = New-Object System.Collections.Generic.HashSet[int]
$PasswordEntireStates = @()

##########################################################################################
### END: Prompt for Entering the password and initialize some vairables ##################
##########################################################################################


##########################################################################################
### BEGIN: Take the password which can be combination of many keys pressed simultaneously#
##########################################################################################
$FirstTime = $true
while ($true) {
    if(!$FirstTime -and $KeysDownAtTheMoment.Count -eq 0){
        break
    }
    $FirstTime = $false

    $key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyUp, IncludeKeyDown")
    if($key.KeyDown){
        if(!($KeysDownAtTheMoment.Contains($key.VirtualKeyCode))){
            $result = $KeysDownAtTheMoment.Add($key.VirtualKeyCode)
            $Temp = New-Object int[] $KeysDownAtTheMoment.Count 
            $KeysDownAtTheMoment.CopyTo($Temp)
            $PasswordEntireStates += , $Temp
        }
    }
    else{
        if($KeysDownAtTheMoment.Contains($key.VirtualKeyCode)){
            $result = $KeysDownAtTheMoment.Remove($key.VirtualKeyCode)
            $Temp = New-Object int[] $KeysDownAtTheMoment.Count 
            $KeysDownAtTheMoment.CopyTo($Temp)
            $PasswordEntireStates += , $Temp        }
        else{
            Write-Host "Something is terribly wrong"
        }
    }
}

##########################################################################################
### END: Take the password which can be combination of many keys pressed simultaneously ##
##########################################################################################

foreach($PasswordEntireState in $PasswordEntireStates){
    Write-Host "STATE" $PasswordEntireState
}


##########################################################################################
### BEGIN: Collect the states of the password from the passwordentirestates ##############
### The entries in password entire states can be either decreasing or increasing in ######
### terms of keys in pressed state: So these two cases are handled carefully #############
##########################################################################################

$PasswordFinalStates = @()
$CurrentPasswordState = @()
$counter = 0
while($counter -lt $PasswordEntireStates.Count){

    ### BEGIN: The scenario when the new keys are being pressed while keeping the already ####
    ### keydown keys intact ##################################################################

    $comparator = Compare-Object -ReferenceObject $PasswordEntireStates[$counter] -DifferenceObject $CurrentPasswordState | Where-Object {$_.SideIndicator -eq "<="} | % {$_.InputObject}
    $broken = $false
    while($comparator.Count -gt 0){
        $CurrentPasswordState = $PasswordEntireStates[$counter]
        $counter++
        if($counter -lt $PasswordEntireStates.Count){
            $comparator = Compare-Object -ReferenceObject $PasswordEntireStates[$counter] -DifferenceObject $CurrentPasswordState | Where-Object {$_.SideIndicator -eq "<="} | % {$_.InputObject}
        }
        else{
            $broken = $true
            break
        }
    }

    $PasswordFinalStates += , $CurrentPasswordState
    if($broken){
        break
    }
    ### END: The scenario when the new keys are being pressed while keeping the already ######
    ### keydown keys intact ##################################################################

    ### BEGIN: The scenario when the pressed keys are taken key up state one after the other #

    $comparator = Compare-Object -ReferenceObject $PasswordEntireStates[$counter] -DifferenceObject $CurrentPasswordState | Where-Object {$_.SideIndicator -eq "=>"} | % {$_.InputObject}
    while($comparator.Count -gt 0){
        $CurrentPasswordState = $PasswordEntireStates[$counter]
        $counter++
        if($counter -lt $PasswordEntireStates.Count){
            $comparator = Compare-Object -ReferenceObject $PasswordEntireStates[$counter] -DifferenceObject $CurrentPasswordState | Where-Object {$_.SideIndicator -eq "=>"} | % {$_.InputObject}
        }
        else{
            break
        }
    }
    $PasswordFinalStates += , $CurrentPasswordState
    ### END: The scenario when the pressed keys are taken key up state one after the other ###
}

# $PasswordFinalStates | Export-Csv .\password.csv

rm .\password.txt
foreach($PasswordFinalState in $PasswordFinalStates){
    $PasswordFinalState.Count | Out-File .\password.txt -Append
    $PasswordFinalState | Out-File password.txt -Append
}

##########################################################################################
### END: Collect the states of the password from the passwordentirestates ################
### The entries in password entire states can be either decreasing or increasing in ######
### terms of keys in pressed state: So these two cases are handled carefully #############
##########################################################################################

