#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

Function Import-SPOUserFromCSV($CSVFile)
{ 
    #Get data from CSV
    $UserData = Import-CSV $CSVFile

    #Get Credentials to connect
    $Cred = Get-Credential

    ForEach($Row in $UserData)
    {
        #Get Data from CSV
        $SiteURL = $Row.SiteURL
        $GroupName = $Row.GroupName
        $UserAccount = $Row.UserAccount

        Try {
            #Setup the context
            $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
            $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)

            #Get the Web and Group
            $Web = $Ctx.Web
            $Group= $Web.SiteGroups.GetByName($GroupName)

            #Resolve the User
            $User=$web.EnsureUser($UserAccount)
            $Ctx.Load($User);
            #Add user to the group
            $Result = $Group.Users.AddUser($User)
            $Ctx.Load($Result)
            $Ctx.ExecuteQuery()

            write-host  -f Green "User '$UserAccount' has been added to '$GroupName' in Site '$SiteURL'"
        }
        Catch {
            write-host -f Red "Error Adding user to Group!" $_.Exception.Message
        }
    }
}

#Call the function
Import-SPOUserFromCSV "D:\UserData1.csv"