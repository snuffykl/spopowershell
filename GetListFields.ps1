#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.WorkflowServices.dll”

#Specify tenant admin and site URL
$SiteUrl = ""
$ListName = ""
$UserName = ""
$SecurePassword = ConvertTo-SecureString "" -AsPlainText -Force

#Bind to site collection
$ClientContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
$ClientContext.Credentials = $credentials
$ClientContext.ExecuteQuery()

# Get List
$list = $ClientContext.Web.Lists.GetByTitle($ListName)
$ClientContext.Load($list)
$ClientContext.ExecuteQuery()

$fields = $list.Fields
$ClientContext.Load($fields)
$ClientContext.ExecuteQuery()

$fields | Select-Object InternalName,SchemaXml