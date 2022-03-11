<#
Example of updating a Member
#>

$ClientID = ""
$CompanyName = ""
$PublicKey = ""
$PrivateKey = ""
$Authorization = "${CompanyName}+${PublicKey}:${PrivateKey}"
$Base64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authorization)));
$uri = "https://na.myconnectwise.net/login/companyinfo/${CompanyName}"
$CompanyInfo = Invoke-RestMethod -uri $uri
$CodeBase = $CompanyInfo.Codebase
$ConnectWiseSite = $CompanyInfo.SiteURL
$BaseUrl = "https://${ConnectWiseSite}/${codebase}apis/3.0"


$Header = @{
        'Accept' = 'application/json'
        'Authorization' = "Basic ${Base64}"
        'Content-Type' = 'application/json'
        'ClientID' = "${ClientID}"
}

$MembersURl = $BaseUrl + "/system/members?conditions=primaryEmail='Email@Email.here'"
$Member = Invoke-RestMethod -Uri $MembersURl -Headers $Header -Method Get
#String
NewFirstname = ""
#string
NewLastName = ""
#String
NewEmployeeID = ""
#String
$NewTitel = ""
#Int, ID of the Manager in Connectwise
$ReportsToID = 
#Int, Typically the same as Reports to
$TimeApprover =
#Int, Typically the same as Reports to
$ExpenseApprover =
#Int, ID of the Department you want to use
$DefaultDepartment = 



$Body = "[
  {
    'op': 'replace',
    'path': 'firstName',
    'value': NewFirstname
  },
    {
    'op': 'replace',
    'path': 'lastName',
    'value': NewLastName
  },
  {
    'op': 'replace',
    'path': 'employeeIdentifer',
    'value': NewEmployeeID
  },
    {
    'op': 'replace',
    'path': 'title',
    'value': $NewTitel
  },
    {
    'op': 'replace',
    'path': 'reportsTo',
    'value': {'ID': $ReportsToID }
  },
    {
    'op': 'replace',
    'path': 'timeApprover',
    'value': {'ID': $TimeApprover }
  },
    {
    'op': 'replace',
    'path': 'expenseApprover',
    'value': {'ID': $ExpenseApprover }
  },
    {
    'op': 'replace',
    'path': 'defaultDepartment',
    'value': {'ID': $DefaultDepartment }
  }
]"

$URI = "https://api-na.myconnectwise.net/v2021_3/apis/3.0/system/members/" + $Members[0].id
Invoke-RestMethod -Uri $URI -Headers $Header -Method Patch -Body $Body
