function Merge-AlternatingEnabledMemoryBlock {
    param (
        [string]$memory
    )
    $stateEnabled = $true
    
    $enabledMemory = ''
    
    while($memory.Length -gt 0){
        if ($stateEnabled) {
            $cond = "don't"
        } else {
            $cond = "do"
        }
        $pattern = "^.*($cond\(\)|$)(?<!$cond\(\).+)"
        
        $memorySegment = (Select-String -InputObject $memory -Pattern $pattern).Matches
        
        
        if ($stateEnabled) {
            $enabledMemory = [System.String]::Concat($enabledMemory, $memorySegment.Value)
        }
        
        $memory = $memory.Remove($memorySegment.Index, $memorySegment.Captures.Length)
        
        $stateEnabled = $stateEnabled -xor $true
    }
    $enabledMemory
}

function mul ([int]$a, [int]$b) {
    $a * $b
}

function Resolve-ValidMulOperation {
    [CmdletBinding()]
    param (
        # Provide a block of enabled memory
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $memory
    )
    
    begin {
        $ValidMulPattern = 'mul\((\d{1,3}),(\d{1,3})\)'
    }
    
    process {
        #(Select-String -InputObject $memory -Pattern $ValidMulPattern -CaseSensitive -AllMatches).Matches
        [regex]::Matches($memory, $ValidMulPattern) | ForEach-Object {[int]$($PSItem.Groups[1].Value) * [int]$($PSItem.Groups[2].Value)}
    }
    
    end {
        
    }
}

function Select-EnabledMemoryBlock {
    [CmdletBinding()]
    param (
        # Input block of memory
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $memory
    )
    
    begin {
        
    }
    
    process {
        ($memory -split 'do\(\)') -replace 'don''t\(\)(.|\n)*$', ''
    }
    
    end {
        
    }
}