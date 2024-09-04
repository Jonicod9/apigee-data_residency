# apigee-data_residency
This terraform block, deploys an Apigee organization, along with a VPC and set a Data residency zone for the control plane

APIs to enable:

Cloud Resource Manager API 
Apigee API
Compute Engine API
SERVICENTWORKING API
Cloud KMS API

Result:

Run this command to check if drz is correct:

curl -X GET https://apigee.googleapis.com/v1/organizations/$PROJECT_ID:getProjectMapping \
    -H "Authorization: Bearer $(gcloud auth print-access-token)"
