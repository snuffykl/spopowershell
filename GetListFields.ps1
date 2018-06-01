    param(
    [System.String][Parameter(Mandatory=$true)]$SiteUrl,
    [System.String][Parameter(Mandatory=$true)]$UserName,
	[System.String][Parameter(Mandatory=$true)]$ListTaskName,
	[System.Security.SecureString][Parameter(Mandatory=$true)]$SecurePassword
	)

$SPClientPathAssembly = $PWD.Path + "\Assembly\Microsoft.SharePoint.Client.dll"
$SPClientRuntimePathAssembly = $PWD.Path + “\Assembly\Microsoft.SharePoint.Client.Runtime.dll”
$SPClientWorkflowServicesAssembly = $PWD.Path + “\Assembly\Microsoft.SharePoint.Client.WorkflowServices.dll”

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path $SPClientPathAssembly
Add-Type -Path $SPClientRuntimePathAssembly
Add-Type -Path $SPClientWorkflowServicesAssembly

#Bind to site collection
$ClientContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
$ClientContext.Credentials = $credentials
$ClientContext.ExecuteQuery()

# Get List
$list = $ClientContext.Web.Lists.GetByTitle($ListTaskName)
$ClientContext.Load($list)
$ClientContext.ExecuteQuery()

$fields = $list.Fields
$ClientContext.Load($fields)
$ClientContext.ExecuteQuery()

$status = $fields | Where-Object {$_.InternalName -eq "Status"}

Write-Host "Mapping: "  $status.Mappings -ForegroundColor Green 

Write-Host "SchemaXml: "  $status.SchemaXml -ForegroundColor Green 