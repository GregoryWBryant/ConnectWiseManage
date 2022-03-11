<#
Example of finding specific addition atached to an Agreement
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
$Counter = 1
$Agreements = @()
$Contracts = @()
#ID Number of the Product Addition you are looking for
$ProdcutID = 

$Header = @{
        'Accept' = 'application/json'
        'Authorization' = "Basic ${Base64}"
        'Content-Type' = 'application/json'
        'ClientID' = "${ClientID}"
}


Write-Output "Getting Agreements"
do {

    $AgreementsURl = $BaseUrl + "/finance/agreements?conditions=agreementStatus='Active'&pagesize=1000&page=$Counter"
    $AgreementsResults = Invoke-RestMethod -Uri $AgreementsURl -Headers $Header -Method Get
    $Agreements += $AgreementsResults
    $Counter++

}until ($AgreementsResults.Length -eq 0)

Write-Output "Checking Additions"
foreach($Agreement in $Agreements) {
    $AgreementURL = $BaseUrl + "/finance/agreements/" + $Agreement.id + "/additions?conditions=product/id=$ProdcutID"
    $Addition = Invoke-RestMethod -Uri $AgreementUrl -Headers $Header -Method Get
    if ($null -ne $Addition.quantity) {
        $Contract = new-object PSObject 
        $Contract | add-member -membertype NoteProperty -name "Customer" -Value $Agreement.company.name
        $Contract | add-member -membertype NoteProperty -name "Agreement Name" -Value $Agreement.name
        $Contract | add-member -membertype NoteProperty -name "Agreement Parent" -Value $Agreement.parentAgreement.name
        $Contract | add-member -membertype NoteProperty -name "Agreement Type" -Value $Agreement.type.name
        $Contract | add-member -membertype NoteProperty -name "Addition Name Here" -Value $Addition.quantity
        $Contracts += $Contract
        }
}

$Contracts | Export-Csv -Path "" -NoTypeInformation
