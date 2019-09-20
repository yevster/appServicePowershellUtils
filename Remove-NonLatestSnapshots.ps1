#!/usr/bin/env pwsh

function Remove-NonLatestSnapshots {
    <#
    .Description
    Given a file pattern (e.g. 'myfile*.jar'), removes all files matching this pattern except for the one with the lexicographically highest name
    #>

    [CmdletBinding()]
    param (
        # The pattern of files of which only the one with the lexicographically highest name should be kept (e.g. 'myApplication*.war').
        [Parameter(Mandatory=$true,
                   Position=0,
                   HelpMessage="The pattern of file names to reduce")]
        [string]
        $Pattern
    )
    
    Get-Item $Pattern | Sort-Object -Descending Name | Select-Object -SkipIndex 0 | Remove-Item
}
