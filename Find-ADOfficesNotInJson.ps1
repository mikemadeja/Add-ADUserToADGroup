param (
    $JsonPath = "ADGroups.json",
    [Parameter(Mandatory=$true)]
    $SearchBase
)

#Load functons
. .\Functions.ps1
$OfficesMissingInJsonThatAreInAD = @()

$ADUsers = Get-ADuser -SearchBase $SearchBase -Properties Office -Filter *

$JsonData = Get-JsonDataForADGroups -JsonPath $JsonPath

$CompareObject = Compare-Object $ADUsers $JsonData -Property Office

$CompareObject = $CompareObject | Where-Object { $_.SideIndicator -eq "<=" }

foreach ($CompareObjectItem in $CompareObject) {
    if ($CompareObjectItem.Office) {
        Write-Verbose -Message "Found $($CompareObjectItem.Office) exists in AD but not in the JSON file"
        $OfficeNotInJson = [PSCustomObject]@{
            OfficeInAD = $CompareObjectItem.Office
            ExistInJson = $false
            }
            $OfficesMissingInJsonThatAreInAD += $OfficeNotInJson
    }
    else {
        Write-Verbose -Message "Found a office this is null. Skipping..."
        Write-Verbose -Message "If you want to find users with null as office, do "
        Write-Verbose -Message "Get-ADUser -SearchBase '$SearchBase' -Property Office -Filter { Office -notlike '*' } | Select-Object SamAccountName, Office"
    }
}

Write-Output $OfficesMissingInJsonThatAreInAD
