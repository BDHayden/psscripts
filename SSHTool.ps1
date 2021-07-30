#
#
#SSH Tool
#
#Writen by Brian Hayden
#
#
#requires


$Outputpath = "$($env:USERPROFILE)\Desktop\"
$date = Get-Date -Format "MM-dd-yy"

do{
clear
$promptA = Read-Host -Prompt "
Which Function would you like to perform?
0. Exit
1. SSH Custom Command
2. Get Device Config to desktop

"
switch ($promptA){
    1{
      $prompt1 = Read-Host -Prompt "
      Which Function would you like to perform?
      0. Back
      1. Run command on one machine
      2. Run command on multiple machines
      "
      Do{
      switch ($prompt1){
        1{
          $servername = Read-Host -Prompt "device IP"
          $username = Read-Host -Prompt "username for $servername"
          $password = Read-Host -Prompt "ssh password for $username"
          $command = Read-Host -Prompt "Enter Command here"
          #Execute SSH command
          echo y | plink.exe -pw $password $username@$servername $command
          Read-Host -Prompt "Press Enter to continue."
          $prompt1 = 0
         }
        2{
          $devices = @()
          $devcount = 1
          Do{
            $Device = Read-Host -Prompt "device #$devcount IP"
            $devices += $device
            $devcount++
            }
          While($device -ne ''){}
          $command = Read-Host -Prompt "Enter Command here"
          ForEach ($servername in $devices.where({ $_ -ne "" })){
            $username = Read-Host -Prompt "username for $servername"
            $password = Read-Host -Prompt "ssh password for $username" -AsSecureString
            echo y | plink.exe -pw $password $username@$servername $command
            }
           $prompt1 = 0
           }

        }
      }
      While($prompt1 -ne 0){}
      }#SSH Custom Command
    2{#Get Device Config to desktop
      $prompt1 = Read-Host -Prompt "
      Which Function would you like to perform?
      0. Back
      1. Run command on one machine
      2. Run command on multiple machines
      "
      Do{
      switch ($prompt1){
        1{
          $device = Read-Host -Prompt "device IP"
          $username = Read-Host -Prompt "username for $device"
          $password = Read-Host -Prompt "ssh password for $username"
          $command = 'show run'
          #Execute SSH command
          echo y | plink.exe -pw $password $username@$servername $command | Out-File $Outputpath\$device-Config_$date.txt -ErrorAction Inquire
          Write-Host "$Outputpath$device-Config_$date.txt"
          $ynprompt = Read-Host -Prompt "Open this File? [Y/N]"
          If($ynprompt -match "[yY]"){
            notepad.exe $Outputpath$device-Config_$date.txt
          }
          #Else{}
          $prompt1 = 0
         }
        2{
          $devices = @()
          $devcount = 1
          Do{
            $Device = Read-Host -Prompt "device #$devcount IP"
            $devices += $device
            $devcount++
            }
          While($device -ne ''){$devices }
          $command = 'show run'
          ForEach ($servername in $devices.where({ $_ -ne "" })){
            $username = Read-Host -Prompt "username for $servername"
            $password = Read-Host -Prompt "ssh password for $username"
            $output = echo y | plink.exe -pw $password $username@$servername $command | Out-File $Outputpath\$device-Config_$date.txt -ErrorAction Inquire
            Write-Host "$Outputpath$device-Config_$date.txt"
            $ynprompt = Read-Host -Prompt "Open this File? [Y/N]"
            }
          $prompt1 = 0
           }

        }
      }
      While($prompt1 -ne 0){}
     }#Get Device Config to desktop
}
}
while ($promptA -ne '0'){exit}
