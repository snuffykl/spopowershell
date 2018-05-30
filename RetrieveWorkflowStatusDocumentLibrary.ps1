param(
    [System.String][Parameter(Mandatory=$true)]$SiteUrl,
    [System.String][Parameter(Mandatory=$true)]$UserName,
	[System.String][Parameter(Mandatory=$true)]$ListName,
	[System.Security.SecureString][Parameter(Mandatory=$true)]$SecurePassword
	)

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.WorkflowServices.dll”

#Connect to site collection
$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
$clientContext.Credentials = $credentials

#Retrieve lists

$list = $clientContext.get_web().get_lists().getByTitle($ListName);
$camlQuery = New-Object Microsoft.Sharepoint.Client.CamlQuery;
$camlQuery.ViewXml = "<View><Query /><RowLimit>5000</RowLimit></View>"
$listItems = $list.GetItems($camlQuery);
$clientContext.Load($list)
$clientContext.Load($listItems);


#Connect to Workflow service manager
$workflowServicesManager = New-Object Microsoft.SharePoint.Client.WorkflowServices.WorkflowServicesManager($clientContext, $clientContext.Web);
$workflowServiceInstance = $workflowServicesManager.GetWorkflowInstanceService();
$clientContext.Load($workflowServicesManager);
$clientContext.Load($workflowServiceInstance);
$clientContext.ExecuteQuery();

$totalCompleted = 0
$totalSuspended = 0
$totalStarted = 0

#Check list item that contain workflow instances
foreach($listItem in $listItems)
{

$workflowInstanceCollection = $workflowServiceInstance.EnumerateInstancesForListItem($list.Id, $listItem.Id);
$clientContext.Load($workflowInstanceCollection);
$clientContext.ExecuteQuery();

if($workflowInstanceCollection.Count -eq 0){
    Write-Host "No workflow instanceId for listItem.Id:"$listItem.Id
}

foreach ($workflowInstance in $workflowInstanceCollection)
{

    #Retrieve error message(Description) from workflow history.
    if ($workflowInstance.Status -eq "Suspended")
    {

    $totalSuspended = $totalSuspended + 1;

    }
    elseif($workflowInstance.Status -eq "Completed"){
        $totalCompleted = $totalCompleted + 1;
    }
    elseif($workflowInstance.Status -eq "Started"){
        $totalStarted = $totalStarted + 1;
    }

}
}

Write-Host "Total Completed:"$totalCompleted
Write-Host "Total Suspended:"$totalSuspended
Write-Host "Total Started:"$totalStarted