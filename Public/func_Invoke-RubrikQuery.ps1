help


function Invoke-RubrikQuery {
    <#
    .SYNOPSIS
        Runs a GraphQL query or mutation from file.
    .DESCRIPTION
        Runs a GraphQL query or mutation from file.

    .EXAMPLE
        Invoke-RubrikQuery -Path ~/foo/bar/test.graphql
        This runs the GraphQL query located at ~/foo/bar/test.graphql
    #>
    
    [CmdletBinding()]
    param (
        # Path to GraphQL query file
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        # Hash of variables required for the query
        [Parameter()]
        [hashtable]
        $QueryParams
    )
    
    process {
        
        [String]$queryString = importQueryFile -Path $Path

        $query = @{query = $queryString; variables = $QueryParams} | ConvertTo-Json -Depth 100

        try {
            $response = runQuery $query
        }
        catch {
            throw $_.Exception
        }

        # Some queries come back in nodes, and some don't.
        # Some queries come back as an array, and sometimes not.
        # PowerShell won't let me just check for $null or emptyString on an array in a hash
        if ($response.data.objects -is "System.Array") {
            if ($response.data.objects.contains("nodes")) {
                $response.data.objects.nodes
            }
            else {
                $response.data.objects
            }
        }
        elseif ($response.data.objects -is "System.Management.Automation.PSCustomObject")  {
            if (!$null -eq $response.data.objects.nodes) {
                $response.data.objects.nodes
            }
            else {
                $response.data.objects
            }
        }
        elseif ($response.errors) {
            Write-Host $response.errors
        }
        else {
            $response.data.objects
        }
    }
}