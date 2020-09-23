<#
    .SYNOPSIS
        Test for existing of running process
#>

$Servers = Import-Csv -Path "Servers.csv"

$Results = @()

#$ProcessToCheck = "Spoolsv","svchost","System","NotePad"
$ProcessToCheck = "NotePad"

Foreach ($Server in $Servers) {

    $RemoteScript = {
        Param($Server,$ProcessToCheck)

        $ProcessesFound = Get-Process | Where-Object {$_.ProcessName -in $ProcessToCheck } | Select-Object -Unique
        
        $Result =  $Server | Select-Object ComputerName,
            @{N='ProcessExists';E={
                [Bool]$ProcessesFound
                }
            },
            @{N='Found';E={
                $ProcessesFound.ProcessName -join ";"
                }
            },
            @{N='FoundCount';E={
                $ProcessesFound | Measure-Object | ForEach-Object {$_.Count}
                }
            },
            @{N='Searched';E={
                $ProcessToCheck -join ";"
                }
            },
            @{N='SearchedCount';E={
                $ProcessToCheck | Measure-Object | ForEach-Object {$_.Count}
                }
            }
        
        $Result

    }

    $Results += Invoke-Command -ComputerName $Server.FullyQualifiedDomainName -ScriptBlock $RemoteScript -ArgumentList $Server, $ProcessToCheck | 
        Select-Object * -ExcludeProperty PSComputerName,RunspaceId 
}

$NowString = (get-date -Format s) -replace ":","."

$Results | Export-Csv -Path "$($NowString)_TestRunningProcessResults.csv"

Write-Host "Results 
    ServersTested: $($Results.Count) 
    Failed: $($Results | where-object {$_.ProcessExists} | Measure-Object | ForEach-Object {$_.Count})
    Passed: $($Results | where-object {!$_.ProcessExists} | Measure-Object | ForEach-Object {$_.Count})"

#$Results | Ogv