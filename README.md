# Hash-Huntress
Hash-Huntress.ps1
# Purpose: Hunt for files hash or process hash matching IOCs you provide, at scale across domain, or on a single host  

#Before using  
Open the Hash-Huntress.ps1 script in your favorite text editor.  
Modify the $IOCPath1 and $IOCHash1 and $IOCPath2 and $IOCPath2 varibles to suit your needs. SHA-256 is the default.  
If you want to add more checks to the script, you can add more stanzas, and update the varible names to fit your needs.  

#Usage  
PS>. .\Hash-Huntress.ps1  
PS>Hash-Huntress.ps1  

A transcript file named Hash-Huntress_Transcript$timestamp.txt will be generated in the pwd.  
