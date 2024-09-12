# Show Neighbor (PowerShell Script)

This PowerShell script is designed to ping all IP addresses within a `/24` subnet, wait for the ARP cache to populate, and then display the neighbors' IP addresses, MAC addresses, and hostnames. It provides an easy way to discover devices in the local subnet.

## Features

- Pings all IP addresses in the current `/24` subnet (based on the system's local IP).
- Waits for the ARP cache to fully populate before processing.
- Displays results, including the IP, MAC address, and hostname of each reachable neighbor.
- Outputs the results in a user-friendly grid view for easy inspection.

## How It Works

1. The script retrieves the system's local IP address and subnet mask.
2. It calculates the network IP and pings every IP in the subnet (from `.1` to `.254`).
3. After the pings, it waits for the ARP cache to complete.
4. The script then retrieves the neighbor information (IP, MAC, state) and resolves hostnames using DNS.
5. Finally, it displays the result in a grid view.

## Installation

1. Clone this repository:

    ```bash
    git clone https://github.com/truelockmc/show-neighbor.git
    cd show-neighbor
    ```

2. Make sure PowerShell is installed on your system. The script is compatible with Windows PowerShell.

## Usage

Run the Start.bat script

## Script Breakdown

- **Ping Subnet:**
  
    The script pings all IP addresses in the `/24` subnet derived from your local machine's IP.

    ```powershell
    $netip="$($([IPAddress]$_).GetAddressBytes()[0]).$($([IPAddress]$_).GetAddressBytes()[1]).$($([IPAddress]$_).GetAddressBytes()[2])"
    ```

    It then pings all addresses from `.1` to `.254`:

    ```powershell
    1..254 | % { 
        (New-Object System.Net.NetworkInformation.Ping).SendPingAsync("$netip.$_","1000") | Out-Null
    }
    ```

- **Wait for ARP Cache:**

    The script waits until all ARP entries are populated before proceeding:

    ```powershell
    while ($(Get-NetNeighbor).state -eq "incomplete") {write-host "waiting";timeout 1 | out-null}
    ```

- **Display Neighbor Information:**

    After ARP population, the neighbors' IP addresses, MAC addresses, and hostnames are displayed in a grid view:

    ```powershell
    Get-NetNeighbor | Where-Object -Property state -ne Unreachable | 
        where-object -property state -ne Permanent | 
        select IPaddress,LinkLayerAddress,State, 
        @{n="Hostname"; e={(Resolve-DnsName $_.IPaddress).NameHost}} | Out-GridView
    ```

## Requirements

- **PowerShell** (Windows PowerShell or PowerShell Core).
- Administrative privileges to run network-related PowerShell cmdlets (e.g., `Get-NetIPAddress`, `Get-NetNeighbor`).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
