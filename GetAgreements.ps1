<#
Example of getting Agreements per Company and creating your own report style
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
$Counter1 = 1
$Companies = @()
$Agreements = @()
$CompaniesInfo =@()
$AgreementsInfo = @()

$Header = @{
        'Accept' = 'application/json'
        'Authorization' = "Basic ${Base64}"
        'Content-Type' = 'application/json'
        'ClientID' = "${ClientID}"
}


Write-Output "Getting Companies"
do {

    $CompanyURl = $BaseUrl + "/company/companies?conditions=status/name='active' &pagesize=1000&page=$Counter"
    $CompanyResults = Invoke-RestMethod -Uri $CompanyURL -Headers $Header -Method Get
    $Companies += $CompanyResults
    $Counter++

}until ($CompanyResults.Length -eq 0)

#I seperate out here as Connectwise does not let you use type/name= as a condition when I was testing.
$TMCompanies = $Companies | Where-Object {$_.Types.Name -notcontains "Internal" -and $_.Types.Name -notcontains "Vendor" -and $_.Types.Name -notcontains "Prospect" -and $_.Types.Name -notcontains "Not a Fit"}

Write-Output "Getting Agreements"
do {

    $AgreementsURl = $BaseUrl + "/finance/agreements?conditions=agreementStatus='Active'&pagesize=1000&page=$Counter1"
    $AgreementsResults = Invoke-RestMethod -Uri $AgreementsURl -Headers $Header -Method Get
    $Agreements += $AgreementsResults
    $Counter1++

}until ($AgreementsResults.Length -eq 0)

#Seperating out all Agreements with T&M in the name
$TMAgreements = $Agreements | Where-Object {$_.type.name -contains "T&M"}

#Building out my own object for cleaner exports
Foreach ($Company in $TMCompanies) {

    $CompanyInfo = new-object PSObject 
    $CompanyInfo | add-member -membertype NoteProperty -name "Customer" -Value $Company.Name
    $CompanyInfo | add-member -membertype NoteProperty -name "Identifier" -Value $Company.Identifier
    $CompanyInfo | add-member -membertype NoteProperty -name "ID" -Value $Company.ID
    $CompanyInfo | add-member -membertype NoteProperty -name "Default Contact" -Value $Company.defaultContact.Name
    $CompanyInfo | add-member -membertype NoteProperty -name "Account Number" -Value $Company.defaultContact.Name
    $CompaniesInfo += $CompanyInfo
}

#Building out my own object for cleaner exports
Foreach ($Agreement in $TMAgreements) {

    $AgreementInfo = new-object PSObject 
    $AgreementInfo | add-member -membertype NoteProperty -name "Customer" -Value $Agreement.company.name
    $AgreementInfo | add-member -membertype NoteProperty -name "Name" -Value $Agreement.name
    $AgreementInfo | add-member -membertype NoteProperty -name "Type" -Value $Agreement.type.name
    $AgreementInfo | add-member -membertype NoteProperty -name "End Date" -Value $Agreement.endDate
    $AgreementsInfo += $AgreementInfo
}

#Exprots of original data and cleaned upversions
$TMCompanies | Export-Csv -Path "" -NoTypeInformation
$TMAgreements | Export-Csv -Path "" -NoTypeInformation
$CompaniesInfo | Export-Csv -Path "" -NoTypeInformation
$AgreementsInfo | Export-Csv -Path "" -NoTypeInformation
