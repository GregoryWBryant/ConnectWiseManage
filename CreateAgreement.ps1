<#
This is an example of creating a basic T&M Agreement with defaults
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
$NeedAgreements = Import-Csv "PathToCSV"

$Header = @{
        'Accept' = 'application/json'
        'Authorization' = "Basic ${Base64}"
        'Content-Type' = 'application/json'
        'ClientID' = "${ClientID}"
}

$AgreementsURl = $BaseUrl + "/finance/agreements"

Foreach ($NeededAgreement in $NeedAgreements) {

    #Sets whot he Agreement will be assigned to, this is a required field
    $CompanyID = $NeededAgreement.CompanyID
    #Sets the contacton the Agreement, this is a required field
    $ContactID = $NeededAgreement.POCID
    #Sets the type of the contract, this is a required field
    $TypeID = 
    #Sets the tax code, if nothing is set it will default
    $TaxCodeID = 


    $NewAgreement = "{
        'name': 'T&M',
        'type': {'id': $TypeID},
        'company': {'id': $CompanyID },
        'applicationUnits': 'Amount',
        'applicationLimit': 0.00,
        'applicationCycle': 'CalendarMonth',
        'applicationUnlimitedFlag': true,
        'startDate': '2021-03-10T00:00:00Z',
        'billStartDate': '2021-03-10T00:00:00Z',
        'noEndingDateFlag': true,
        'contact': {'id': $ContactID },  
        'restrictLocationFlag': false,
        'restrictDepartmentFlag': false,
        'cancelledFlag': false,
        'agreementStatus': 'Active',
        'coverAgreementTime': true,
        'coverAgreementProduct': false,
        'coverAgreementExpense': false,
        'taxCode': {'id': $TaxCodeID}

    }"

    Invoke-RestMethod -Uri $AgreementsURl -Headers $Header -Body $NewAgreement -Method Post
}
