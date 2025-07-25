 #!/bin/bash
 # zowe_operations.sh
 # Set up environment
 # cd ../IBMZ/github/check-cobol-automation
 echo "change to github dir"
 #zowe --version > $ZOWE_VERSION
 echo $ZOWE_VERSION
# Convert username to lowercase
 echo "zowe operation start..."
 LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
 # Check if directory exists, create if it doesn't
 echo " uss files zid=" $LOWERCASE_USERNAME
 echo "ssh logon"
 sshpass -p $ZOWE_PASSWORD ssh $ZOWE_USERNAME@204.90.115.200
 #if ! zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" &> /dev/null; then
 echo "Directory does not exist. Creating it..."
 zowe zos-files create uss-directory "/z/$LOWERCASE_USERNAME/cobolcheck"
 #else
 echo "Directory already exists." 
 #fi
 # Upload files
 echo "upload files..."
 zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive--binary-files "cobol-check-0.2.18.zip"
 # Verify upload
 echo "Verifying upload:"
 zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck"
