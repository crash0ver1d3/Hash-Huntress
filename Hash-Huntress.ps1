##############################################################################
#  Script: Hash-Huntress.ps1
#    Date: 2021.03.20
# Version: 3.5
#  Author: Blake Regan @crash0ver1d3
# Purpose: Hunt for files hash or process hash matching IOCs you provide, at scale across domain.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
#NOTE: This script requires Windows RM to be enabled and run with an account with elevated privileges on target for domain use.
#By default, this will work with a account that is a memeber of the local administrators group on the targets
#If you do not want to use domain admin to perform this, you can establish a lower privilege domain account as a member of local adminisrators using 
#Restricted groups and applying via Group Policy


 
function Hash-Huntress {

   

#Starts transcript, to capture output to review later in IR phases
$timestamp=(Get-Date -UFormat "%Y%m%d_%H-%M-%S")
$TranscriptFile=(Get-item ".\").FullName + "\Hash-Huntress_Transcript$timestamp.txt"

#start transcription to defined file with timestamp. Allows multiple unique files to be stored in same directory
Start-Transcript -Path $TranscriptFile

#start defintion of script block, to be passed via the Invoke-Command -ScriptBlock command
#allows locally defined criteria to be passed to remote host(s)
$Hash_Huntress ={

#Define Path1 and Hash1 to search for, and gather hashes to loop through from specified directory. SHA-256 is default Algo
$IOCPath1="C:\Users\Public\Downloads"
$IOCHash1="23A243A1CE474C4DA90B1003FFCBAF9A3FF25E0787844BFE74C21671FDD8B269"

#verify if $IOCPath1 exists, and if so gather hashes and store to array, if not, notify and move on, set $IOCPath1_Check to false
if (Test-Path -Path $IOCPath1)
{
    write-host
    write-host "Path $IOCPath1 exists, continuing..."
    $IOC1DirContents=(dir -Path $IOCPath1 | Get-FileHash)
}
#If path does not exists on host, skip attempts to process
else
{
    write-host
    write-host "Path $IOCPath1 does not exist, skipping..."
    $IOCPath1_Check=$false
}

#Enumerate through each hashed file in the specified directory, and compare for match
if (!($IOCPath1_Check))
{
    #For each of the hashes contained in the defined directory
    foreach ($IOC1DirContentHash in $IOC1DirContents)
    {
        
        #Evaluate whether current element in the array matches the defined IOC, if true declare match and identify path and filename, and host
        if ($IOC1DirContentHash.Hash -eq $IOCHash1)
        {
            
            write-host
            write-host "$($IOC1DirContentHash.Hash) matches IOC1!!! Discovered $($IOC1DirContentHash.Path) on $ServerName"
        }
    
    }

}

#Define Path2 and Hash2 to search for and gather hashes to loop through from specified directory. SHA-256 is default Algo
$IOCPath2="C:\Windows\system32"
$IOCHash2 = "E9E646A9DBA31A8E3DEBF4202ED34B0B22C483F1ACA75FFA43E684CB417837FA"


#verify if $IOCPath2 exists, and if so gather hashes and store to array, if not, notify and move on, set $IOCPath2_Check to false
if (Test-Path -Path $IOCPath2)
{
    write-host
    write-host "Path $IOCPath2 exists, continuing..."
    $IOC2DirContents=(dir -Path $IOCPath2 | Get-FileHash)
}
#If path does not exists on host, skip attempts to process
else
{
    write-host
    write-host "Path $IOCPath2 does not exist, skipping..."
    $IOCPath2_Check=$false
}

#evaluate if $IOCPath2_Check, if false, skip attempt to process
if (!($IOCPath2_Check))
{
    #Enumerate through each hashed file in the specified directory, and compare for match
    foreach ($IOC2DirContentHash in $IOC2DirContents)
    {
        #Evaluate whether current element in the array matches the defined IOC, if true declare match and identify path and filename, and host
        if ($IOC2DirContentHash.Hash -eq $IOCHash2)
        {
            
            write-host
            write-host "$($IOC2DirContentHash.Hash) matches IOC2!!! Discovered $($IOC2DirContentHash.Path) on $ServerName"
        }
        
     }

}

#end of $Hash_Huntress script block statement
}

#dynamically identify Default Domain Naming context and assign to a variable to use for distinguishedname of OU to query member servers/workstations
$root = [ADSI]"LDAP://RootDSE"
$DOMAIN = $root.defaultNamingContext



<#Main Action of the script#>

#gather specified members from OU, and pass the $Hash-Huntress script block to them
$Servers=Get-ADComputer -filter * -SearchBase "OU=Servers,$DOMAIN" -Properties Name,OperatingSystem  | where-object {$_.OperatingSystem -like "Windows Server 2012*" -or $_.OperatingSystem -like "Windows Server 2016*" -or $_.OperatingSystem -like "Windows Server 2019*"} | select-object -Property Name, OperatingSystem
    #For each member server represented in the array defined as $Servers, execute the $Hash_Huntress script block
    foreach ($Server in $Servers)
    {
        Invoke-Command -ComputerName $Server.Name -ScriptBlock $Hash_Huntress

    }
}
#Stops transcript, to capture output to review later in IR phases
#If you just define Stop-Transcript, when the script is loaded as a function
#an error will be thrown, stating no transcription is taking place currently.
#Checking the value of the $StarTranscript variable, which contains the file that we defined at the top of the script ;)
If ($StartTranscript -ne $null)
{
    Stop-Transcript
}
