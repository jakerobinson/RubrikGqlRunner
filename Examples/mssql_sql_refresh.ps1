#Load Rubrik GraphQLRunner Module
Import-Module rubrikgqlrunner

#Connect to Rubrik server
Connect-RubrikSecurityCloud -ServiceAccountPath ./Service-Account-File.json

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
        [parameter(Mandatory=$false)]$sqlInstanceName = "MSSQLSERVER", 
        [parameter(Mandatory=$true)]$sqlDatabaseName, 
        [parameter(Mandatory=$true)]$sqlLiveMountDBName, 
        [parameter(Mandatory=$true)]$recoveryPoint
        )

        #region Get Instance ID of the Source SQL Server
        #set Parameters for GraphQL Query to retrieve SQL Instance ID
        $GetMSSQLInstanceParams = @{hostname = "$($sqlHostName)"; instance = "$($sqlInstanceName)"}
        
        #Invoke GraphQL Query 
        $GetSQLInstanceQuery = Invoke-RubrikQuery -Path './Queries/GetMSSQLInstance.gql' -QueryParams $GetMSSQLInstanceParams

        #Store the SQL Instance ID in a variable for passing to the next GraphQL query (to get database ID)
        $sqlInstanceID = $GetSQLInstanceQuery.physicalChildConnection.nodes.id
        $sqlInstanceID
        #endregion

        #region Get Database ID of the database to be Live Mounted
        #Set Parameters for GraphQL Query to retrieve the database ID (uses the SQL Instance ID and the SQL Database Name)
        $GetMSSQLDatabaseParams = @{instanceID = $sqlInstanceID; DatabaseName = @($sqlDatabaseName)}
        
        #Invoke GraphQL Query to obtain the SQL Database ID of the source database
        $GetSQLDatabaseQuery = Invoke-RubrikQuery -Path './Queries/GetMSSQLDatabase.gql' -QueryParams $GetMSSQLDatabaseParams
        
        #Store the SQL Database ID in a variable for passing to the next GraphQL query (to mount the database)
        $sqlDatabaseID = $GetSQLDatabaseQuery.descendantConnection.nodes.id
        $sqlDatabaseID
        #endregion

        #region Create Live Mount of the databse
        #Set Paremeters for GraphQL Query to execute a MS SQL Database LiveMount passing the Destination Database Name, Target InstanceID, recoveryPoint (date in UTC Format) and the Source SQL Database ID
        $CreateMssqlLiveMountParams = @{mountedDatabaseName = "$($sqlLiveMountDBName)"; targetInstanceId = "$($sqlInstanceID)"; date = $recoveryPoint; id = "$($sqlDatabaseID)"}
        $CreateMssqlLiveMountParams
        Invoke-RubrikQuery -Path './Queries/CreateMssqlLiveMount.gql' -QueryParams $CreateMssqlLiveMountParams -Verbose
        #endregion
}

#Example of invoking the above MS SQL Live Mount Database Function
# MSSQLDB_LiveMount -sqlHostName "rp-sql19sl-01.perf.rubrik.com" -sqlInstanceName "MSSQLSERVER" -sqlDatabaseName "TPCC_5000GB" -sqlLiveMountDBName "JCTestGraphLiveMount" -recoveryPoint "2023-03-23T18:02:00.000z"
MSSQLDB_LiveMount -sqlHostName "rp-sql19sl-01.perf.rubrik.com"  -sqlDatabaseName "TPCC_5000GB" -sqlLiveMountDBName "JCTestGraphLiveMount" -recoveryPoint "2023-03-23T18:02:00.000z"