function Get-JsonDataForADGroups {
    <#
    .SYNOPSIS
        This is a function to get the JSON data of Office and Groups and convert it to a PowerShell object

    .PARAMETER JsonPath
        JsonPath will be the path of the Json file

    .LINK
        Links to further documentation.
    #>
    [CmdletBinding()]
    param (
        $JsonPath
    )
    if (Test-Path -Path $JsonPath) {
        $JsonData = (Get-Content -Path $JsonPath | ConvertFrom-Json).ADGroups
        Write-Output $JsonData
    }
    else {
        Write-Error -Message "Json file missing or not correct" -ErrorAction Stop
    }
}

function Get-ADGroupsForUserAtSpecificOffice {
    <#
    .SYNOPSIS
        This is a function will get the specific AD Groups for a specific Office 

    .PARAMETER JsonData
        JsonData will be the output of Get-JsonDataForADGroups

    .PARAMETER ADOffice
        ADOffice will be the Office attribute of a ADUser
    .LINK
        Links to further documentation.
    #>
    [CmdletBinding()]
    param (
        $JsonData,
        $ADOffice
    )
    $JsonDataOutput = $JsonData | Where-Object { $_.Office -eq $ADOffice}

    if ($JsonData) {
        Write-Output $JsonDataOutput
    }
    else {
        Write-Error -Message "No Json data for Office called $ADOffice"
    }
}

function Test-ADGroup {
    <#
    .SYNOPSIS
        This is a function to just test a AD Group from to see if it exists in AD, it returns a true or false

    .PARAMETER ADGroup
        ADGroup will be pulled from the Json File paramter of the script itself

    .LINK
        Links to further documentation.
    #>
     [CmdletBinding()]
     param (
         $ADGroup
     )
     try {
         $ADGroupOutput = Get-ADGroup $ADGroup -ErrorAction SilentlyContinue
         Write-Verbose -Message "AD Group $ADGroup found..."
        
     }
     catch {
         Write-Verbose -Message "AD Group $ADGroup not found..."

     }
     finally {
         if ($ADGroupOutput) {
             Write-Output $true
         }
         else {
             Write-Output $false
         }
     }
}

