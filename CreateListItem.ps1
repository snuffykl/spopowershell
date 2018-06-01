param(
    [System.String][Parameter(Mandatory=$true)]$SiteUrl,
    [System.String][Parameter(Mandatory=$true)]$ListName,
    [System.String][Parameter(Mandatory=$true)]$UserName,
	[System.Security.SecureString][Parameter(Mandatory=$true)]$SecurePassword
	)

$SPClientPathAssembly = $PWD.Path + "\Assembly\Microsoft.SharePoint.Client.dll"
$SPClientRuntimePathAssembly = $PWD.Path + “\Assembly\Microsoft.SharePoint.Client.Runtime.dll”
$SPClientWorkflowServicesAssembly = $PWD.Path + “\Assembly\Microsoft.SharePoint.Client.WorkflowServices.dll”

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path $SPClientPathAssembly
Add-Type -Path $SPClientRuntimePathAssembly
Add-Type -Path $SPClientWorkflowServicesAssembly

# Bind to site collection
$ClientContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
$ClientContext.Credentials = $credentials
$ClientContext.ExecuteQuery()

# Get List
$List = $ClientContext.Web.Lists.GetByTitle($ListName)
$ClientContext.Load($List)
$ClientContext.ExecuteQuery()

# Loop Create List Item
for ($i=1; $i -le 1000; $i++)
{
  $ListItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
  $NewListItem = $List.AddItem($ListItemCreationInformation)
  $NewListItem["Title"] = "abc$($i)"
  $NewListItem.Update()
  $ClientContext.ExecuteQuery()
}