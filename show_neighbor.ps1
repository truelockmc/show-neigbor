$(Get-NetIPAddress | where-object {$_.PrefixLength -eq "24"}).IPAddress | Where-Object {$_ -like "*.*"} | % { 
    $netip="$($([IPAddress]$_).GetAddressBytes()[0]).$($([IPAddress]$_).GetAddressBytes()[1]).$($([IPAddress]$_).GetAddressBytes()[2])"
    write-host "`n`nping C-Subnet $netip.1-254 ...`n"
    1..254 | % { 
        (New-Object System.Net.NetworkInformation.Ping).SendPingAsync("$netip.$_","1000") | Out-Null
    }
}
#warte bis arp-cache: complete
while ($(Get-NetNeighbor).state -eq "incomplete") {write-host "waiting";timeout 1 | out-null}
#Hostname hinzufügen und Ergebnis anzeigen 
Get-NetNeighbor | Where-Object -Property state -ne Unreachable | where-object -property state -ne Permanent | select IPaddress,LinkLayerAddress,State, @{n="Hostname"; e={(Resolve-DnsName $_.IPaddress).NameHost}} | Out-GridView