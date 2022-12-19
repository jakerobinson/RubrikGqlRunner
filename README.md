# RubrikGqlRunner
PowerShell module for running GraphQL queries from file

# Installation
Download and unzip into your PowerShell module path (check $env:PsModulePath if you aren't sure).

# Connecting to RSC
You can connect using your web session's access token or using a service account json file downloaded from the GUI when you create the service account.

## Connecting with Access Token
You must provide your access token (found in your browsers developer tools network tab), and your RSC instance name. i.e. an instance name of jake refers to `jake.my.rubrik.com`
```PowerShell
#For additional security, you can also read the access token is as a secure string, but here we are just masking the input.
$AccessToken = Read-Host -Prompt "Access Token" -MaskInput
Connect-RubrikSecurityCloud -InstanceName jake -AccessToken $AccessToken
```

## Connecting with a Service Account JSON file
```PowerShell
Connect-RubrikSecurityCloud -ServiceAccountPath ~/.rubrik/service-account-file.json
```

The service account file JSON is downloaded from the UI when you create a service account. The contents will look something like this:

```json
{
	"client_id": "client|QX8eSvuvE4PRswfGXc0jjfqXrIdLkdsi",
	"client_secret": "iLZOlumkf3P75_Ru34EQROFLMAOUyyGg77mOmI9RPvOf7o",
	"name": "powershell",
	"access_token_uri": "https://jake.my.rubrik.com/api/client_token"
}
```

# Running Queries
To run queries from a GraphQL file, you will use `Invoke-RubrikQuery`

## Running Queries with No Parameters
If you have a simple query with no parameters, or maybe hardcoded parameters, you can simply just run the query by giving it a path to the query file.

Given the following query in `/tmp/vsphereMountConnection.gql`:
```GraphQL
cat /tmp/vSphereMountConnection.gql
{
  objects: vSphereMountConnection {
    nodes {
        newVmName
    }
  }
}
```
I would run the following:
```PowerShell
Invoke-RubrikQuery -Path /tmp/vSphereMountConnection.gql 
```

## Running Queries with Parameters
Most of the time you will want to filter based on some name, or pass in variables for mutations. To do this, we will need to know what parameters the query/mutation expects from the file, and we can simply pass those in via hash table. 

Given the following GraphQL query to add a VM to an SLA:
```GraphQL
mutation assignSla($slaId: UUID, $objectIds: [UUID!]!) {
  objects: assignSla(input: {
    slaDomainAssignType: protectWithSlaId
    slaOptionalId: $slaId
    objectIds: $objectIds
    # shouldApplyToExistingSnapshots: true # optional. if you want existing snaps applied to new SLA assignment
    # existingSnapshotRetention: RETAIN_SNAPSHOTS # optional. What do you want to do with the old snaps if you change to DONOTPROTECT?
  }) {
    success
  }
}
```

The query expects slaId and an array of objectIds. We can pass these in from PowerShell like so:

```PowerShell
$queryvars = @{slaId = "00000000-0000-0000-0000-000000000001"; objectIds = @("51c6ebe3-6217-5643-9e30-7820e5653847")
Invoke-RubrikQuery -Path /tmp/assignSla.gql -QueryParams $queryvars
```

## Running Built-In Queries
I've included a few built-in queries into the module as examples (against my better judgement). Eventually these will be removed and there will be a separate repo specifically for example queries. For now, you can run these by name. They are `assignSla` and `slaDomains`. Note that I am using the `-Name` parameter instead of `-Path`

```PowerShell
$queryvars = @{slaId = "00000000-0000-0000-0000-000000000001"; objectIds = @("51c6ebe3-6217-5643-9e30-7820e5653847")
Invoke-RubrikQuery -Name assignSla -QueryParams $queryvars

Invoke-RubrikQuery -Name slaDomains
```


# Writing you own queries to work with RubrikGQLRunner
There are only a couple requirements here.

1. Your query must be aliased with `objects`
2. If you want to pass in variables dynamically, you must name the query. 

Here is an example of the simplest query:
```GraphQL
{
  objects: slaDomains { # <--------I am aliasing slaDomains as objects! This is how the GQLRunner parses the output!
    nodes {
      name
    }
  }
}
```

If I want to pass in variables to the same query, I will need to name the query and plumb in the variables. The name really doesn't matter. Get Creative. :)

```GraphQL
query getSLADomainByName($slaName: String!) {
  objects: slaDomains(filter: {field: NAME, text: $slaName}) {
    nodes {
      name
    }
  }
}
```

# Need More GraphQL Query Authoring Help?

* Rubrik GraphQL course by Mike Preston: https://www.youtube.com/playlist?list=PLHHKVC-uQ3XjL_LnGEBtgdbaqzReUuIqt
* GraphQL Query Authoring: https://graphql.org/learn/queries/