function getUrlFromJwt {
    param (
        $jwt
    )
    
    $jwtPayloadEncoded = $jwt.Split(".")[1].Replace('-', '+').Replace('_', '/')
    $jwtPayloadByteArray = [System.Convert]::FromBase64String($jwtPayloadEncoded)
    $payloadObject = [System.Text.Encoding]::ASCII.GetString($jwtPayloadByteArray) | ConvertFrom-Json
    $instance = $payloadObject."https://my.rubrik.com/account"

    "https://$instance.my.rubrik.com/api/graphql"
}