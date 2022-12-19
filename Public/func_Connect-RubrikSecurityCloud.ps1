function Connect-RubrikSecurityCloud() {
    [CmdletBinding(DefaultParameterSetName = 'ServiceAccountFile')]
    param (
        [Parameter(Mandatory = $true,
        ParameterSetName = 'ServiceAccountFile')]
        [String]$ServiceAccountPath,
        [Parameter(Mandatory = $true,
        ParameterSetName = 'AccessToken')]
        [String]$AccessToken,
        [Parameter(Mandatory = $true,
        ParameterSetName = 'AccessToken')]
        [String]$InstanceName
    )
    <#
    .SYNOPSIS

     Connects to an instance of Rubrik Security Cloud using an Access Token or Service Account File

    .DESCRIPTION

    Connects to an instance of Rubrik Security Cloud using an Access Token or Service Account File
 
    .EXAMPLE

    The Service Account JSON can be downloaded from the GUI when creating a service account.

    PS> Connect-RubrikSecurityCloud -ServiceAccountFile ~/.rubrik/myserviceaccount.json

    .EXAMPLE

    The Instance name "JakeCo" refers to the my.rubrik.com instance name i.e. JakeCo.my.rubrik.com

    PS> Connect-RubrikSecurityCloud -InstanceName JakeCo -AccessToken "Access Token from Browser session or another vault or script that has authenticated using a Servce Account"

    #>

    Write-Information -Message "Info: Attempting to read the Service Account file located at $($ServiceAccountPath)"
    try {
        switch ($PSCmdlet.ParameterSetName) {
            'ServiceAccountFile' {
                $serviceAccountFile = Get-Content -Path $ServiceAccountPath -ErrorAction Stop | ConvertFrom-Json
                $payload = @{
                    grant_type = "client_credentials";
                    client_id = $serviceAccountFile.client_id;
                    client_secret = $serviceAccountFile.client_secret
                }   
            
                Write-Debug -Message "Determing if the Service Account file contains all required variables."
                $missingServiceAccount = @()
                if ($null -eq $serviceAccountFile.client_id) {
                    $missingServiceAccount += "'client_id'"
                }
            
                if ($null -eq $serviceAccountFile.client_secret) {
                    $missingServiceAccount += "'client_secret'"
                }
            
                if ($null -eq $serviceAccountFile.access_token_uri) {
                    $missingServiceAccount += "'access_token_uri'"
                }
            
            
                if ($missingServiceAccount.count -gt 0){
                    throw "The Service Account JSON secret file is missing the required paramaters: $missingServiceAccount"
                }

                $headers = @{
                    'Content-Type' = 'application/json';
                    'Accept'       = 'application/json';
                }

                Write-Debug -Message "Connecting to the Polaris GraphQL API using the Service Account JSON file."
                $response = Invoke-RestMethod -Method POST -Uri $serviceAccountFile.access_token_uri -Body $($payload | ConvertTo-JSON -Depth 100) -Headers $headers
                $AccessToken = "Bearer " + $response.access_token
                $RubrikURL  = $serviceAccountFile.access_token_uri.Replace("/api/client_token", "/api/graphql")
            }
            'AccessToken' {
                $RubrikURL = "https://$InstanceName.my.rubrik.com/api/graphql"
            }
            Default {}
        }
        
    }
    catch {
        $errorMessage = $_.Exception | Out-String        
        throw $_.Exception
        
    }


    
    Write-Verbose -Message "Creating the Rubrik Polaris Connection Global variable."
    $global:RubrikSecurityCloudConnection = @{
        accessToken      = $AccessToken
        RubrikURL        = $RubrikURL
    }

}
