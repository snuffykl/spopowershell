param(
    [System.String][Parameter(Mandatory=$true)]$UserName,
	[System.Security.SecureString][Parameter(Mandatory=$true)]$Password
	)

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.WorkflowServices.dll”

$SourceSiteUrl = Read-Host 'Which site (SiteUrl) is working in SP Ribbon for the Nintex Workflow icon ?'
$SourceSiteUrl = $SourceSiteUrl + "/"


#Bind to site collection
$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($WorkingSiteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $Password)
$clientContext.Credentials = $credentials
$clientContext.ExecuteQuery()

# Get Web
$web = $clientContext.Web
$clientContext.Load($web) 
$clientContext.ExecuteQuery() 

$userActions = $web.UserCustomActions   
$clientContext.Load($userActions)     
$clientContext.ExecuteQuery()   

$tempRibbonItem = $userActions.Add()
$tempRibbonItem = $userActions


$DestinationSiteUrl = Read-Host 'Which site (SiteUrl) do you want Nintex Workflow icon to appear at ?'
$DestinationSiteUrl = $DestinationSiteUrl + "/"

$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($DestinationSiteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $Password)
$clientContext.Credentials = $credentials
$clientContext.ExecuteQuery()

$web = $clientContext.Web
$clientContext.Load($web) 
$clientContext.ExecuteQuery() 

$userActions = $web.UserCustomActions   
$clientContext.Load($userActions)     
$clientContext.ExecuteQuery()   

$newRibbonItem = $userActions.Add()
$newRibbonItem.RegistrationId = "100" 
$newRibbonItem.Title = $tempRibbonItem.Title 
$newRibbonItem.RegistrationType = [Microsoft.SharePoint.Client.UserCustomActionRegistrationType]::List 
$newRibbonItem.Location = "CommandUI.Ribbon"
$newRibbonItem.CommandUIExtension = $tempRibbonItem.CommandUIExtension

$newRibbonItem.Update() 
$clientContext.Load($newRibbonItem)  
$clientContext.ExecuteQuery()  