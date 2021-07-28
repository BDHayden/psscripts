#
# User Tracker Tool
#
#
#
# Written by Brian Hayden
#
#

do{
clear
$prompt1 = Read-Host -Prompt "
Which Function would you like to perform?
0. Exit
1. Find Computer user is logged onto
2. Find which Users are logged into a Computer
3. Log User out of a Computer
"
switch ($prompt1)
{
    1 { #Find Computer user is logged onto (gets ad computers and checks them for the specified user as logged on)
        $Computers = @()
        $Getad = Get-ADObject -LDAPFilter objectclass=computer -Properties name -SearchBase "OU=Computers,DC=domain,DC=com" 
        $Computers += $Getad.name
        $adpccount = $Computers.Count
        $user = Read-Host -Prompt "Which user?"
        $loggedonpcs = @()
        $pcnum = 1
        ForEach ($computer in $Computers){
          Write-Progress -Activity "Searching PCs for $user logged on" -Status "Progress:" -PercentComplete ($pcnum/$adpccount*100)
          #Write-host "Checking PC $pcnum" 
          $explorerInstance = Get-WmiObject -Class Win32_Process -ComputerName $computer -ErrorAction SilentlyContinue | Where-Object -Property name -EQ -Value 'explorer.exe'
          $pcnum++

          ForEach ($Instance in $explorerInstance){
            $ownerInfo = $Instance.GetOwner()
                $hash = @{
                Domain       = $ownerInfo.Domain
                Username     = $ownerInfo.User
                ComputerName = $computer
                }
          }
          If($ownerInfo.user -eq $user){ $loggedonpcs += $computer }
          }
        clear
        Write-Host "Checked $pcnum hosts for $user logged in.
        $user is logged in on the following machine(s):"
        $loggedonpcs
        read-host “Press ENTER to continue...”
      }
    2 { #Find which Users are logged into a Computer
        $Computer = Read-Host -Prompt "Which Computer?"
        query user /server:$Computer
        read-host “Press ENTER to continue...”
      }
    3 { #Log User out of a Computer
        $Computer = Read-Host -Prompt "Which Computer?"
        query user /server:$Computer
        $userID = Read-Host -Prompt "Please input the proper user ID" 
        logoff /server:$computer $userID
        read-host “Press ENTER to continue...”
      }
}
}
while ($prompt1 -ne '0'){exit}
