<#
    .SYNOPSIS
        Run Server Focused Script Blocks with Thottled Jobs
#>

$Servers = Import-Csv -Path "Servers.csv" # Reqiures "ComputerName" Property

$HostInput = Read-Host "Filter Servers (Y,N)"
If ($HostInput -eq "Y") {
    $Servers = $Servers | Out-Gridview -Title "Select Servers to Filter..." -OutputMode Multiple
}

If (!$Servers ) {
    Write-host "No Servers Found Exiting!"
}

$HostInput = Read-Host "$($Servers.count) Servers Selected, Proceed (Y,N)"
If ($HostInput -ne "Y") {
    Write-host "Exiting!"
    Exit
}

# Start Timer
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

$NowString = (get-date -Format s) -replace ":","."

$maxConcurrentJobs = 4 

$Jobs = @()

foreach($Server in $Servers) { #Where $Objects is a collection of objects to process. It may be a computers list, for example.
    Write-Host "$(get-date -Format s) Processing $($Server.ComputerName)..."
    $Check = $false #Variable to allow endless looping until the number of running jobs will be less than $maxConcurrentJobs.
    while ($Check -eq $false) {
        if ((Get-Job -State 'Running').Count -lt $maxConcurrentJobs) {
            $ScriptBlock = {
                Param($Server)
                
                $RemoteScript = {
                    Param($Server)
                    $ProcessToCheck = "Spoolsv","svchost","System","NotePad"
                    $ProcessesFound = Get-Process | Where-Object {$_.ProcessName -in $ProcessToCheck } | Select-Object -Unique
    
                    $RemoteResult =  $Server | Select-object -Property ComputerName,
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
                    
                    $RemoteResult
            
                }     
                
                $RemoteResult = Invoke-Command -ComputerName $Server.ComputerName -ScriptBlock $RemoteScript -ArgumentList $Server 
                $RemoteResult             

            }
            Write-Host "$(get-date -Format s) Starting New Job... "
            $JobObject = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $Server 
            $Job = "" | Select-Object -Property @{N='ComputerName';E={
                    $Server.ComputerName
                    }
                },
                @{N='Job';E={
                    $JobObject
                    }
                }                
            $Check = $true #To stop endless looping and proceed to the next object in the list.            
        } Else {
            Write-Host "$(get-date -Format s) Waiting for Jobs to finish..."
            Start-Sleep -s 2
        }
     }

     $Jobs += $Job 
}

Write-Host "$(get-date -Format s) Waiting for ALL Jobs to Complete..."
$Jobs | Wait-Job | Out-Null

Write-Host "$(get-date -Format s) Processing ALL Results..."
$JobsResults = $Jobs | ForEach-Object {

    $obj = [PSCustomObject]@{
        Job = $_.Job
        State = $_.Job.State
        Results = $_.Job | Receive-Job
        ComputerName = $_.ComputerName
        }
    
    $obj
}

$NowString = (get-date -Format s) -replace ":","."

$JobsResults | Export-Clixml -Path "$($NowString)_JobsResults.xml"

$JobsResults | ForEach-Object {
    "`n====================================" | Out-File -FilePath "$($NowString)_JobsResultsLogstream.txt" -Append 
    "RemoteServer = $($_.ComputerName)" | Out-File -FilePath "$($NowString)_JobsResultsLogstream.txt" -Append
    "State = $($_.State)" | Out-File -FilePath "$($NowString)_JobsResultsLogstream.txt" -Append     
    "====================================" | Out-File -FilePath "$($NowString)_JobsResultsLogstream.txt" -Append 
    $CurrentResults = $_.Results

    $CurrentResults | ForEach-Object {
        "$($_)" | Out-File -FilePath "$($NowString)_JobsResultsLogstream.txt" -Append 
    }    
}

Write-Host "$(get-date -Format s) Done! Total Elapsed Time: $($elapsed.Elapsed.ToString())" 
$elapsed.Stop()

#$JobsResults.Results | ogv



