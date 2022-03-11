<#
Get contacts for specific Customers and transform the data to be cleaner
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
$Companies = Import-Csv -Path "C:\users\GregoryBryant\Downloads\Companies needing POC.csv"
$Contacts = @()
$NewContacts = @()


$Header = @{
        'Accept' = 'application/json'
        'Authorization' = "Basic ${Base64}"
        'Content-Type' = 'application/json'
        'ClientID' = "${ClientID}"
}


Write-Output "Getting Contacts"

foreach ($Company in $Companies ) {
    $CompanyID = $Company.CompanyID
    $ContactsURl = $BaseUrl + "/company/contacts?conditions=company/id=$CompanyID&pagesize=1000"
    $ContactsResults = Invoke-RestMethod -Uri $ContactsURL -Headers $Header -Method Get
    $Contacts += $ContactsResults
}

foreach ($Contact in $Contacts) {

    $NewContact = new-object PSObject 
    $NewContact| add-member -membertype NoteProperty -name "ID" -Value $Contact.id
    $NewContact| add-member -membertype NoteProperty -name "Company" -Value $Contact.company.name
    $NewContact| add-member -membertype NoteProperty -name "First name" -Value $Contact.firstName
    $NewContact| add-member -membertype NoteProperty -name "Last name" -Value $Contact.lastName
    $NewContact| add-member -membertype NoteProperty -name "Disabled" -Value $Contact.inactiveFlag
    $NewContacts += $NewContact

}

$Contacts | Export-Csv -Path "" -NoTypeInformation
$NewContacts | Export-Csv -Path "" -NoTypeInformation
