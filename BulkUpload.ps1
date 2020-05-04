$User = "jerry@zheguo.onmicrosoft.com"  
$Password = 'sisi@2018'  
$SiteURL = "https://zheguo.sharepoint.com"  
$Folder = "C:\Scripts\HpeQuota"  
#Path where you want to Copy  
$DocLibName = "Documents"  
#Docs library  
# Add references to SharePoint client assemblies and authenticate to Office 365 site - required  for CSOM  
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"  
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"  
#Bind to site collection  
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)  
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User, (ConvertTo-SecureString $Password -AsPlainText -Force))  
$Context.Credentials = $Creds  
#Retrieve list  
$List = $Context.Web.Lists.GetByTitle($DocLibName)  
$Context.Load($List) 
$context.Load($List.RootFolder.Folders); 
$Context.ExecuteQuery()  
# Upload file  
Foreach($File in (dir $Folder -File))  
{  
    $FileStream = New-Object IO.FileStream($File.FullName, [System.IO.FileMode]::Open)  
    $FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation  
    $FileCreationInfo.Overwrite = $true  
    $FileCreationInfo.ContentStream = $FileStream  
    $FileCreationInfo.URL = $File  
    $Upload = $List.RootFolder.Folders.GetByUrl("/Shared Documents/Cu folder").Files.Add($FileCreationInfo)  
    $Context.Load($Upload)  
    $Context.ExecuteQuery()  
}  