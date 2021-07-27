
# E-Mail settings
$scriptemail = ''
$SMSAddress = ''
$Email = ''
$smtpserver = ''
$Time = Get-Date -Format HH:mm
$date = Get-Date -Format "MM/dd/yyyy"
$hostname = Hostname

# Get Host Connected Subnets
Write-Host "Aquiring Subnets connected to $hostname" -fore cyan
$subnets = (Get-NetIPAddress -AddressFamily IPv4).IPAddress

# Trim last octet off subnet
$trimmedsubnets = @()
ForEach($subnet in $subnets){
    $octetrm = $subnet.LastIndexOf('.')
    $subnet = $subnet.Remove($octetrm)
    $trimmedsubnets += $subnet
}

# ICMP test ip addresses in subnets
$activeIps = @()
Write-Host "Subnets Found: $subnets" -ForegroundColor Cyan
ForEach($trimmedsubnet in $trimmedsubnets){
    $ip = 1
    While ($ip -ne 255){
        $device = "$trimmedsubnet.$ip"
        write-host "Testing $device..."
        If((Test-Connection -Count 1 -ComputerName $device -Quiet)){
            write-host "$device Active" -Fore Green -Back Black
            $activeIps += $device
        } 
        $ip++
    }
}

#test ports on all online IPs
$ports = @(21,22,23,25,53,69,109,110,111,135,137,138,139,445,1433,1434,3389,3481,5631)
$outputArray = @()
ForEach($activeIP in $activeIPs){
    write-host "Testing ports on $activeIP" -Fore Cyan -Back Black
    ForEach($port in $ports){
        $outputArray = "<tr><td>$activeIP</td><td><span style=color:Green;>online</span></td><td>$port</td></tr>"
        If(Test-NetConnection -ComputerName $activeIP -Port $port -InformationLevel Quiet){
            Write-Host "$activeIP Port $port open" -fore Green -BackgroundColor Black
            $outputArray += "<tr><td>$activeIP</td><td><span style=color:Green;>online</span></td><td>$port</td></tr>"
        }
    }
}

#E-Mail Setup
$devicecount = $activeIps.count
$body = "
<p>This is an automated report the following Devices and ports on $date </p>
<p>There are <span style=color:red;>$devicecount</span> devices on the same networks as $hostname as of $time</p>
<table style=width:300px>
<tr><th align='left'>Device</th><th align='left'>Status</th><th align='left'>Open Port</th></tr>
$outputArray
</table>
"

#file output to desktop
$Outputpath = "$($env:USERPROFILE)\Desktop\"
$body | Out-File $outputpath\netresults.html

#E-Mail Results
Send-MailMessage -From $scriptemail -To $Email -Subject 'Net Scan' -Body "$body" -BodyAsHtml -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer $smtpserver
