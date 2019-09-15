#!/usr/bin/env pwsh
function Set-AzWebAppSettings {
    <#
    .Description
    Sets App Settings in an Azure App Service web application to those specified in a Properties file in key=value form.
    #>

    param (
        # The name of the resource group containing the app service.
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $ResourceGroupName,

        # The name of the webapp
        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $WebAppName,

        # The name of the webapp slot
        [Parameter(Mandatory = $false, Position = 2)]
        [string]
        $SlotName,

        # The property file containing the settings to be set
        [Parameter(Mandatory = $true, Position = 3)]
        [string]
        $SettingsFile
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    # Determine whether or not to work on app-level or slot-level
    if ($SlotName) {
        $settingsGetter = { (Get-AzWebAppSlot -ResourceGroupName $ResourceGroupName -Name $WebAppName -Slot $SlotName).SiteConfig.AppSettings }
        $settingsSetter = { param ($newSettings) Set-AzWebAppSlot -ResourceGroupName $ResourceGroupName -Name $WebAppName -Slot $SlotName -AppSettings $newSettings }
    }
    else {
        $settingsGetter = { (Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName).SiteConfig.AppSettings }
        $settingsSetter = { param ($newSettings) Set-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -AppSettings $newSettings }
    }

    $oldSettings = &$settingsGetter
    $newSettings = @{ }
    $oldSettings | ForEach-Object { $newSettings[$_.Name] = $_.Value }
    $props = Get-Content $SettingsFile | ConvertFrom-StringData
    $props.Keys | ForEach-Object { $newSettings[$_] = $props.$_ }
    &$settingsSetter $newSettings
}

