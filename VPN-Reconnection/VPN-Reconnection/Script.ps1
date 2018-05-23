$vpnName = "<VPN Name>";
    $vpn = Get-VpnConnection -Name $vpnName;
    while($vpn.ConnectionStatus -eq "Disconnected"){
    rasdial $vpnName "username" "password";
    Start-Sleep -Seconds 120
    }

#Disconnect Event ID
#rasman
#20268
#System