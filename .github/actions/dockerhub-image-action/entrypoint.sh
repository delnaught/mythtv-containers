#!/usr/bin/env bash

repo="$1"
tag="$2"
token=$(echo $token_rest | jq -r '.token')
token=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull" | jq -r '.token')
echo "::debug token => ${token}"
digest=$(curl -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
              -H "Authorization: Bearer $token" \
              -s "https://registry-1.docker.io/v2/${repo}/manifests/${tag}" \
             | jq -r '.config.digest')
echo "::debug digest => ${digest}"
http_code=$(curl -o /dev/null --silent -Iw '%{http_code}' \
		 -H "Authorization: Bearer $token" \
		 -s -L "https://registry-1.docker.io/v2/${repo}/blobs/${digest}")
echo "::debug http_code => ${http_code}"
echo "::set-output name=http-code::${http_code}"

