#!/bin/bash

instances=$@

echo "All instances: ${instances[@]}"

image_id="ami-09c813fb71547fc4f"
hosted_zone_id="Z08250303NQOMHGBRQZIZ"
domain_name="joindevops.store"
security_group_id="sg-04b86a12980ec1b5f"

for i in "$@"
do
  if [[ "$i" == "mongodb" || "$i" == "mysql" ]]; then
    instance_type="t3.medium"
  else
    instance_type="t2.micro"
  fi

  echo "Launching $i with instance type $instance_type"

  private_ip=$(aws ec2 run-instances \
    --image-id "$image_id" \
    --instance-type "$instance_type" \
    --security-group-ids "$security_group_id" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
    | jq -r '.Instances[].PrivateIpAddress')

  echo "$i private IP: $private_ip"

  # Route53 record creation with safe variable expansion
  aws route53 change-resource-record-sets --hosted-zone-id "$hosted_zone_id" --change-batch "$(cat <<EOF
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "$i.$domain_name",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$private_ip"
          }
        ]
      }
    }
  ]
}
EOF
)"

done
