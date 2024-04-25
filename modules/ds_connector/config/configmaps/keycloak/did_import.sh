export KEY=$(cat /opt/did/secret/tls.key)
export KEY_ID=$(curl --location "$${WALTID_CORE_ADDRESS}/v1/key/import" --header 'Content-Type: text/plain' --data "$${KEY}" | jq -r '.id')
echo The key id: $${KEY_ID}
curl --location "$${WALTID_CORE_ADDRESS}/v1/did/create" \
  --header 'Content-Type: application/json' \
  --data "{
      \"method\": \"web\",
      \"keyAlias\":\"$${KEY_ID}\",
      \"domain\": \"${waltid_domain}\",
      \"path\": \"did\",
      \"x5u\": \"https://${waltid_domain}/certs/tls.crt\"
  }"