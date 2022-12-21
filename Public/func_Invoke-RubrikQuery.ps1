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
        
        $queryString = importQueryFile -Path $Path

        $query = @{query = $queryString; variables = $QueryParams} | ConvertTo-Json

        try {
            $response = runQuery $query
        }
        catch {
            throw $_.Exception
        }
        if ($response.data.objects.contains('nodes')) {
            $response.data.objects.nodes
        }
        elseif ($response.data.objects)  {
            $response.data.objects
        }
        else {
            $response
        }
    }
}