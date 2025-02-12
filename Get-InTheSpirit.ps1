[CmdletBinding()]
param (

    [Parameter(Mandatory=$true, Position=0)]
    [String]
    [ValidateLength(2,3)]
    [ValidateNotNullOrEmpty]
    [ValidatePattern('\d\d?[abv]')]
    $puzzle,

    [switch]$validate
)


# Determine and verify solution path
$solution = "$PSScriptRoot/solution/$puzzle.ps1"

if (Test-Path $solution) {
    Write-Output "$([System.String]::Format("|*** {0} [{1,3}] ***|", @("Let's Go", $puzzle)))"
    Write-Debug "File exists: [<$solution>]"
} else {
    Write-Error "File does not exist: [<$solution>]"
}

# Determine and verify puzzle Input path
$dayNumeral = (Select-String -InputObject "$puzzle" -Pattern "[0-9]{1,2}").Matches.Value
Write-Debug "Calendar Day Numeral: $dayNumeral"

if ($validate) {
    $puzzleinput = "$PSScriptRoot/validation/$dayNumeral.txt"
} else {
    $puzzleinput = "$PSScriptRoot/puzzle/$dayNumeral.txt"   
}

if (Test-Path $puzzleinput) {
    Write-Debug "File exists: [<$puzzleinput>]"
} else {
    Write-Error "File does not exist: [<$puzzleinput>]"
}

Invoke-Expression -Command "$solution $puzzleInput"

if ($validate) {
    $assertionPath = "$PSScriptRoot/assertion/$puzzle.txt"
    if (Test-Path $assertionPath) {
        Write-Debug "File exists: [<$assertionPath>]"
    } else {
        Write-Error "File does not exist: [<$assertionPath>]"
    }
}