<#
Example of getting Closed Opportunities for certain dates
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
$Opportunities = @()
$StartDate = "2022-02-01T17:00:00Z"
$EndDate = "2022-02-21T20:00:00Z"

$Header = @{
        'Accept' = 'application/json'
        'Authorization' = "Basic ${Base64}"
        'Content-Type' = 'application/json'
        'ClientID' = "${ClientID}"
}

do {

    $OppsURl = $BaseUrl + "/sales/Opportunities?conditions=closedDate > [$StartDate] and closedDate < [$EndDate] and status/name='Won' &pagesize=1000&page=$Counter"
    $OppResults = Invoke-RestMethod -Uri $OppsURl -Headers $Header -Method Get
    $Opportunities += $OppResults
    $Counter++

}until ($OppResults.Length -eq 0)

$Opportunities | Export-Csv -Path "" -NotypeInformation
