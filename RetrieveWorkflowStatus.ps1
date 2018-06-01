param(
    [System.String][Parameter(Mandatory=$true)]$SiteUrl,
    [System.String][Parameter(Mandatory=$true)]$UserName,
	[System.String][Parameter(Mandatory=$true)]$ListName,
	[System.Security.SecureString][Parameter(Mandatory=$true)]$SecurePassword
	)

$SPClientPathAssembly = $PWD.Path + "\Assembly\Microsoft.SharePoint.Client.dll"
$SPClientRuntimePathAssembly = $PWD.Path + “\Assembly\Microsoft.SharePoint.Client.Runtime.dll”
$SPClientWorkflowServicesAssembly = $PWD.Path + “\Assembly\Microsoft.SharePoint.Client.WorkflowServices.dll”

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path $SPClientPathAssembly
Add-Type -Path $SPClientRuntimePathAssembly
Add-Type -Path $SPClientWorkflowServicesAssembly

#Connect to site collection
$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
$clientContext.Credentials = $credentials

#Retrieve lists
$list = $clientContext.get_web().get_lists().getByTitle($ListName);
$camlQuery = New-Object Microsoft.Sharepoint.Client.CamlQuery;
$camlQuery.ViewXml = "<View><Query /><RowLimit>300</RowLimit></View>"
$listItems = $list.GetItems($camlQuery)
$clientContext.Load($list)
$clientContext.Load($listItems)

#Connect to Workflow service manager
$workflowServicesManager = New-Object Microsoft.SharePoint.Client.WorkflowServices.WorkflowServicesManager($clientContext, $clientContext.Web)
$workflowServiceInstance = $workflowServicesManager.GetWorkflowInstanceService();
$clientContext.Load($workflowServicesManager)
$clientContext.Load($workflowServiceInstance)
$clientContext.ExecuteQuery()

#Check list item that contain workflow instances
foreach($listItem in $listItems)
{

$workflowInstanceCollection = $workflowServiceInstance.EnumerateInstancesForListItem($list.Id, $listItem.Id)
$clientContext.Load($workflowInstanceCollection)
$clientContext.ExecuteQuery()


foreach ($workflowInstance in $workflowInstanceCollection)
{

    #Retrieve error message(Description) from workflow history.
    if ($workflowInstance.Status -eq "Suspended")
    {
    Write-Host “List Item Title:”$listItem["ID", “Title”]
    Write-Host “Workflow Status:”$workflowInstance.Status

    $listHistory = $clientContext.get_web().get_lists().getByTitle("Workflow History")
    $camlQueryHistory = New-Object Microsoft.Sharepoint.Client.CamlQuery
    $camlQueryHistory.ViewXml = "<View><Query><ViewFields><FieldRef Name='Description' /></ViewFields><Where><Eq><FieldRef Name='WorkflowInstance' /><Value Type='Text'>"+ $workflowInstance.Id + "</Value></Eq></Where></Query><RowLimit>300</RowLimit></View>"
    $listItemsHistory = $listHistory.GetItems($camlQueryHistory)
    $clientContext.Load($listHistory)
    $clientContext.Load($listItemsHistory)
    $clientContext.ExecuteQuery()

        foreach($listItemHistory in $listItemsHistory)
        {
            Write-Host “Error text: ”$listItemHistory.FieldValues.Description
        }
    Write-Host “Last Updated:”$workflowInstance.LastUpdated

    #Update error message to specify item contain workflow status is suspended.
    #Replace ["Actual_x0020_result"] withother internal field name for other field.
    $listItem["Error_x0020_message"] = $listItemHistory.FieldValues.Description
    $listItem["Workflow_x0020_run"] = "No"
    $listItem.Update()
    $clientContext.ExecuteQuery()

    #Cancel Workflows
    #$workflowServiceInstance.TerminateWorkflow($workflowInstance)
    #$clientContext.ExecuteQuery();        
    #write-output "Workflow terminated for:"$listItem["ID", “Title”]

    Write-Host “”
    }

}
}