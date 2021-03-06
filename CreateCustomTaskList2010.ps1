﻿param(
    [System.String][Parameter(Mandatory=$true)]$SiteUrl,
    [System.String][Parameter(Mandatory=$true)]$ListName,
    [System.String][Parameter(Mandatory=$true)]$CustomTemplateTitle,
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

$Web = $ClientContext.Web
$ListTemplates = $ClientContext.Site.GetCustomListTemplates($Web)
$ClientContext.Load($ListTemplates)
$ClientContext.ExecuteQuery()

$listTemplate = $ListTemplates | Where Name -eq $CustomTemplateTitle

# Task List creation
$listCreationInformation = New-Object Microsoft.SharePoint.Client.ListCreationInformation
$listCreationInformation.Title = $ListName
$listCreationInformation.Description = $ListName
$listCreationInformation.TemplateType = $listTemplate.ListTemplateTypeKind
$listCreationInformation.TemplateFeatureId = $listTemplate.FeatureId
$listCreationInformation.ListTemplate = $listTemplate

$list = $ClientContext.Web.Lists.Add($listCreationInformation)
$ClientContext.Load($list)
$ClientContext.ExecuteQuery()