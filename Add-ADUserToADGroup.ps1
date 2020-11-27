[CmdletBinding()]
param (
    [Microsoft.ActiveDirectory.Management.ADUser[]]
    $ADUser,
    $JsonPath = "ADGroups.json",
    [System.Management.Automation.PSCredential]
    $Credential
)

#Load functons
. .\Functions.ps1

$JsonData = Get-JsonDataForADGroups -JsonPath $JsonPath

foreach ($ADUserObject in $ADUser) {
    $ADUserObject = Get-ADUser $ADUserObject.SamAccountName -Properties Office
    if ($ADUserObject.Office) {
         Write-Verbose -Message "Checking $($ADUserObject.SamAccountName) located in office of $($ADUserObject.Office)"
         $ADGroups = (Get-ADGroupsForUserAtSpecificOffice -JsonData $JsonData -ADOffice $ADUserObject.Office).Groups

         if ($ADGroups) {
             foreach ($ADGroupItem in $ADGroups) {
                 if (Test-ADGroup -ADGroup $ADGroupItem) {
                      Write-Verbose -Message "Adding $($ADUserObject.SamAccountName) to ADGroup $ADGroupItem..."
                      $AddAdGroupMemberParams = @{
                          Identity = $ADGroupItem
                          Members = $ADUserObject
                      }
                      if ($Credential) {
                        $AddAdGroupMemberOptionalParams = @{
                            Credential = $Credential
                        }
                        $AddAdGroupMemberParams += $AddAdGroupMemberOptionalParams
                      }
                      Add-AdGroupMember @AddAdGroupMemberParams
                 }
             }
         }
         else {
             Write-Verbose -Message "No ADGroups found for $($ADUserObject.Office)"
         }
    }
    else {
        Write-Verbose -Message "$($ADUserObject.SamAccountName) does not have a office defined! Skipping..."
    }
}