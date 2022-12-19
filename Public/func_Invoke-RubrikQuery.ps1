help


function Invoke-RubrikQuery {
    <#
    .SYNOPSIS
        Runs a GraphQL query or mutation from file.
    .DESCRIPTION
        Runs a GraphQL query or mutation from file. You can specify one of the built-in graphql queries included with this module, or specify a path to a graphql file on disk.
    .EXAMPLE
        Invoke-RubrikQuery -Name slaDomains
        This runs the built-in slaDomains query located in the queries folder within the module.
    .EXAMPLE
        Invoke-RubrikQuery -Path ~/foo/bar/test.graphql
        This runs the GraphQL query located at ~/foo/bar/test.graphql
    #>
    
    [CmdletBinding()]
    param (
        # Path to GraphQL query file
        [Parameter()]
        [string]
        $Path,

        # Name of built-in query file
        [Parameter(Position=1)]
        [string]
        $Name,

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
        if ($Name) {
            $queryString = importQueryFile -Name $Name
        }
        elseif ($Path) {
            $queryString = importQueryFile -Path $Path
        }

        $query = @{query = $queryString; variables = $QueryParams} | ConvertTo-Json

        Write-Debug $rscUrl
        Write-Debug ($query | ConvertTo-Json)
        write-debug $query

        try {
            $response = Invoke-RestMethod -Method POST -Uri $rscUrl -Body $query -Headers $headers
        }
        catch {
            throw $_
        }
        if ($response.data.objects.nodes) {
            $response.data.objects.nodes
        }
        else {
            $response.data.objects
        }
    }
}