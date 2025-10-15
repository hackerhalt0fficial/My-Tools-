#!/bin/bash

show_menu() {
  echo "Select a category:"
  echo "1) Enumeration"
  echo "2) Exploitation"
  echo "3) Network Scanning"
  echo "4) Information Gathering"
  echo "5) Reporting"
  echo "6) Exit"
}

# Enumeration
run_enumeration() {
  echo "Select Enumeration Script:"
  echo "1) SMB Enum"
  echo "2) HTTP Enum"
  echo "3) FTP Enum"
  read -p "Choice: " enum_choice
  case $enum_choice in
    1) bash ./Enumeration/smb-enum.sh ;;
    2) bash ./Enumeration/http-enum.sh ;;
    3) bash ./Enumeration/ftp-enum.sh ;;
    *) echo "Invalid choice." ;;
  esac
}

# Exploitation
run_Exploitation() {
  echo "Select Enumeration Script:"
  echo "1) SMB Enum"
  echo "2) HTTP Enum"
  echo "3) FTP Enum"
  read -p "Choice: " enum_choice
  case $enum_choice in
    1) bash ./Enumeration/smb-enum.sh ;;
    2) bash ./Enumeration/http-enum.sh ;;
    3) bash ./Enumeration/ftp-enum.sh ;;
    *) echo "Invalid choice." ;;
  esac
}

# Networking
run_Networking() {
  echo "Select Enumeration Script:"
  echo "1) SMB Enum"
  echo "2) HTTP Enum"
  echo "3) FTP Enum"
  read -p "Choice: " enum_choice
  case $enum_choice in
    1) bash ./Enumeration/smb-enum.sh ;;
    2) bash ./Enumeration/http-enum.sh ;;
    3) bash ./Enumeration/ftp-enum.sh ;;
    *) echo "Invalid choice." ;;
  esac
}

# Information-Gathering 
run_Information-Gathering() {
  echo "Select Enumeration Script:"
  echo "1) SMB Enum"
  echo "2) HTTP Enum"
  echo "3) FTP Enum"
  read -p "Choice: " enum_choice
  case $enum_choice in
    1) bash ./Enumeration/smb-enum.sh ;;
    2) bash ./Enumeration/http-enum.sh ;;
    3) bash ./Enumeration/ftp-enum.sh ;;
    *) echo "Invalid choice." ;;
  esac
}

# Reporting 
run_Reporting() {
  echo "Select Enumeration Script:"
  echo "1) SMB Enum"
  echo "2) HTTP Enum"
  echo "3) FTP Enum"
  read -p "Choice: " enum_choice
  case $enum_choice in
    1) bash ./Enumeration/smb-enum.sh ;;
    2) bash ./Enumeration/http-enum.sh ;;
    3) bash ./Enumeration/ftp-enum.sh ;;
    *) echo "Invalid choice." ;;
  esac
}


# Add similar functions for other categories...

while true; do
  show_menu
  read -p "Enter choice: " main_choice
  case $main_choice in
    1) run_enumeration ;;
    2) run_Exploitation ;; # Add later
    3) run_Networking ;; # Add later
    4) echo "Info Gathering not added yet" ;; # Add later
    5) echo "Reporting not added yet" ;; # Add later
    6) exit 0 ;;
    *) echo "Invalid choice." ;;
  esac
done
