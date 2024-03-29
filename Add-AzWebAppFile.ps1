#!/usr/bin/env pwsh

function Add-AzWebAppFile {
    <#
    .Description
    Uploads files to Azure App Service application file system.
    #>


    [CmdletBinding()]
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
        [Parameter(Mandatory=$false, Position=2)]
        [string]
        $SlotName,

        # Target Directory, where "/" is "/home" on the App Service file system.
        [Parameter(Mandatory=$true, Position=3)]
        [string]
        $TargetDirectory,

        # Files to upload
        [Parameter(Mandatory=$true,
                   Position=4,
                   ValueFromPipeline=$true,
                   HelpMessage="Path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $File,

        # Overwrite if a file already existss
        [Parameter()]
        [switch]
        $Force
    )
    
    begin {
        if ($SlotName){
            $target = Get-AzWebAppSlotPublishingProfile -ResourceGroupName $ResourceGroupName -Name $WebAppName -Slot $SlotName -Format ftp
        } else {
            $target = Get-AzWebAppPublishingProfile  -ResourceGroupName $ResourceGroupName -Name $WebAppName -Format ftp
        }

        if (!$target) {
            throw "Unable to obtain publishing profile."
        }

        $publishProfile=[xml]$target | Select-Object -ExpandProperty publishData | Select-Object -ExpandProperty publishProfile | Where-Object publishMethod -eq 'MSDeploy'
        $credential=[PSCredential]::new("$($publishProfile.userName)", (ConvertTo-SecureString -AsPlainText $publishProfile.userPWD -Force))
        $apiLocation="https://$($publishProfile.publishUrl)/api/vfs"
    }
    
    process {
        $item = Get-Item $File
        if ($item -is [System.IO.FileInfo]) {
            Write-Host "Uploading $($item.Name)"
            $headers=@{}
            if ($Force) {
                $headers['If-Match'] ='*'
            }
            
            Invoke-RestMethod -Credential $credential `
                -Authentication Basic -Method PUT -InFile $File `
                -Uri "${apiLocation}/$($TargetDirectory.TrimStart('/'))/$($item.Name)" -Headers $headers > $null
        }
    }
}
