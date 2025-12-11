#!bin/bash

# This code is for Creating Instances and Route53 Domains through script

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-043c394b36a5f4c32" #Replace with your SG ID
ZONE_ID="Z0916971Y125VMEVE7EO" # Will find this in Route53 place and different for all
DOMAIN_NAME="dawsnikitha.fun"
for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro $SG_ID sg-043c394b36a5f4c32 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    #Get Private IP
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"  # mongo --> Instance given at run time and mongo.dawsnikitha.fun we get 
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN_NAME" #dawsnikitha.fun --> This is frontend so frontend will be only called as dawsnikitha.fun no instance name attached before
    fi


    echo "$instance: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating record set"
        ,"Changes": [{
       "Action"              : "UPSERT"    
       ,"ResourceRecordSet" : {
        "Name"              : "'$RECORDNAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
       
       }       
        }]
    }
    '

done


