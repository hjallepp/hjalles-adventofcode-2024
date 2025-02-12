[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $puzzleInputPath,

    [Parameter(Mandatory=$false, Position=1)]
    [string]
    $validationInputPath
)

# Import puzzle data as an array of strings, each line is one report.
[string[]]$puzzleInput = Get-Content -Path $puzzleInputPath
Write-Output "Imported $($puzzleInput.Count) [$($puzzleInput[0].GetType())]reports`n"

$reportCount = 0

[int[]]$reportSafetyRecord = $puzzleInput | ForEach-Object {
    # FOR EACH REPORT
    # Break each report into arrays of ints (split with space-character)
    [int[]]$report = $PSItem.Split(' ')
    
    # Determine reference inclination firstLevel -lt nextAdjacentLevel
    [bool]$isIncreasing = $report[0] -lt $report[1]
    
    Write-Verbose "GENERATE: [$($report.GetType())]report: $report"
    Write-Verbose "Incline reference: $isIncreasing"
    
    # Report is assumed to be SAFE
    $safetyState = 1
    
    # Set initial Problem Dampener components
    [int]$problemDampenerStep = 0
    [System.Collections.Generic.List[int[]]]$problemDampenerBuffer = @(@(), @(), @())
    
    # Loop through levels of report between indexes {0 - (last -1)}
    [int[]]$reportSafetyStaging = $report
    for ($i = 0; $i -lt $reportSafetyStaging.Count-1; $i++) {
        # Create placeholder for readability
        $currentLevel = $reportSafetyStaging[$i]
        $nextAdjacentLevel = $reportSafetyStaging[$i+1]

        Write-Verbose "VERIFY COMPLIANCE: report levels $currentLevel and $nextAdjacentLevel"

        # Determine difference and incline for current and next adjacent level
        $difference = [System.Math]::Abs($currentLevel - $nextAdjacentLevel)
        $incline = ($currentLevel -lt $nextAdjacentLevel)

        # Verify Rule Compliance
        if (($incline -ne $isIncreasing) -or ($difference -lt 1) -or ($difference -gt 3)) {
            Write-Verbose "COMPLIANCE ERROR: report levels $currentLevel and $nextAdjacentLevel (Incline $incline : Difference $difference)"
            
            # Perform ProblemDampener actions
            if ($problemDampenerStep -eq 0) {
                # Copy report into three separate modified versions and assign them to problemDampenerBuffer
                if ($i -eq 0) {
                    #There is no level to our left
                    $problemDampenerBuffer[0] = [int[]]@(0,100)
                } else {
                    [System.Collections.Generic.List[int]]$copyA = $report
                    $copyA.removeAt($i-1)
                    $problemDampenerBuffer[0] = [int[]]$copyA
                }
                [System.Collections.Generic.List[int]]$copyB = $report
                $copyB.removeAt($i)
                $problemDampenerBuffer[1] = [int[]]$copyB
                [System.Collections.Generic.List[int]]$copyC = $report
                $copyC.removeAt($i+1)
                $problemDampenerBuffer[2] = [int[]]$copyC
                
                Write-Verbose "POPULATE: [$($problemDampenerBuffer.GetType())]problemDampenerBuffer($($problemDampenerBuffer.Count)) : [$($problemDampenerBuffer[0].GetType())]$($problemDampenerBuffer[0]) : [$($problemDampenerBuffer[1].GetType())]$($problemDampenerBuffer[1]) : [$($problemDampenerBuffer[2].GetType())]$($problemDampenerBuffer[2])"
            }
            if ($problemDampenerStep -eq $problemDampenerBuffer.Count) {
                # Report is determined as UNSAFE
                Write-Verbose "ProblemDampener unsuccessful"
                $safetyState = 0
                break
            }
            # ProblemDampener is active but cycle is neither on first or last attempt, replace
            $reportSafetyStaging = $problemDampenerBuffer[$problemDampenerStep]
            $isIncreasing = $reportSafetyStaging[0] -lt $reportSafetyStaging[1]
            Write-Verbose "DAMPENING ATTEMPT($problemDampenerStep): $reportSafetyStaging (Incline Updated: $isIncreasing)"
            $i = -1
            $problemDampenerStep += 1
        }
    }

    # Loop was successful
    Write-Verbose "REPORT $reportCount VERIFIED: exitcode $safetyState`n"
    $reportCount += 1
    $safetyState
}

Write-Verbose "reportSafetyRecord $($reportSafetyRecord.Count)"

if ($validationInputPath) {
    # Validate results using provided reference
    [int[]]$validationReference = Get-Content -Path $validationInputPath
    Write-Output "Comparing`n$($validationReference.GetType())validationReference ($($validationReference.Count))`n$($reportSafetyRecord.GetType())reportSafetyRecord ($($reportSafetyRecord.Count))"

    if ($reportSafetyRecord.Count -eq $validationReference.Count) {
        foreach ($i in $(0..($reportSafetyRecord.Count - 1))) {
            if ($reportSafetyRecord[$i] -ne $validationReference[$i]) {
                Write-Output "Validation failed at report $i : Has $($reportSafetyRecord[$i]) expects $($validationReference[$i])"
            }
        }
    } else {
        Write-Output "VALIDATION FAILED DUE TO COUNT DISCREPANCY"
    }
}

Write-Verbose "Final count of safe reports:"
($reportSafetyRecord | Measure-Object -Sum) | Select-Object -ExpandProperty Sum
