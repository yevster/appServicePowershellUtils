#!/usr/bin/env pwsh
function Set-AzWebAppSettings {
    <#
    .Description
    Sets App Settings in an Azure App Service web application to those specified in a Properties file in key=value form.
    #>

    param (
        # The name of the resource group containing the app service.
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $ResourceGroupName,

        # The name of the webapp
        [Parameter(Mandatory=$true, Position=1)]
        [string]
        $WebAppName,

        # The name of the webapp slot
        [Parameter(Mandatory=$true, Position=2)]
        [string]
        $SlotName,

        # The property file containing the settings to be set
        [Parameter(Mandatory=$true, Position=3)]
        [string]
        $SettingsFile
    )

    $slotSettings = (Get-AzWebAppSlot -ResourceGroupName $ResourceGroupName -Name $WebAppName -Slot $SlotName).SiteConfig.AppSettings
    $newSettings=@{}
    $slotSettings | % {$newSettings[$_.Name] = $_.Value}
    $props = Get-Content $SettingsFile | ConvertFrom-StringData
    $props.Keys | %{ $newSettings[$_]=$props.$_}
    Set-AzWebAppSlot -ResourceGroupName $ResourceGroupName -Name $WebAppName -Slot $SlotName -AppSettings $newSettings

}

