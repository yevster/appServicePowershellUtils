# App Service Powershell Utilities

PowerShell utilities for migration/deployment tasks with Azure App Service

[`Add-AzWebAppFile`](Add-AzWebAppFile.ps1) - Uploads files to the App Service file system.

[`Set-AzWebAppSettings`](Set-AzWebAppSettings.ps1) - Applies settings from a property file in `key=value` form to App Service.

[`Remove-NonLatestSnapshots`](Remove-NonLatestSnapshots.ps1) - When running a release pipeline in Azure Pipelines on a Maven snapshot artifact, multiple versions of the same file (typically a Jar file) may be present. In such cases, this command can be used to keep only the latest one.
