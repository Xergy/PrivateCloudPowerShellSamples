<#
    .SYNOPSIS
        Gather VMM Host info    
#>

Get-SCVMMServer -ComputerName "PC-FabricMgmt01.forthcoffee.local"

$VMMHosts = Get-SCVMHost | Out-GridView -Title "Select Hosts..." -OutputMode Multiple

#$HostsFiltered[0] | fl *
#$HostsFiltered = $Null

$HostsFiltered = $VMMHosts | Select-Object -Property ComputerName,FullyQualifiedDomainName,DomainName,VMHostGroup,HostCluster,OverallState,ClusterNodeStatus,Description

$HostsFiltered | Export-Csv -Path "Servers.csv" -Force -NoTypeInformation
