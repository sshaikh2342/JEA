#Create folder for the module
$sourcepath = "C:\users\suser3\Documents\JEA"
$modulepath = "$sourcepath\JEAdemorole"
$dcname = "dc1"
New-Item -ItemType Directory -path $modulepath

#create an empty script module and module manifest
New-item -ItemType file -path (join-path $modulepath "JEAdemorole.psm1")
New-ModuleManifest -path (Join-Path $modulepath "JeaDemoRole.psd1") -RootModule "JEAdemorole.psm1"

#Create the roleCapabilities folder and copy in the PSRC file
$rcfolder = Join-Path $modulepath "RoleCapabilities"
New-Item -ItemType Directory $rcfolder
Copy-Item -Path $sourcepath\helpdesk.psrc -Destination $rcfolder

#deploy Module to target Endpoint
Copy-Item -Path $modulepath -Destination "\\$dcname\c$\Program Files\WindowsPowershell\Modules\" -Recurse

#deploy session configuration and register it, Note .pssc file need not necessarily be in module path it could be anywhere on the system
#Will restart WinRM Service!!!
Copy-Item -Path "$sourcepath\helpdesk-session.pssc" -Destination "\\$dcname\c$\Program Files\WindowsPowershell\Modules\JEAdemorole" -Recurse

#check folders were created successfully
invoke-item "\\$dcname\c$\Program Files\WindowsPowershell\Modules\"
invoke-item "\\$dcname\c$\Program Files\WindowsPowershell\Modules\JEAdemorole\helpdesk-session.pssc"

Invoke-Command -ComputerName $dcname -ScriptBlock {
    Register-PSSessionConfiguration -Path "c:\Program Files\WindowsPowershell\Modules\JEAdemorole\helpdesk-session.pssc" -name "helpdesk"
}


Invoke-Command -ComputerName $dcname -ScriptBlock {
    UnRegister-PSSessionConfiguration "helpdesk"
}

Invoke-Command -ComputerName $dcname -ScriptBlock {Get-PSSessionConfiguration | select name,permission}

#You will get an error because WinRM service restarts and interupts remote session.


