[CmdletBinding()]
param (
    $JsonPath = "ADGroups.json",
    $ShowOnlyGroupsThatAreInTheJsonButNotInAD = $false
)

#Load functons
. .\Functions.ps1

$JsonData = Get-JsonDataForADGroups -JsonPath $JsonPath
$OfficeADGroupObjectFinal = @()

foreach ($JsonDataItem in $JsonData) {
    Write-Verbose -Message "Checking ADGroups for office $($JsonDataItem.Office) in Json..."
    foreach ($ADGroup in $JsonDataItem.Groups)  {
        Write-Verbose -Message "Checking AD Group called $ADGroup"
        $OfficeADGroupObject = [PSCustomObject]@{
        OfficeInJson = $JsonDataItem.Office
        ADGroupInJson = $ADGroup
        ValidGroupInAD = (Test-ADGroup -ADGroup $ADGroup)
        }
        $OfficeADGroupObjectFinal += $OfficeADGroupObject
    }
}

if ($ShowOnlyGroupsThatAreInTheJsonButNotInAD) {
    Write-Output $OfficeADGroupObjectFinal | Where-Object { $_.ValidGroupInAD -eq $false }
}
else {
    Write-Output $OfficeADGroupObjectFinal
}

