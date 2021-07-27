
#E-Mail settings
   $scriptemail = ''
    $SMSAddress = ''
         $Email = ''
    $smtpserver = ''
          $Time = Get-Date -Format HH:mm
          $date = Get-Date -Format "MM/dd/yyyy"
      $hostname = Hostname
#temporary Files
$tmpA = New-TemporaryFile
$tmpB = New-TemporaryFile
$tmpC = New-TemporaryFile
$tmpD = New-TemporaryFile

#Get Host Connected Subnets
Write-Host "Aquiring Subnets connected to $hostname" -fore cyan
(Get-NetIPAddress -AddressFamily IPv4).IPAddress | Out-File $tmpA.FullName

$HostNets = Get-Content $tmpA.FullName
ForEach($HostNet in $HostNets){
  $string = $HostNet
  $octetrm = $string.LastIndexOf('.')
  $hostnet = $string.Remove($octetrm)
  echo $hostnet | Out-File $tmpB.FullName -Append
}

#ICMP test ip addresses in subnets
$subnets = Get-Content $tmpB
Write-Host "Subnets Found: $subnets" -ForegroundColor Cyan
ForEach($subnet in $subnets){
  $ip = 1
  While ($ip -ne 255){
    $device = "$subnet.$ip"
    write-host "Testing $device..."
    If((Test-Connection -Count 1 -ComputerName $device -Quiet)){
    write-host "$device Active" -Fore Green -Back Black
    echo $device | Out-File $tmpC.FullName -Append
    } $ip++
  }
}

#test ports on all online IPs
$activeIPs = Get-Content $tmpC
$ports = @(21,22,23,25,53,69,109,110,111,135,137,138,139,445,1433,1434,3389,3481,5631)
ForEach($activeIP in $activeIPs){
  write-host "Testing ports on $activeIP" -Fore Cyan -Back Black
  ForEach($port in $ports){
    $outfileP = "<tr><td>$activeIP</td><td><span style=color:Green;>online</span></td><td>$port</td></tr>"
    If(Test-NetConnection -ComputerName $activeIP -Port $port -InformationLevel Quiet){
      Write-Host "$activeIP Port $port open" -fore Green -BackgroundColor Black
      $outfileP | Out-File $tmpd.FullName -Append
      }
  }
}

#E-Mail Setup
$devicecount = $activeIPs.count
$output = Get-Content $tmpD
$body = "
<p>This is an automated report the following Devices and ports on $date </p>
<p>There are <span style=color:red;>$devicecount</span> devices on the same networks as $hostname as of $time</p>
<table style=width:300px>
<tr><th align='left'>Device</th><th align='left'>Status</th><th align='left'>Open Port</th></tr>
$output
</table>
"

#file output to desktop
$Outputpath = "$($env:USERPROFILE)\Desktop\"
$body | Out-File $outputpath\netresults.html

#E-Mail Results
Send-MailMessage -From $scriptemail -To $Email -Subject 'Net Scan' -Body "$body" -BodyAsHtml -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer $smtpserver
