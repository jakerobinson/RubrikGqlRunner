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
        [Parameter(required=$true)]
        [string]
        $Path,

        # Hash of variables required for the query
        [Parameter()]
        [hashtable]
        $QueryParams
    )
    
    process {
        $token = $global:RubrikSecurityCloudConnection.accessToken
        $rscUrl = $global:RubrikSecurityCloudConnection.RubrikURL
        $headers = @{
            'Content-Type'  = 'application/json';
            'Accept'        = 'application/json';
            'Authorization' = $token;
        }
        
        $queryString = importQueryFile -Path $Path

        $query = @{query = $queryString; variables = $QueryParams} | ConvertTo-Json

        Write-Debug $rscUrl
        Write-Debug $query

        try {
            $response = Invoke-RestMethod -Method POST -Uri $rscUrl -Body $query -Headers $headers
            Write-Debug $response
        }
        catch {
            throw $_.Exception
        }
        if ($response.data.objects.nodes) {
            $response.data.objects.nodes
        }
        elseif ($response.data.objects)  {
            $response.data.objects
        }
        else {
            $response.data
        }
    }
}