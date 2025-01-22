#!/bin/bash

if [[ -z "${BIGUSER}" ]]
then
    echo 
    echo "The user:pass must be set in an environment variable. Exiting."
    echo "   export BIGUSER 'admin:admin'"
    echo 
    exit 1
fi

## Create iFile System object (user-coaching-html)
echo "..Creating the iFile system object for the user-coaching-html"
curl -k \
-u admin:admin \
-H "Content-Type: application/json" \
-d '{"name": "user-coaching-html", "source-path": "https://raw.githubusercontent.com/kevingstewart/sslo-user-coaching/refs/heads/main/user-coaching-html"}' \
https://localhost/mgmt/tm/sys/file/ifile/

# ## Create iFile LTM object (user-coaching-html)
echo "..Creating the iFile LTM object for the user-coaching-html"
curl -k \
-u admin:admin \
-H "Content-Type: application/json" \
-d '{"name":"user-coaching-html", "file-name": "user-coaching-html"}' \
https://localhost/mgmt/tm/ltm/ifile

# ## Install user-coaching-rule iRule
echo "..Creating the user-coaching-rule iRule"
rule=$(curl -sk https://raw.githubusercontent.com/kevingstewart/sslo-user-coaching/refs/heads/main/user-coaching-rule | awk '{printf "%s\\n", $0}' | sed -e 's/\"/\\"/g;s/\x27/\\'"'"'/g')
data="{\"name\":\"user-coaching-rule-tmp\",\"apiAnonymous\":\"${rule}\"}"
curl -sk \
-u admin:admin \
-H "Content-Type: application/json" \
-X POST https://localhost/mgmt/tm/ltm/rule \
-d "${data}"

# ## Install user-coaching-ja4t-rule iRule
echo "..Creating the user-coaching-ja4t-rule iRule"
rule=$(curl -sk https://raw.githubusercontent.com/kevingstewart/sslo-user-coaching/refs/heads/main/user-coaching-ja4t-rule | awk '{printf "%s\\n", $0}' | sed -e 's/\"/\\"/g;s/\x27/\\'"'"'/g')
data="{\"name\":\"user-coaching-ja4t-rule-tmp\",\"apiAnonymous\":\"${rule}\"}"
curl -sk \
-u admin:admin \
-H "Content-Type: application/json" \
-X POST https://localhost/mgmt/tm/ltm/rule \
-d "${data}"

## Create SSLO User-Coaching TAP Inspection Service
echo "..Creating the SSLO user-coaching inspection service (type TAP)"
curl -sk \
-u admin:admin \
-H "Content-Type: application/json" \
-X POST https://localhost/mgmt/shared/iapp/blocks \
-d "$(curl -sk https://raw.githubusercontent.com/kevingstewart/sslo-user-coaching/refs/heads/main/user-coaching-service)"

## Sleep for 15 seconds to allow SSLO inspection service creation to finish
echo "..Sleeping for 15 seconds to allow SSLO inspection service creation to finish"
sleep 15

# ## Modify SSLO User-Coaching TAP Service Profile (add http profile, remove clone-pool)
echo "..Modifying the SSLO user-coaching service"
curl -k \
-u admin:admin \
-H "Content-Type: application/json" \
-X PATCH \
-d '{"clonePools": [],"rules":["/Common/user-coaching-rule"],"profiles":[{"name":"http"},{"name":"ssloS_F5_UC.app/ssloS_F5_UC-service"},{"name":"ssloS_F5_UC.app/ssloS_F5_UC-tcp-lan","context":"clientside"},{"name":"ssloS_F5_UC.app/ssloS_F5_UC-tcp-wan","context":"serverside"}]}' \
https://localhost/mgmt/tm/ltm/virtual/ssloS_F5_UC.app~ssloS_F5_UC-t-4

# ## Modify the Service profile (change to f5-module type)
echo "..Modifying the SSLO user-coaching service profile"
curl -sk \
-u admin:admin \
-H "Content-Type: application/json" \
-X PATCH \
-d '{"type": "f5-module"}' \
https://localhost/mgmt/tm/ltm/profile/service/ssloS_F5_UC.app~ssloS_F5_UC-service

echo "..Done"



