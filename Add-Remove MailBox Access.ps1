<#
Author - Deathjam
Edit Lines: 
24 - (365 password)
25 - (365 account)
55,97,137,165 - (path to scheduledtask files, what ever account runs the script will need write access)
71 - (365 password)
72 - (365 account)
113 - (365 password)
114 - (365 account)
150 - (Account to run scheduledtask currently set to domain\user)
154 - (WINDOWS PASSWORD for scheduledtask)
173 - (Account to run scheduledtask currently set to domain\user)
177 - (WINDOWS PASSWORD for scheduledtask)
227 - (365 email domain "*@DOMAIN.COM")

Function: Add/Remove access to mailbox based on scheduled tasks

#>

if (Get-Module -ListAvailable -Name MsOnline) {
	Set-ExecutionPolicy Unrestricted -force
##Set Credential
	$securepassword = ConvertTo-SecureString -string "365 PASSWORD" -AsPlainText -Force 
	$credential = new-object System.Management.Automation.PSCredential ("365 ACCOUNT", $securepassword)
##Connect to 365
	Import-Module MsOnline
	Connect-MsolService -Credential $credential
##Connect to Exchange
	$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
	Import-PSSession $exchangeSession -DisableNameChecking -AllowClobber
#

	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  

	$Form = New-Object System.Windows.Forms.Form    
	$Form.Size = New-Object System.Drawing.Size(710,400)  
	$Form.Text = "Mailbox Access" 

############################################## Start functions

#CreateschtaskFileStart
	function CreateschtaskFileStart {
		$Access=$AccessDropDownBox.SelectedItem.ToString()
		$User=$UserDropDownBox.SelectedItem.ToString()
		if ($RadioButton1.Checked -eq $true) {$Level='SendAs'}
		if ($RadioButton2.Checked -eq $true) {$Level='Send On Behalf'}
		if ($RadioButton3.Checked -eq $true) {$Level='FullAccess'}
		$cfalse = '-confirm:$False'

		$argsStart = " -Identity $Access -User $User -AccessRights $Level -InheritanceType All $cfalse" 

##PATH FOR schtask folder
		$schtaskpath = 'c:\schtask'
		$Startfile = "GiveAccess-$num.ps1"
		$Startfile2 = "DeleteTask_GiveAccess-$num.ps1"
		If (!(Test-Path $schtaskpath)) {
			New-Item -ItemType directory -Path $schtaskpath
		}
		If (Test-Path $schtaskpath\$Startfile -PathType Leaf) {
			del $schtaskpath\$Startfile
		}
		If (Test-Path $schtaskpath\$Startfile2 -PathType Leaf) {
			del $schtaskpath\$Startfile2
		}
		$CrLf = [char]13 + [char]10
		$args2 = "del $schtaskpath\$Startfile2"
		New-Item -Path $schtaskpath -Name $Startfile -Value '
##Set Credential
$securepassword = ConvertTo-SecureString -string "365 PASSWORD" -AsPlainText -Force
$credential = new-object System.Management.Automation.PSCredential ("365 ACCOUNT", $securepassword)
##Connect to 365
Import-Module MsOnline
Connect-MsolService -Credential $credential
##Connect to Exchange
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking -AllowClobber
Add-MailboxPermission' -ItemType file -force
		$argsStart | Out-File -FilePath $schtaskpath\$Startfile -Append -encoding ASCII
		New-Item -Path $schtaskpath -Name $Startfile2 -Value "Get-ScheduledTask -TaskName '$user Access Remove $num'| Unregister-ScheduledTask $cfalse" -ItemType file -force
		$CrLf | Out-File -FilePath $schtaskpath\$Startfile2 -Append -encoding ASCII
		$args2 | Out-File -FilePath $schtaskpath\$Startfile2 -Append -encoding ASCII
	}


#CreateschtaskFileRemove
	function CreateschtaskFileRemove  {
		$Access=$AccessDropDownBox.SelectedItem.ToString()
		$User=$UserDropDownBox.SelectedItem.ToString()
		if ($RadioButton1.Checked -eq $true) {$Level='SendAs'}
		if ($RadioButton2.Checked -eq $true) {$Level='Send On Behalf'}
		if ($RadioButton3.Checked -eq $true) {$Level='FullAccess'}
		$cfalse = '-confirm:$False'

		$args = " -Identity $Access -User $User -AccessRights $Level -InheritanceType All $cfalse" 
		$schtaskpath = 'c:\schtask'
		$file = "RemoveAccess-$num.ps1"
		$file2 = "DeleteTask_RemoveAccess-$num.ps1"
		If (!(Test-Path $schtaskpath)) {
			New-Item -ItemType directory -Path $schtaskpath
		}
		If (Test-Path $schtaskpath\$file -PathType Leaf) {
			del $schtaskpath\$file
		}
		If (Test-Path $schtaskpath\$file2 -PathType Leaf) {
			del $schtaskpath\$file2
		}
		$CrLf = [char]13 + [char]10
		$args2 = "del $schtaskpath\$file2"
		New-Item -Path $schtaskpath -Name $file -Value '
##Set Credential
$securepassword = ConvertTo-SecureString -string "365 PASSWORD" -AsPlainText -Force
$credential = new-object System.Management.Automation.PSCredential ("365 ACCOUNT", $securepassword)
##Connect to 365
Import-Module MsOnline
Connect-MsolService -Credential $credential
##Connect to Exchange
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking -AllowClobber
Remove-MailboxPermission' -ItemType file -force
		$args | Out-File -FilePath $schtaskpath\$file -Append -encoding ASCII
		New-Item -Path $schtaskpath -Name $file2 -Value "Get-ScheduledTask -TaskName '$user Access Remove $num'| Unregister-ScheduledTask $cfalse" -ItemType file -force
		$CrLf | Out-File -FilePath $schtaskpath\$file2 -Append -encoding ASCII
		$args2 | Out-File -FilePath $schtaskpath\$file2 -Append -encoding ASCII
	}
##

	function GiveAccess {
		$dateStart = $calendarstart.Value.ToShortDateString()
		$num = ""
		$rng = Get-Random -minimum 1 -maximum 999
		$num =$rng
		$User=$UserDropDownBox.SelectedItem.ToString()
		$Access=$AccessDropDownBox.SelectedItem.ToString()
		$User=$UserDropDownBox.SelectedItem.ToString()
		$schtaskpath = 'c:\schtask'
		$Startfile = "GiveAccess-$num.ps1"
		$Startfile2 = "DeleteTask_GiveAccess-$num.ps1"

		if ($RadioButton1.Checked -eq $true) {$Level='SendAs'}
		if ($RadioButton2.Checked -eq $true) {$Level='Send On Behalf'}
		if ($RadioButton3.Checked -eq $true) {$Level='FullAccess'}

		CreateschtaskFileStart

		$startdnt = $calendarstart.Value.Date.ToShortDateString() + ' ' + $timestart.Value.ToShortTimeString()

#Create scheduled task
		$stpStart = $env:USERDOMAIN + '\' + $env:USERNAME
$StaStart = New-ScheduledTaskAction "powershell.exe" -Argument $schtaskpath\$Startfile
$StaStart2 = New-ScheduledTaskAction "powershell.exe" -Argument $schtaskpath\$Startfile2
$SttStart = New-ScheduledTaskTrigger  -At $startdnt -Once
Register-ScheduledTask "$User Give Access $num" -user $stpStart -Password 'WINDOWS PASSWORD' -Action $StaStart,$StaStart2 -Trigger $SttStart 
$msgbox1=[System.Windows.Forms.Messagebox]::Show("Scheduled Task created to Give access on $startdnt" )
} 
##

function RemoveAccess  {
$date = $calendar.Value.ToShortDateString()
$num = ""
$rng = Get-Random -minimum 1 -maximum 999
$num =$rng
$User=$UserDropDownBox.SelectedItem.ToString()
$schtaskpath = 'c:\schtask'
$file = "RemoveAccess-$num.ps1"
$file2 = "DeleteTask-$num.ps1"

CreateschtaskFileRemove

$enddnt = $calendar.Value.Date.ToShortDateString() + ' ' + $timeend.Value.ToShortTimeString()
#Create scheduled task
$stp = $env:USERDOMAIN + '\' + $env:USERNAME
$Sta = New-ScheduledTaskAction "powershell.exe" -Argument $schtaskpath\$file
$Sta2 = New-ScheduledTaskAction "powershell.exe" -Argument $schtaskpath\$file2
$Stt = New-ScheduledTaskTrigger -Once -At $enddnt
Register-ScheduledTask "$user Access Remove $num" -user $stp -Password 'WINDOWS PASSWORD' -Action $Sta,$Sta2 -Trigger $Stt 
$msgbox1=[System.Windows.Forms.Messagebox]::Show("Scheduled Task created to remove access on $enddnt" )
						}


function GiveAccessNOW {
$Access=$AccessDropDownBox.SelectedItem.ToString()
$User=$UserDropDownBox.SelectedItem.ToString()


if ($RadioButton1.Checked -eq $true) {$Level='SendAs'}
if ($RadioButton2.Checked -eq $true) {$Level='Send On Behalf'}
if ($RadioButton3.Checked -eq $true) {$Level='FullAccess'}

Add-MailboxPermission -Identity $Access -User $User -AccessRights $Level -InheritanceType All
$msgbox=[System.Windows.Forms.Messagebox]::Show("Access Given, $Access to User $User with AccessRights $Level" )
					} 
#

############################################## end functions


############################################## Start text fields


$UserLabel = New-Object System.Windows.Forms.Label
$UserLabel.Location = New-Object System.Drawing.Size(20,22) 
$UserLabel.size = New-Object System.Drawing.Size(220,20) 
$UserLabel.text = "Email of the User who needs the Access:" 
$Form.Controls.Add($UserLabel) 

$UserDropDownBox = New-Object System.Windows.Forms.ComboBox 
$UserDropDownBox.Location = New-Object System.Drawing.Size(240,20) 
$UserDropDownBox.Size = New-Object System.Drawing.Size(280,30) 
$UserDropDownBox.DropDownHeight = 200 
$Form.Controls.Add($UserDropDownBox) 

$AccessLabel = New-Object System.Windows.Forms.Label
$AccessLabel.Location = New-Object System.Drawing.Size(20,82) 
$AccessLabel.size = New-Object System.Drawing.Size(220,30) 
$AccessLabel.text = "Email of the Mailbox the above is Accessing:" 
$Form.Controls.Add($AccessLabel) 

$AccessDropDownBox = New-Object System.Windows.Forms.ComboBox 
$AccessDropDownBox.Location = New-Object System.Drawing.Size(240,80) 
$AccessDropDownBox.Size = New-Object System.Drawing.Size(280,30) 
$AccessDropDownBox.DropDownHeight = 200 
$Form.Controls.Add($AccessDropDownBox) 

#Get Address list
$addressesList=@(Get-MsolUser -All | Where-Object { $_.UserPrincipalName -LIKE "*@DOMAIN.COM" } | Select-Object UserPrincipalName | sort-object UserPrincipalName| ForEach{ $_.UserPrincipalName })

#Put Lists into dropdowns
foreach ($addresses in $addressesList) {
					$UserDropDownBox.Items.Add($addresses)
							} 
foreach ($addresses2 in $addressesList) {
					$AccessDropDownBox.Items.Add($addresses2)
							} 


############################################## end text fields

############################################## Start group boxes

$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Location = New-Object System.Drawing.Size(550,10) 
$groupBox.size = New-Object System.Drawing.Size(130,100) 
$groupBox.text = "Access Level:" 
$Form.Controls.Add($groupBox) 

############################################## end group boxes


############################################## Start radio buttons

$RadioButton1 = New-Object System.Windows.Forms.RadioButton 
$RadioButton1.Location = new-object System.Drawing.Point(15,15) 
$RadioButton1.size = New-Object System.Drawing.Size(90,20) 
$RadioButton1.Text = "Send As" 
$groupBox.Controls.Add($RadioButton1) 

$RadioButton2 = New-Object System.Windows.Forms.RadioButton
$RadioButton2.Location = new-object System.Drawing.Point(15,45)
$RadioButton2.size = New-Object System.Drawing.Size(110,20)
$RadioButton2.Text = "Send On Behalf"
$groupBox.Controls.Add($RadioButton2)
##Above Not tested


$RadioButton3 = New-Object System.Windows.Forms.RadioButton
$RadioButton3.Location = new-object System.Drawing.Point(15,75)
$RadioButton3.size = New-Object System.Drawing.Size(90,20)
$RadioButton3.Checked = $true 
$RadioButton3.Text = "Full Access"
$groupBox.Controls.Add($RadioButton3)

############################################## end radio buttons

############################################## Start Remove via scheduled task text

$TaskLabel = New-Object System.Windows.Forms.Label
$TaskLabel.Location = New-Object System.Drawing.Size(150,300) 
$TaskLabel.size = New-Object System.Drawing.Size(220,70) 
$TaskLabel.text = "Clicking the Give/Remove Access Button will create a scheduled task to Give/Remove the Access on the Date and time Selected" 
$Form.Controls.Add($TaskLabel) 

############################################## End Remove via scheduled task text

############################################## Start buttons

$ButtonGive = New-Object System.Windows.Forms.Button 
$ButtonGive.Location = New-Object System.Drawing.Size(320,160) 
$ButtonGive.Size = New-Object System.Drawing.Size(225,30) 
$ButtonGive.Text = "Give Access via a Scheduled Task" 
$ButtonGive.Add_Click({GiveAccess}) 
$Form.Controls.Add($ButtonGive) 

$ButtonCheck = New-Object System.Windows.Forms.Button 
$ButtonCheck.Location = New-Object System.Drawing.Size(20,300) 
$ButtonCheck.Size = New-Object System.Drawing.Size(110,30) 
$ButtonCheck.Text = "Give Access NOW" 
$ButtonCheck.Add_Click({GiveAccessNOW}) 
$Form.Controls.Add($ButtonCheck) 

$ButtonRemove = New-Object System.Windows.Forms.Button 
$ButtonRemove.Location = New-Object System.Drawing.Size(320,240) 
$ButtonRemove.Size = New-Object System.Drawing.Size(225,30) 
$ButtonRemove.Text = "Remove Access via a Scheduled Task" 
$ButtonRemove.Add_Click({RemoveAccess}) 
$Form.Controls.Add($ButtonRemove)

############################################## end buttons


############################################## Start Date Picker start date

$DatePickerLabelstart = New-Object System.Windows.Forms.Label
$DatePickerLabelstart.Text = "Select Date and Time to Start the Access"
$DatePickerLabelstart.Location = New-Object System.Drawing.Size(20,145) 
$DatePickerLabelstart.size = New-Object System.Drawing.Size(220,20) 
$Form.Controls.Add($DatePickerLabelstart) 

$calendarstart = New-Object System.Windows.Forms.DateTimePicker
$calendarstart.Location = New-Object System.Drawing.Size(20,165)
$calendarstart.CustomFormat = "ddd dd/MM/yyyy"
$Form.Controls.Add($calendarstart)

$timestart = New-Object System.Windows.Forms.DateTimePicker
$timestart.CustomFormat = "h:mm tt"
$timestart.Format = 8
$timestart.ShowUpDown = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 77
$timestart.Size = $System_Drawing_Size
$timestart.Location = New-Object System.Drawing.Size(230,165)
$Form.Controls.Add($timestart)


############################################## End Date Picker start date

############################################## Start Date Picker end date

$DatePickerLabel = New-Object System.Windows.Forms.Label
$DatePickerLabel.Text = "Select Date and Time to Remove the Access"
$DatePickerLabel.Location = New-Object System.Drawing.Size(20,220) 
$DatePickerLabel.size = New-Object System.Drawing.Size(250,20) 
$Form.Controls.Add($DatePickerLabel) 

$calendar = New-Object System.Windows.Forms.DateTimePicker
$calendar.Location = New-Object System.Drawing.Size(20,245)
$calendar.CustomFormat = "ddd dd/MM/yyyy"

$Form.Controls.Add($calendar)

$timeend = New-Object System.Windows.Forms.DateTimePicker
$timeend.CustomFormat = "h:mm tt"
$timeend.Format = 8
$timeend.ShowUpDown = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 77
$timeend.Size = $System_Drawing_Size
$timeend.Location = New-Object System.Drawing.Size(230,245)
$Form.Controls.Add($timeend)


############################################## End Date Picker end date


$Form.Add_Shown({$Form.Activate()})
$result =  $Form.ShowDialog()



Remove-Module MsOnline
Remove-PSSession $exchangeSession

} else {
	Write-Host "======================================================="
	Write-Host "Module MsOnline does not exist"
	Write-Host ""
	Write-Host "Please install Before running script"
	Write-host "For Powershell See: https://technet.microsoft.com/en-gb/library/dn568015.aspx"
	Write-Host ""
	Write-Host "======================================================="	
}
