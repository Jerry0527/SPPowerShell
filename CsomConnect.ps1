Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

$userName = "jerry@zheguo.onmicrosoft.com"
$password = ConvertTo-SecureString "sisi@2018" -AsPlainText -Force

$webURL="https://zheguo.sharepoint.com/sites/dev/"
$Context=New-Object Microsoft.SharePoint.Client.ClientContext($webURL)
$Context.Credentials=New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username,$password)
$Web=$context.Web
$Context.Load($web)
$Context.executeQuery()
Write-host $Web.URL