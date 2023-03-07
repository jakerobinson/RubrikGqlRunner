#Load Rubrik GraphQLRunner Module
Import-Module rubrikgqlrunner

#Connect to Rubrik server
Connect-RubrikSecurityCloud -ServiceAccountPath ~/.rubrik/service-account-file.json

<#  Example of Variables to be passed to the below function
#Source SQL DB Hostname
$sqlHostName = "rp-sql19sl-01.perf.rubrik.com"
#Source SQL DB Name
$sqlDatabaseName = "TPCC_5000GB"
#Destination DB LiveMount Name
$sqlLiveMountDBName = "JCTestGraphLiveMount"
#Source SQL DB Recovery Point to Mount
$recoveryPoint = "2023-02-27T18:02:00.000Z"
#>

Function MSSQLDB_LiveMount {
    param(
        [parameter(Mandatory=$true)]$sqlHostName, 
        [parameter(Mandatory=$true)]$sqlDatabaseName, 
        [parameter(Mandatory=$true)]$sqlLiveMountDBName, 
        [parameter(Mandatory=$true)]$recoveryPoint
        )

        #set Parameters for GraphQL Query to retrieve SQL Instance ID
        $GetMSSQLInstanceParams = @{hostname = $sqlHostName}
        #Invoke GraphQL Query to obtain the SQL InstanceID of the source database
        $GetSQLInstanceQuery = Invoke-RubrikQuery -Path '/Users/jcathey/Google Drive/My Drive/Scripts/GraphQL/Queries/GetMSSQLInstance.gql' -QueryParams $GetMSSQLInstanceParams
        #Store the SQL Instance ID in a variable for passing to the next GraphQL query (to get database ID)
        $sqlInstanceID = $GetSQLInstanceQuery.physicalChildConnection.nodes[0].id

        #Set Parameters for GraphQL Query to retrieve the database ID (uses the SQL Instance ID and the SQL Database Name)
        $GetMSSQLDatabaseParams = @{instanceID = $sqlInstanceID; DatabaseName = @($sqlDatabaseName)}
        #Invoke GraphQL Query to obtain the SQL Database ID of the source database
        $GetSQLDatabaseQuery = Invoke-RubrikQuery -Path '/Users/jcathey/Google Drive/My Drive/Scripts/GraphQL/Queries/GetMSSQLDatabase.gql' -QueryParams $GetMSSQLDatabaseParams
        #Store the SQL Database ID in a variable for passing to the next GraphQL query (to mount the database)
        $sqlDatabaseID = $GetSQLDatabaseQuery.descendantConnection.nodes.id

        #Set Paremeters for GraphQL Query to execute a MS SQL Database LiveMount passing the Destination Database Name, Target InstanceID, recoveryPoint (date in UTC Format) and the Source SQL Database ID
        $CreateMssqlLiveMountParams = @{mountedDatabaseName = $sqlLiveMountDBName; targetInstanceId = $sqlInstanceID; date = $recoveryPoint; id = $sqlDatabaseID}
        Invoke-RubrikQuery -Path '/Users/jcathey/Google Drive/My Drive/Scripts/GraphQL/Queries/CreateMssqlLiveMount.gql' -QueryParams $CreateMssqlLiveMountParams -Debug
}

#Example of invoking the above MS SQL Live Mount Database Function
MSSQLDB_LiveMount -sqlHostName "rp-sql19sl-01.perf.rubrik.com" -sqlDatabaseName "TPCC_5000GB" -sqlLiveMountDBName "JCTestGraphLiveMount" -recoveryPoint "2023-02-27T18:02:00.000Z"