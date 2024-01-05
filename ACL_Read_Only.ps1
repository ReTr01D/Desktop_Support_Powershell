


function SingleBatch {

    $SingleBatch = Read-Host -Prompt "`nAre you changing permissions for one or multiple files or folders??
    1 - Single
    2 - Batch
    "

    Switch ($SingleBatch) {
    1 {$choice = "Single"}
    2 {$choice = "Batch"}
  
    }
    return $choice
    }

$BatchFunct = SingleBatch


if ($BatchFunct -eq "Single")
    {# Ceck if File or Folder 
function File-Folder{

    $File0rFolder = Read-Host -Prompt "`nAre you changing permissions for file or folder??
    1 - File
    2 - Folder
    3 - Custom Path
    "

    Switch ($File0rFolder) {
    1 {$choice = "File"}
    2 {$choice = "Folder"}
    3 {$choice = "Custom Path"}

    }
    return $choice
    }

$FileChFunct= File-Folder

#Select if File or Folder or custom path 
if ($FileChFunct -eq "File" )
    {Add-Type -AssemblyName System.Windows.Forms
     $browser = New-Object System.Windows.Forms.OpenFileDialog  -Property @{ InitialDirectory = "./" }

     # Source folder Dialog Box 
     $browser.Title = "Select file to change ACL"
     $null2 = $browser.ShowDialog()
     $Folder = $browser.FileName

     }

     elseif ($FileChFunct -eq "Folder" )
     {Add-Type -AssemblyName System.Windows.Forms
      $browser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{ SelectedPath = 'C:\’}

      # Source folder Dialog Box 
      $browser.Description = "Select folder to change ACL"
      $null2 = $browser.ShowDialog()
      $Folder = $browser.SelectedPath
      }

      elseif ($FileChFunct -eq "Custom Path" )
      {$Folder = Read-Host -Prompt "`nType the custom path"}

      Write-Host "This is ACL for $Folder`n"


(Get-ACL -Path $Folder ).Access | Format-Table -Autosize



 
    


$identity = Read-Host -Prompt "`nType the domain\username"
$rights = 'Read' 
$inheritance = 'ContainerInherit, ObjectInherit' 
$propagation = 'None' 
$type = 'Allow'

$ACE2 = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation, $type)

$Acl=Get-ACL -Path $Folder

$Ace = $Acl.Access | Where-Object {($_.IdentityReference -eq $identity) -and -not ($_.IsInherited)}

$Acl.RemoveAccessRule($Ace)

$Acl.AddAccessRule($ACE2)

Set-Acl -Path $Folder -AclObject $Acl

(Get-ACL -Path $Folder ).Access | Format-Table -Autosize

pause

}



      # Works only if it is a Batch ACL change and will pull the CSV from the same location the PS1 file is run from
      elseif ($BatchFunct -eq "Batch" )
      #Imports and reads csv for the Folder path
      {$CSV = @(Import-Csv .\UserandFolder.csv -Header "FOLDER" , "USER" | ForEach-Object {$($_.FOLDER)})

        #Imports and reads csv for the User
       $identityMain = @(Import-Csv .\UserandFolder.csv -Header "FOLDER" , "USER" | ForEach-Object {$($_.USER)})

       #Needed to go by each user 1 by 1 relating to the folder 
       $x = 0

      foreach ($Folder in $CSV)
      {
        # Selects only one user from the list, next one each time
        $identity = $identityMain[$x]

        #Shows Which folder you are changing the ACL for
        Write-Host "This is ACL for $Folder`n"
        
        #Parameters of the Read Only rule
        $rights = 'Read' 
        $inheritance = 'ContainerInherit, ObjectInherit' 
        $propagation = 'None' 
        $type = 'Allow' 

        #Gets Permissions
        $Acl=Get-ACL -Path $Folder

        #Creates a permission rule same as the permissions
        $Ace = $Ace = $Acl.Access | Where-Object {($_.IdentityReference -eq $identity) -and -not ($_.IsInherited)}

        #Removes the permission rule hence removes permissions
        $Acl.RemoveAccessRule($Ace)

        #Creates a new permission rule with Read Only
        $ACE2 = New-Object System.Security.AccessControl.FileSystemAccessRule(@($identity),$rights,$inheritance,$propagation, $type)

        #Adds the permission Rule 
        $Acl.AddAccessRule($ACE2)

        #Sets the permission Rule 
        Set-Acl -Path $Folder -AclObject $Acl
        
        #Shows new ACL for each folder
        (Get-ACL -Path $Folder ).Access | Format-Table -Autosize

        #Increments the value so the next folder will correspond to correlated user
        $x++
     
      
      }

      pause 
      }
