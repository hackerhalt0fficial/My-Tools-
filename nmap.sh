#!/bin/bash

# Check if the user provided a target IP or hostname
read -p "Enter the target IP address or hostname: " target

# Nmap Scan Functions 
Default_scan(){
    echo "Running Default Scan on $target..."
    nmap -v -A $target
}

