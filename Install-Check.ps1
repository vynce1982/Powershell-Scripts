Function Install-Check 
{
    if (!(Get-Module -ListAvailable -Name MSOnline) -or !(Get-Module -ListAvailable -Name SkypeOnlineConnector) -or !(Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell) ) 
    {
        $a = New-Object -ComObject wscript.shell 
        $intAnswer = $a.popup('Office 365 powershell module not detected. Install Now?', `
        0,'Pre run Check...',4) 
        If ($intAnswer -eq 6) 
        {
            New-Item -Path 'c:\temp\MSO_PS' -ItemType Directory -Force
            Import-Module -Name BitsTransfer
            $src_msonline = 'https://download.microsoft.com/download/5/0/1/5017D39B-8E29-48C8-91A8-8D0E4968E6D4/en/msoidcli_64.msi'
            $src_azure = 'https://bposast.vo.msecnd.net/MSOPMW/Current/amd64/AdministrationConfig-en.msi'
            $src_spo = 'https://download.microsoft.com/download/0/2/E/02E7E5BA-2190-44A8-B407-BC73CA0D6B87/sharepointonlinemanagementshell_4727-1200_x64_en-us.msi'
            $src_spoClient = 'https://download.microsoft.com/download/B/3/D/B3DA6839-B852-41B3-A9DF-0AFA926242F2/sharepointclientcomponents_16-4002-1211_x64-en-us.msi'
            $src_skype = 'https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowershell.exe'            
            $destination = 'c:\temp\MSO_PS'
            $msiArgumentList = '/quiet /qr /norestart IAGREE=Yes'
            Start-BitsTransfer -Source $src_msonline -Destination $destination
            Start-BitsTransfer -Source $src_azure -Destination $destination
            Start-BitsTransfer -Source $src_spo -Destination $destination
            Start-BitsTransfer -Source $src_spoClient -Destination $destination
            Start-BitsTransfer -Source $src_skype -Destination $destination
            Start-Process -FilePath $destination\msoidcli_64.msi -ArgumentList $msiArgumentList -Wait
            Start-Process -FilePath $destination\AdministrationConfig-en.msi -ArgumentList $msiArgumentList -Wait 
            Start-Process -FilePath $destination\sharepointonlinemanagementshell_4727-1200_x64_en-us.msi -ArgumentList $msiArgumentList -Wait 
            Start-Process -FilePath $destination\sharepointclientcomponents_16-4002-1211_x64-en-us.msi -ArgumentList $msiArgumentList -Wait
            Start-Process -FilePath $destination\SkypeOnlinePowershell.exe -ArgumentList '/quiet /NoRestart' -Wait
            Remove-Item C:\temp\MSO_PS -Recurse
        } 
    }  
}

Install-Check
