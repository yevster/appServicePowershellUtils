function Add-AzWebAppFile {
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
        [Parameter(Mandatory=$true, Position=2)]
        [string]
        $SlotName,

        # Target Directory
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
        $File
    )
    
    begin {
        $profile=[xml](Get-AzWebAppSlotPublishingProfile -ResourceGroupName $ResourceGroupName -Name $WebAppName -Slot $SlotName -Format ftp) | Select-Object -ExpandProperty publishData | Select-Object -ExpandProperty publishProfile | Where-Object publishMethod -eq 'MSDeploy'
        $credential=[PSCredential]::new("$($profile.userName)", (ConvertTo-SecureString -AsPlainText $profile.userPWD -Force))
        $apiLocation="https://$($profile.publishUrl)/api/vfs"
    }
    
    process {
        $item = Get-Item $File
        if ($item -is [System.IO.FileInfo]) {
            $targetPath = $item | Resolve-Path -Relative 
            Write-Host "Uploading ${targetPath}"
            Invoke-RestMethod -Credential $credential -Authentication Basic -Method PUT -InFile $File -Uri "${apiLocation}/${TargetDirectory}/${targetPath}" > $null
        }
    }
}
