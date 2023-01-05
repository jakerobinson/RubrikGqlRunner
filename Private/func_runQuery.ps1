function runQuery {
    param (
        [String]$query
    )
    
    $token = $global:RubrikSecurityCloudConnection.accessToken
    $rscUrl = $global:RubrikSecurityCloudConnection.RubrikURL
    $headers = @{
        'Content-Type'  = 'application/json';
        'Accept'        = 'application/json';
        'Authorization' = $token;
    }

    Write-Debug $rscUrl
    Write-Debug $query
    
    try {
        $response = Invoke-RestMethod -Method POST -Uri $rscUrl -Body $query -Headers $headers
    }
    catch {
        throw $_.Exception | Out-String
    }

    $response
    
}