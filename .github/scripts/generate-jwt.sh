#!/bin/bash

#
# JWT Encoder Bash Script
#

secret="$1"

# Static header fields.
header='{
    "alg":"RS256"
}'

# Static payload fields.
payload='{
    "iss": "134490"
}'

# Use jq to set the dynamic `iat` and `exp`
# fields on the payload using the current time.
# `iat` is set to now, and `exp` is now + 1 second.
payload=$(
    echo "${payload}" | jq --arg time_str "$(date +%s)" \
    '
    ($time_str | tonumber) as $time_num
    | .iat=$time_num
    | .exp=($time_num + 10)
    '
)

base64_encode()
{
    declare input=${1:-$(</dev/stdin)}
    # Use `tr` to URL encode the output from base64.
    printf '%s' "${input}" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'
}

json() {
    declare input=${1:-$(</dev/stdin)}
    printf '%s' "${input}" | jq -c .
}

sha256_sign()
{
    declare input=${1:-$(</dev/stdin)}
    printf '%s' "${input}" | openssl dgst -binary -sha256 -sign "${secret}"
}

header_base64=$(echo "${header}" | json | base64_encode)
payload_base64=$(echo "${payload}" | json | base64_encode)

header_payload=$(echo "${header_base64}.${payload_base64}")
signature=$(echo "${header_payload}" | sha256_sign | base64_encode)

echo "${header_payload}.${signature}"