# SSLO User Coaching Implementation

Requires:
* BIG-IP SSL Orchestrator 17.1.x (SSLO 11.1+)

To implement:
1. Run the following from the BIG-IP shell to get the installer:
  ```bash
  curl -sk https://raw.githubusercontent.com/kevingstewart/sslo-user-coaching/refs/heads/main/user-coaching-installer.sh -o user-coaching-installer.sh
  chmod +x user-coaching-installer.sh
  ```

2. Export the BIG-IP user:pass:
  ```bash
  export BIGUSER='admin:password'
  ```

3. Run the script to create all of the User Coaching objects
  ```bash
  ./user-coaching-installer.sh
  ```

4. Add the resulting "ssloS_F5_UC" inspection service in SSLO to a decrypted traffic service chain

5. Add the "user-coaching-ja4t-rule" iRule to the SSLO outbound topology interception rule



------
To Remove:
1. Remove ssloS_F5_UC service from any SSLO service chain
2. Delete the ssloS_F5_UC service
3. Remove the user-coaching-ja4t-rule iRule from the SSLO interception rule
4. Delete the user-coaching-ja4t-rule and user-coaching-rule iRules
5. Delete the user-coaching iFile (LTM and system)




