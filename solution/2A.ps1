[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $puzzleInputPath
)

# $input = '.\validation2.txt'

# $input = '.\puzzle_input2-1.txt'

# Import puzzle data as an array of strings, each line is one report.
[string[]]$puzzleInput = Get-Content -Path $puzzleInputPath
Write-Verbose "Imported $($puzzleInput.Count) reports of type $($puzzleInput[0].GetType())"

$verifiedReports = $puzzleInput | ForEach-Object {
    # Break each report into arrays of ints (split with space-character)
    [int[]]$report = $PSItem.Split(' ')
    Write-Verbose "Report split into object of type $($report.GetType()), content: $report"

    # For each report:
    # Set $isIncreasing equal to the value of item0 -lt item1
    [bool]$isIncreasing = $report[0] -lt $report[1]
    Write-Verbose "$('$report[0] -lt $report[1] evaluates to: ' + "$isIncreasing")"
    
    
    # open loop of all items in report, for each step of the loop:
    [int]$limit = $report.Count-2
    [int[]]$indexes = (0..$limit)
    
    # break with succeess (return 1) if loop reached the end
    $result = 1
    foreach ($i in $indexes) {
        # break with failure (return 0) if:
        # result of item < next_item != $isIncreasing
        if (($report[$i] -lt $report[$i+1]) -ne $isIncreasing) {
            Write-Verbose "Criteria missmatch, $($report[$i]) -lt $($report[$i+1]) does not evaluate to $isIncreasing"
            $result = 0
            break
        }
        # difference of adjacent items fall OUTSIDE 1 <= |item - next_item| <= 3
        $difference = [System.Math]::Abs($report[$i] - $report[$i+1])
        if (($difference -lt 1) -or ($difference -gt 3)) {
            Write-Verbose "Criteria missmatch $($report[$i]) - $($report[$i+1]) equals $difference"
            $result = 0
            break
        }
    }
    # Safe reports return 1, unsafe return 0, sum of output represent answer
    Write-Verbose "Result is $result"
    $result
}
$numberOfSafeReports = 0
foreach ($tally in $verifiedReports) {
    $numberOfSafeReports += $tally
}
Write-Verbose "Final count of safe reports is $numberOfSafeReports"
$numberOfSafeReports
