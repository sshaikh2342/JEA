function Get-serviceinfo {
    get-service bits,winrm | select name,status
}

Get-serviceinfo