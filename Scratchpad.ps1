

                $RemoteScript = {
                    hostname
                    Get-Date
                    Start-Sleep -s 2
                }

                
                $RemoteResult = Invoke-Command -ComputerName $Server.ComputerName -ScriptBlock $RemoteScript
                $RemoteResult  


                $ProcessToCheck = "Spoolsv","svchost","System","NotePad"
                $ProcessesFound = Get-Process | Where-Object {$_.ProcessName -in $ProcessToCheck } | Select-Object -Unique


            $RemoteScript = {

                $ProcessToCheck = "Spoolsv","svchost","System","NotePad"
                $ProcessesFound = Get-Process | Where-Object {$_.ProcessName -in $ProcessToCheck } | Select-Object -Unique
                
                $obj = new-object psobject                                             

                $Result =  "" | Select-object -Property @{N='ProcessExists';E={
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
        
            $Results += Invoke-Command -ComputerName $Server.ComputerName -ScriptBlock $RemoteScript 

                $ProcessToCheck = "Spoolsv","svchost","System","NotePad"
                $ProcessesFound = Get-Process | Where-Object {$_.ProcessName -in $ProcessToCheck } | Select-Object -Unique
                
                $obj = new-object psobject                                             

                $Result =  "" | Select-object -Property @{N='ProcessExists';E={
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
        
            $Results += Invoke-Command -ComputerName $Server.ComputerName -ScriptBlock $RemoteScript | Select -Exclude PSComputerName,Runspace 


            $JobsResults.Results | ogv