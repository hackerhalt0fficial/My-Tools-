#!/bin/bash 


SMB_Nmap_scan(){
    echo "SMB Port Scanning Start ...."
    nmap $IP -sC -sV -p139,445 > Smb-Port-Scanning.txt
    echo "Scan Completed ..."
}

# SMB Environment Information

# Anonymous Login 
netexec(){
    echo "NetExec with Blank Password"
    nxc smb $IP -u '' -p ''  > nxc-Enum-report
    nxc smb $IP -u 'guest' -p ''  >> nxc-Enum-report

    # Checking For Shares 
    nxc smb $IP -u '' -p '' --shares >> nxc-Enum-report
    nxc smb $IP -u 'guest' -p '' --shares >> nxc-Enum-report
    
    # Checking  For Users 
    nxc smb $IP -u '' -p '' --users >> nxc-Enum-report
    nxc smb $IP -u 'guest' -p '' --users >> nxc-Enum-report

    # Checking for Rid-Brute
    nxc smb $IP -u '' -p '' --rid-brute >> nxc-Enum-report
    nxc smb $IP -u 'guest' -p '' --rid-brute >> nxc-Enum-report
    
    # Checking for pass-pol 
    nxc smb $IP -u '' -p '' --pass-pol >> nxc-Enum-report
    nxc smb $IP -u 'guest' -p '' --pass-pol >> nxc-Enum-report
}


# Function Call 
read -p 'Enter the IP Address : ' IP
netexec
