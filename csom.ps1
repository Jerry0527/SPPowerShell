#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
   
#Set Variables for Site URL, Library Name and Item ID
$SiteURL= "https://zheguo.sharepoint.com/"
$LibraryName="Documents"
$OldString="National"
$NewString="Crescent"
 
#Setup Credentials to connect
$Cred = Get-Credential
$Cred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)
 
Try {
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
    $Ctx.Credentials = $Cred
 
    #Get the web and Library
    $Web=$Ctx.Web
    $List=$web.Lists.GetByTitle($LibraryName)
 
    #Get all items
    $Query = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery()
    $ListItems = $List.GetItems($Query)
    $Ctx.Load($ListItems)
    $Ctx.ExecuteQuery()
 
    #Rename each file matching given old string
    Foreach($Item in $ListItems)
    {
        #Replace string in the File Name
        if($Item["FileRef"].ToString().Contains($OldString))
        {
            $CurrentURL=$Item["FileRef"].ToString()
            $NewURL = $CurrentURL.Replace($OldString,$NewString)
            $Item.File.MoveTo($NewURL, [Microsoft.SharePoint.Client.MoveOperations]::Overwrite)
            $ctx.ExecuteQuery()
            Write-host -f Green "Renamed: "$CurrentURL
        }
    }
}
Catch {
    write-host -f Red "Error Renaming File!" $_.Exception.Message
}