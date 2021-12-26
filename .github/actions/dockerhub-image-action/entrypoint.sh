#!/usr/bin/env bash

repo=$1
tag=$2
echo "::debug input ${repo}:${tag}"
token_rest=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull")
echo "::debug rtn => $? token_rest => ${token_rest}"
token=$(echo $token_rest | jq -r '.token')
#token=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull" | jq -r '.token')
echo "::debug rtn => $? token => ${token}"
digest=$(curl -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
              -H "Authorization: Bearer $token" \
              -s "https://registry-1.docker.io/v2/${repo}/manifests/${tag}" \
             | jq -r '.config.digest')
echo "::debug rtn => $? digest => ${digest}"
http_code=$(curl -o /dev/null --silent -Iw '%{http_code}' \
		 -H "Authorization: Bearer $token" \
		 -s -L "https://registry-1.docker.io/v2/${repo}/blobs/${digest}")
echo "::debug rtn => $? http_code => ${http_code}"
echo "::set-output name=http-code::${http_code}"

