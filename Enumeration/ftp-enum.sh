#!/bin/bash 

ftp_anonymous(){

    # Checking for Anonymous Login is Enable or not 
    nmap $IP -p21 --script=ftp-anon.nse > ftp-anon.nse.txt
    echo "Anonymous Scan Sucessfully...." 
}

Unauth_enum(){

    # Checking for Unauth_enum
    sudo nmap -sV -p21 -sC -A $IP
}

