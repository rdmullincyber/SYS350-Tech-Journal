#Ryan Mullin 5-03-21
#Final Project
#In this assignment, I will be creating a PowerCLI Script that will be able to preform multiple tasks all from a single script.
Clear-host
#General Prompt
read-host -Prompt "Welcome to my PowerCLI Script, upon pressing enter we will progress to the rest of the script"

#Connecting to VI server
$title = "Connect to VI server"
$message = "Have you connected to your VI via PowerCLI?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Proceeds to the Main Menu of the Script."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Makes you input your VI server and Credentials."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {read-host -Prompt "You selected Yes. We will Proceed to the Main Menu of the Script now."}
        1 {Connect-VIServer}
    }

#Snapshot Capabilites 
function snapShot {
    # Clear the screen
    clear
    # Create our menus
    write-host "What do you want to do with Snapshots?"
    write-host "1. Create a New Snapshot"
    write-host "2. List Snapshots"
    write-host "3. Delete a Snapshot"
    write-host "[E]xit to Main Menu"
    
    # Prompt the user for a selection
    $user_select = read-host -Prompt "Please select one of the menu options above"
    # Process the user response
    if ($user_select -eq 1) {
        $vm = Read-Host -prompt "What VM do you want to use?"
    $name = Read-Host -prompt "What do you want to name your Snapshot?"
    New-Snapshot -vm $vm -name $name -confirm:$false -runasync:$true
    Read-Host -prompt "Your snapshot is being created asynchronously! Press enter to return to main menu"
    snapShot
        }
    
if ($user_select -eq 2) {
        $vm = Read-Host -prompt "What VM do you want to use?"
    $name = Read-Host -prompt "What Snapshot do you want to view?"
    Get-Snapshot -vm $vm -name $name | select *
    Read-Host -prompt "Here is your information! Press enter to return to main menu"
    snapShot
        }
if ($user_select -eq 3) {
        $vm = Read-Host -prompt "What VM do you want to use?"
    $name = Read-Host -prompt "What Snapshot do you want to delete?"
    Get-Snapshot -vm $vm -name $name | remove-snapshot -confirm:$false -runasync:$true
    Read-Host -prompt "Your snapshot is being deleted asynchronously! Press enter to return to main menu"
    snapShot
        }
    if ($user_select -eq "E") {
        mainMenu
        }
}

#Datastore Capabilites 
function dataStore {
    # Clear the screen
    clear
    # Create our menus
    write-host "What do you want to do with Datastores?"
    write-host "1. List all Datastores"
    write-host "2. List how much space VM's are taking up on a Specific Datastore"
    write-host "3. Export Datastore VM information"
    write-host "[E]xit to Main Menu"
    
    # Prompt the user for a selection
    $user_select = read-host -Prompt "Please select one of the menu options above"
    # Process the user response
    if ($user_select -eq 1) {
        Get-Datastore
	read-host -prompt "Press enter to return to Datastore Menu"
	dataStore
        }
    
if ($user_select -eq 2) {
    $Datastore = Read-Host -prompt "What Datastore do you want to use?"
    Get-Datastore -Name $Datastore | get-vm | select name,usedspacegb
    read-host -prompt "Press enter to return to Datastore Menu"
    dataStore
        }
if ($user_select -eq 3) {
        $Datastore = Read-Host -prompt "What Datastore do you want to use?"
    $Path = Read-Host -prompt "What and where do you want to put the CSV file, Example: /home/ryan/Desktop/test.csv!"
    write-host "Creating with all settings of your VMs"
    Get-Datastore -Name $Datastore | get-vm | Export-csv -path $Path -NoTypeInformation
    read-host -prompt "Press enter to return to Datastore Menu"
    dataStore
        }
    if ($user_select -eq "E") {
        mainMenu
        }
}

#Main Menu
function mainMenu {
    # Clear the screen
    clear
    # Create our menus
    write-host "Welcome! Please choose what you would like to do with your VI server below:"
    write-host "1. Grab all of the current VMs within the Environment."
    write-host "2. Go into the Snapshot Menu."
    write-host "3. Get Data Store Information."
    write-host "4. Deploy OVA."
    write-host "5. Full/Linked Clones."
    write-host "[E]xit"
    
    # Prompt the user for a selection
    $user_select = read-host -Prompt "Please select one of the menu options above"
    # Process the user response
    if ($user_select -eq 1) {
        Get-VM
    $title = "Export your running VMs"
    $message = "Do you want to export your VMs in your environment to a CVS file?"

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Proceeds to export your data into a CSV"

    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Brings you back to Main Menu"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result){
                0 {    $Path = Read-Host -prompt "What and where do you want to put the CSV file, Example: /home/ryan/Desktop/test.csv!"
                write-host "Creating with all settings of your VMs"
                Get-VM | Select Name, PowerState, NumCpu, MemoryGB, Id, Uid, NetworkAdapters, UsedSpaceGB, ProvisionedSpaceGB | Export-Csv -path $Path -NoTypeInformation
                mainMenu
            }
                1 {mainMenu}
            }

        }
    
if ($user_select -eq 2) {
    snapShot
        }
if ($user_select -eq 3) {
    dataStore
        }
if ($user_select -eq 4) {
    $ova = Read-Host -prompt "File path to OVA. Example /home/ryan/Downloads/Test.ova" 
    $vmhostq = Read-Host -Prompt 'What is your VMhost name'
    $vmhost = Get-VMHost -Name "$vmhostq"
    Get-Datastore
    $datastore = read-host -prompt "What datastore do you want to use"
    $folderq = Read-Host -Prompt 'What is your folder name'
    $folder = Get-Folder -Name "$folderq"
    $name = read-host -prompt "What do you want to name your VM"
    $vmhost | Import-vApp –Source $ova -Datastore $datastore -Name $name -Force
    Read-Host -prompt "Your OVA is being deployer! Press enter to return to main menu"
    mainMenu
        }
if ($user_select -eq 5) {
    Get-VM -Server $connection| Select-Object -Property Name,Notes,VMHost,Guest
    $basevmq = Read-Host -Prompt 'Which VM would you like to use'
    $basevm = Get-VM -Name "$basevmq"
    get-snapshot -vm $basevm
    $snapshotq = Read-Host -Prompt 'Which snapshot would you like to use'
    $snapshot = Get-Snapshot -VM $basevm -Name "$snapshotq"
    $vmhostq = Read-Host -Prompt 'What is your VMhost name'
    $vmhost = Get-VMHost -Name "$vmhostq"
    $dstoreq = Read-Host -Prompt 'What is your dstore name'
    $dstore = Get-Datastore -Name "$dstoreq"
    $folderq = Read-Host -Prompt 'What is your folder name'
    $folder = Get-Folder -Name "$folderq"
    $question = Read-Host -Prompt "Would you like to create a Full or Linked Clone? (F or L)"
    if ($question -eq 'L'){
    $newvmq = Read-Host -Prompt 'what do you want to name your new vm'
    $newvm = New-VM -Name "$newvmq" -VM $basevm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore -Location $folder
    read-host -prompt "Complete"
    }
    if ($question -eq 'F'){
    $newvmq = Read-Host -Prompt 'what do you want to name your new vm'
    $newvm = New-VM -Name "$newvmq.tmp" -VM $basevm -LinkedClone -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $dstore -Location $folder
    New-VM -Name "$newvmq" -VM $newvm -VMHost $vmhost -Datastore $dstore -Location $folder
    Remove-VM -VM "$newvmq.tmp" -DeletePermanently
    read-host -prompt "Complete"
    }






    mainMenu
}
    if ($user_select -eq "E") {
        exit
        }
}



mainMenu



