#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

#Function to Move a File
Function Move-SPOFile([String]$SiteURL, [String]$SourceFileURL, [String]$TargetFileURL)
{
    Try{
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
        $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
      
        #sharepoint online powershell to move files
        #New-Item -ItemType File -Path $TargetFileURL -Force
        $MoveCopyOpt = New-Object Microsoft.SharePoint.Client.MoveCopyOptions
        $Overwrite = $True
        [Microsoft.SharePoint.Client.MoveCopyUtil]::MoveFile($Ctx, $SourceFileURL, $TargetFileURL, $Overwrite, $MoveCopyOpt)
        $Ctx.ExecuteQuery()
        Write-host -f Green "Files Moved Successfully! "
    }
    Catch {
    write-host -f Red "Error Moving the File!" $_.Exception.Message
    Write-host -f Yellow "Files are failed to moved"
    }
}

Function Delete-Folder([String]$SiteURL, [String]$FolderUrl)
{
    Try{
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
        $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
        $Web = $Ctx.Web
 
        #Get the folder object from given URL
        $Folder=$web.GetFolderByServerRelativeUrl($FolderURL)
         
        #Delete the folder
        $Folder.DeleteObject()
        $Ctx.ExecuteQuery()
     
        Write-host "Folder deleted Successfully!" -ForegroundColor Green
    }
    Catch {
        write-host -f Red "Error deleting Folder!" $_.Exception.Message
    }
}

#Set Config Parameters
$SiteURL="https://zheguo.sharepoint.com"
  
#Get Credentials to connect
$Cred= Get-Credential
$folderData = Import-CSV -path D:\FolderList.csv

foreach ($row in $folderData) 
{
$FolderUrl = $row.FolderUrl
Write-host "FolderUrl: "$FolderUrl
  
  #Call the function to Delete the Folder
  Delete-Folder $SiteURL $FolderUrl
}