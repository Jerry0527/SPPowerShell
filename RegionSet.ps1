#region Variables 
$AdminSiteURL = "https://M365x636146-admin.sharepoint.com"
$tenantAdmin = "linda@M365x636146.onmicrosoft.com"
$Password = "37KjyhOvGY" 
$groupEmail = "SPOGroup@leetestdev.onmicrosoft.com"
$LogFile = "C:\temp\"+(Get-Date -Format yyyy-MM-dd) + "joblog1.log"
#endregion Variables

#region Credentials 
[SecureString]$SecurePass = ConvertTo-SecureString $Password -AsPlainText -Force 
[System.Management.Automation.PSCredential]$PSCredentials = New-Object System.Management.Automation.PSCredential($tenantAdmin, $SecurePass) 
#endregion Credentials

Function Write-Log([string[]]$Message, [string]$LogFile = $Script:LogFile, [switch]$ConsoleOutput) {
    $Message = $Message + $Input
    If ($null -ne $Message -and $Message.Length -gt 0) {
        if ($null -ne $LogFile -and $LogFile -ne [System.String]::Empty) {
            Out-File -Append -FilePath $LogFile -InputObject "$Message"			
        }
        if ($ConsoleOutput -eq $true) {
            Write-Host "$Message"
        }
    }
}

#Connect to SharePoint Online Admin Center
#Connect-SPOService -Url $AdminSiteURL -credential $PSCredentials
Connect-PnPOnline -Url $AdminSiteURL -credentials $PSCredentials

#Get all OneDrive for Business Site collections
#$OneDriveSites = Get-SPOSite -Template "SPSPERS" -Limit ALL -IncludePersonalSite $True
$Sites=Get-PnPTenantSite -IncludeOneDriveSites
#Write-Host -f Yellow "Total Number of OneDrive Sites Found: " $OneDriveSites.count

#Add Site Collection Admin to each OneDrive
foreach ($Site in $Sites) {
	#Test purpose
	#if ($Site.Url -eq "https://leetestdev-my.sharepoint.com/personal/krissy_leetestdev_onmicrosoft_com") {		
		$Url=$Site.Url
		#Write-Host -f Yellow "Adding $($groupEmail) with read permission to: $Url"
		try {
			$needReset = $false
			try {				
				Connect-PnPOnline -Url $Url -credentials $PSCredentials	
				Write-Log -LogFile $LogFile -Message "connecting to site $($Url)."	
				$checkAdmin = Get-PnPUser | ? Email -eq $tenantAdmin
				if ($?) {
					if ($checkAdmin.IsSiteAdmin -eq $false) {
						Write-Host "Use has permission while not admin, add User $($tenantAdmin) as admin to site $($Url)"
						Connect-PnPOnline -Url $AdminSiteURL -credentials $PSCredentials
						Set-PnPTenantSite -Url $Url -Owners $tenantAdmin
						$needReset = $true
						Write-Log -LogFile $LogFile -Message "Use has permission while not admin, add User $($tenantAdmin) as admin to site $($Url), need reset $($needReset)"
					}
				}
				else {
					$errorMessage=$error[0].Exception
					Write-Log -LogFile $LogFile -Message "Connecting to site $($Url). Error $($errorMessage)"	
					throw $errorMessage
                }	
                
			}
			catch {
				Write-Host "Add User $($tenantAdmin) as admin to site $($Url)"
				Connect-PnPOnline -Url $AdminSiteURL -credentials $PSCredentials
				Set-PnPTenantSite -Url $Url -Owners $tenantAdmin
				$needReset = $true
				Write-Log -LogFile $LogFile -Message "Add User $($tenantAdmin) as admin to site $($Url), need reset $($needReset)"
            }

            finally{
            
                $web = Get-PnPWeb -Includes RegionalSettings.LocaleId
                $Web.RegionalSettings.LocaleId= 3081
                $web.Update()
                Invoke-PnPQuery
                
            }
        
		}
		catch {			
			Write-Host "Error connecting to site $($Url)."
			Write-Log -LogFile $LogFile -Message "Error connecting to site $($Url), Error message: $($_)."
        }
        finally
        {
            if ($needReset) {
                Write-Host "Restset User $($tenantAdmin) as admin to false in site $($Url) "					
                Remove-PnPSiteCollectionAdmin -Owners $tenantAdmin
                Write-Log -LogFile $LogFile -Message "Restset User $($tenantAdmin) as admin to false in site $($Url)"			
            }		
        }
   
		#Connect-PnPOnline -Url $Url -Credentials $PSCredentials
		#Set-PnPListPermission -Identity "Documents" -User $groupEmail -AddRole "Read"
        #Write-Host -f Green "$($groupEmail) Added to OneDrive Sites $Url Successfully!"
        
		
	#}
}
Write-Host -f Green "Script complete..."