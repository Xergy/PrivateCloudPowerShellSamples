<#
    .SYNOPSIS
        Grabs all assigned primary Host network adaptor IPs     
#>

Get-SCVMMServer -ComputerName "PC-FabricMgmt01.forthcoffee.local"

$HostsFiltered = Get-SCVMHost | Out-GridView -Title "Select Hosts..." -OutputMode Multiple

$NicsWithHostInfo = @()
$NicsWithHostInfo = $HostsFiltered | ForEach-Object {
    $CurrentVM = $_

    $CurrentVM | 
        Get-SCVMHostNetworkAdapter | Select-Object *,
        @{N='IPAddress';E={
                $_.IPAddresses[0].IPAddressToString
            } 
        },
        @{N='Host';E={
                $CurrentVM.ComputerName
            } 
        },
        @{N='VMHostGroup';E={
                $CurrentVM.VMHostGroup 
            } 
        },
        @{N='HostCluster';E={
                $CurrentVM.HostCluster 
            } 
        }
} 
 
$NicsFiltered = $NicsWithHostInfo | Select-Object "VMHostGroup","HostCluster","Host","Name","IPAddress"

$NowString = (Get-Date -Format s) -replace ":","."

$NicsFiltered | Export-Csv -Path "$($NowString)_HostNicPrimaryIPs.csv" -NoTypeInformation