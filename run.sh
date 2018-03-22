#!/bin/bash


if [ "${PLUGIN_AWS_ACCOUNT_ID}" == "none" ]; then
    PLUGIN_AWS_ACCOUNT_ID="IAM Role"
fi

echo "AWS credentials:"
echo "Account ID: ${PLUGIN_AWS_ACCOUNT_ID}"

region=${PLUGIN_AWS_REGION:-'eu-central-1'}

if [ "${PLUGIN_AWS_ACCOUNT_ID}" != "IAM Role" ]; then
    session_id=${PLUGIN_AWS_SESSION_ID:-"${DRONE_COMMIT_SHA:0:10}-${DRONE_BUILD_NUMBER}"}

    if [ "${PLUGIN_AWS_ROLE}" = "" ]; then
        echo "Required attribute missing: aws_role"
    fi

    echo "Role: ${PLUGIN_AWS_ROLE}"
    echo "IAM Role Session ID: ${session_id}"
    echo "Region: ${region}"

    iam_creds=$(aws sts assume-role --role-arn "arn:aws:iam::${PLUGIN_AWS_ACCOUNT_ID}:role/${PLUGIN_AWS_ROLE}" --role-session-name "docker-${session_id}" --region=${region} | python -m json.tool)
    export AWS_ACCESS_KEY_ID=$(echo "${iam_creds}" | grep AccessKeyId | tr -d '" ,' | cut -d ':' -f2)
    export AWS_SECRET_ACCESS_KEY=$(echo "${iam_creds}" | grep SecretAccessKey | tr -d '" ,' | cut -d ':' -f2)
    export AWS_SESSION_TOKEN=$(echo "${iam_creds}" | grep SessionToken | tr -d '" ,' | cut -d ':' -f2)
fi


echo "Packer build starting..."

target="${PLUGIN_TARGET:-${target}}"
if [ "${target}" = "" ]; then
    echo "Required attribute missing: target"
fi

echo "Build target: ${target}"

if [ -n "${PLUGIN_WORKING_DIRECTORY}" ]; then
    echo "Change to working directory: ${PLUGIN_WORKING_DIRECTORY}"
    cd ${PLUGIN_WORKING_DIRECTORY}
fi

packer build "${target}"