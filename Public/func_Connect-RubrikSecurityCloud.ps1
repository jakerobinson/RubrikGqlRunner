function Connect-RubrikSecurityCloud() {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $ServiceAccountName
    )
    <#
    .SYNOPSIS

     Connect to a Rubrik Security Cloud Account using a Service Account. This is the recommended connection method. 

    .DESCRIPTION

    Connects to an instance of Rubrik Security Cloud. The cmdlet requires a Service Account JSON file stored at ~/.rubrik/polaris-service-account.json.

    .INPUTS

    None. You cannot pipe objects to Connect-RubrikSecurityCloud.
 
    .EXAMPLE

    PS> Connect-RubrikSecurityCloud
    #>

    Write-Information -Message "Info: Attempting to read the Service Account file located at ~/.rubrik/$($ServiceAccountName).json "
    try {
        $serviceAccountFile = Get-Content -Path "~/.rubrik/$($ServiceAccountName).json" -ErrorAction Stop | ConvertFrom-Json 
    }
    catch {
        $errorMessage = $_.Exception | Out-String

        if($errorMessage.Contains('because it does not exist')) {
            throw "The Service Account JSON secret file was not found. Ensure the file is location at ~/.rubrik/$($ServiceAccountName).json."
        } 
        
        throw $_.Exception
        
    }


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

    Write-Verbose -Message "Creating the Rubrik Polaris Connection Global variable."
    $global:RubrikSecurityCloudConnection = @{
        accessToken      = $response.access_token;
        PolarisURL  = $serviceAccountFile.access_token_uri.Replace("/api/client_token", "")
    }

}
# Export-ModuleMember -Function Connect-Polaris
