param(
    [System.String][Parameter(Mandatory=$true)]$SiteUrl,
    [System.String][Parameter(Mandatory=$true)]$UserName,
	[System.Security.SecureString][Parameter(Mandatory=$true)]$Password
	)

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.WorkflowServices.dll”

$SiteUrl = $SiteUrl + "/"

#Bind to site collection
$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $Password)
$clientContext.Credentials = $credentials
$clientContext.ExecuteQuery()

# Get Web
$web = $clientContext.Web
$clientContext.Load($web)
$clientContext.ExecuteQuery()

# Get WorkflowServicesManager
$WorkflowServicesManager = New-Object Microsoft.SharePoint.Client.WorkflowServices.WorkflowServicesManager($clientContext, $clientContext.Web)
$clientContext.Load($WorkflowServicesManager)
$clientContext.ExecuteQuery()

# Get WorkflowSubscriptionService
$WorkflowSubscriptionService = $WorkflowServicesManager.GetWorkflowSubscriptionService()
$clientContext.Load($WorkflowSubscriptionService)
$clientContext.ExecuteQuery()

# Get WorkflowDeploymentService
$WorkflowDeploymentService = $WorkflowServicesManager.GetWorkflowDeploymentService()
$clientContext.Load($WorkflowDeploymentService)
$clientContext.ExecuteQuery()

# Get WorkflowDefinitions
$WorkflowDefinitions = $WorkflowDeploymentService.EnumerateDefinitions($false)

$clientContext.Load($WorkflowDefinitions)
$clientContext.ExecuteQuery()

$i = 0;
$WorkflowDefinitions | Select-Object -InformationAction Inquire Selection, DisplayName,Id,RestrictToType,Published |  ForEach-Object {$_.Selection = $i++; $_}  | out-host

$selectionWorkflow = Read-Host 'Which workflow do you select from above (Selection)?'

$WorkflowDefinitionId = $WorkflowDefinitions[$selectionWorkflow].Id.Guid -replace '[-]'

$uri = New-Object System.Uri($SiteUrl)
$wfUrl =  $uri.AbsolutePath + "wfsvc/"+ $WorkflowDefinitionId +"/workflow.xaml"
$workflow = $web.GetFileByServerRelativeUrl($wfUrl)
$versions = $workflow.Versions

$WorkflowDefinitionId | out-host

$web.Context.Load($workflow)
$web.Context.Load($versions)
$web.Context.ExecuteQuery()

$versions | Select-Object Created, @{Name="Version";Expression={ "{0}" -f ($_.VersionLabel) }}, @{Name="Url";Expression={ "{0}" -f ($SiteUrl + $_.Url) }} | out-host