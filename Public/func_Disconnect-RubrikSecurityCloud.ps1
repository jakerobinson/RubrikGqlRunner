function Connect-RubrikSecurityCloud() {
    [CmdletBinding(DefaultParameterSetName = 'ServiceAccountFile')]
    param ()
    <#
    .SYNOPSIS

     Disconnects from an instance of Rubrik Security Cloud

    .DESCRIPTION

    Disconnects from an instance of Rubrik Security Cloud
 
    .EXAMPLE

    PS> Disconnect-RubrikSecurityCloud

    #>

    if (Test-Path variable:global:RubrikSecurityCloudConnection) {
        $sessionUrl = $global:RubrikSecurityCloudConnection.Replace('graphql','session')
        $token = $global:RubrikSecurityCloudConnection.accessToken
        $headers = @{
            'Content-Type'  = 'application/json';
            'Accept'        = 'application/json';
            'Authorization' = $token;
        }
        try {
            $response = Invoke-RestMethod -Method POST -Uri $sessionUrl -Headers $headers
            Write-Information "Connection to $($global:RubrikSecurityCloudConnection.RubrikURL) released."
        }
        catch {
            throw $_.Exception
        }
        Remove-Item variable:global:RubrikSecurityCloudConnection
        
    }
}
