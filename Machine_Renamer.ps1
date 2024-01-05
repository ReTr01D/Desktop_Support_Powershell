Function Check-RunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!"
  }
  else
    {
       #Create a new Elevated process to Start PowerShell
       $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
       # Specify the current script path and name as a parameter
       $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
       #Set the Process to elevated
       $ElevatedProcess.Verb = "runas"
 
       #Start the new elevated process
       [System.Diagnostics.Process]::Start($ElevatedProcess)
 
       #Exit from the current, unelevated, process
       Exit
 
    }
}

#Check Script is running with Elevated Privileges
Check-RunAsAdministrator


Write-Host " __  __         _    _                                             " -ForegroundColor Green
Write-Host "|  \/  |__ _ __| |_ (_)_ _  ___   _ _ ___ _ _  __ _ _ __  ___ _ _  " -ForegroundColor Green
Write-Host "| |\/| / _` / _| ' \| | ' \/ -_) | '_/ -_) '  \/ _` | '  \/ -_) '_| " -ForegroundColor Green
Write-Host "|_|  |_\__,_\__|_||_|_|_||_\___| |_| \___|_||_\__,_|_|_|_\___|_|   " -ForegroundColor Green
Write-Host "                                               NYC Edition" -ForegroundColor White
Write-Host "       by ReTr01D" -ForegroundColor Red

$repeat=$true

while ($repeat){
$currentName= hostname

echo "`nYou are about to rename $currentName"

$SerialNumber = Get-WMIObject -Class "Win32_BIOS" | Select -Expand SerialNumber

function LT-DT{

    $LTorDT = Read-Host -Prompt "`nAre you renaming a laptop or desktop?
    1 - Desktop
    2 - Laptop
    
    "

    Switch ($LTorDT) {
    1 {$choice = "DT"}
    2 {$choice = "LT"}
    }
    return $choice
    }

$LapORDT= LT-DT

# After each dash you can add the name of the location or reference that will be used as a prefix, this can be shortened to one option
function Get-Location {
    $locSelect= Read-Host -Prompt "`nSelect the location 
    Manhattan:
    1 - 
    2 - 
    3 - 
    4 -
    5 -

    Type the number"

    # Add prefixes before "$LapORDT" if you want or remove the "#PutSomePrefix#"
    # These options refere to the options above, can also be shortened
    Switch ($locSelect){
    1 {$officeloc="#PutSomePrefix#$LapORDT"}
    2 {$officeloc="#PutSomePrefix#$LapORDT"}
    3 {$officeloc="#PutSomePrefix#$LapORDT"}
    4 {$officeloc="#PutSomePrefix#$LapORDT"}
    5 {$officeloc="#PutSomePrefix#$LapORDT"} 
    
    }
    return $officeloc
}

$location = Get-Location

Function customName {
  $custom = Read-Host -Prompt "`nKeep Serial number or Custom name?
  
  1 - Serial Number
  2 - Custom Name
  
  "

  Switch ($custom) {
  1 {$SNorCustom = "$SerialNumber"}
  2 {$SNorCustom = Read-Host -Prompt "Type the custom name (7 Chatacters Max)"}
  }
  return $SNorCustom
}

$NameChoice = customName


$NewName= "$location-$NameChoice"

echo "`nNew hostname will be $NewName"


$Question= Read-Host -Prompt "`nIs this correct? (Y/N)"

if ($Question -eq "N" -or $Question -eq "No")
                            {

                                #Outputs a string in the console 
                                echo "Let's try again"
                    
                                #sets the $repeat variable to false, this will stop the script from repeating
                                $repeat=$true
                            }

                            #else if input equals to Y or Yes 
                            elseif ($Question -eq "Y" -or $Question -eq "Yes")
                            {
                                #sets the $repeat variable to true, making the script repeat 
                                $repeat=$false
                            }

}


echo "Great!! Let's rename the machine"

echo "Please type your username after domain name\"
# Make sure to change  domain\ to the appropriate domain in your organization
Rename-Computer -ComputerName . -NewName "$NewName" -Force -Confirm -DomainCredential (Get-Credential -Credential domain\)

Read-Host -Prompt "Press Enter to exit"
