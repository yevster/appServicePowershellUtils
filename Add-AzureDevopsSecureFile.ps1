#!/usr/bin/env pwsh

function Add-AzDevOpsSecureFile {
    [CmdletBinding()]
    param (
        # The ID of the organization
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Organization,

        # The ID of the project (GUID)
        [Parameter(Mandatory=$true, Position=1)]
        [string]
        $ProjectId,

        # File(s) to upload
        [Parameter(Mandatory=$true,
                   Position=2,
                   ValueFromPipeline=$true,
                   HelpMessage="Path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $File
    )
    
    begin {
        $tokenCache = (Get-AzContext).TokenCache
        $endpoint = "https://dev.azure.com/${Organization}/${ProjectId}/_apis/distributedtask/securefiles"
        $tenantId = (Get-AzSubscription -SubscriptionId $subscriptionId)[0].TenantId
        $accessToken = $tokenCache.ReadItems() `
        | Where-Object { $_.TenantId -eq $tenantId } `
        | Sort-Object -Property ExpiresOn -Descending `
        | Select-Object -First 1 -ExpandProperty AccessToken
        $headers = @{ 
            "Authorization" = "Bearer " + $accessToken;
            "Content-Type" = 'application/octet-stream' ;
            "Accept" = "application/json; api-version=5.2-preview.1; excludeUrls=true" ;
            "Accept-Encoding" = "gzip, deflate, br"
        }
    }
    
    process {
        $item = Get-Item $File
        if ($item -is [System.IO.FileInfo]) {
            Write-Host "Uploading $($item.Name)"
            $body=[System.Convert]::ToBase64String([System.io.File]::ReadAllBytes($item))
            Invoke-RestMethod -Credential $credential -Method POST `
                -Body $body -Uri "${endpoint}?file=$($item.Name)" `
                -Headers $headers 
        }
    }
}
