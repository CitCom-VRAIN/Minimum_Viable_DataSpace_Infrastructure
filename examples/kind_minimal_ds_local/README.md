# Minimal Data Space Local - Kind Cluster

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
        <a href="#deployment">Deployment</a>
    </li>
    <li>
        <a href="#cheetsheet">Cheetsheet</a>
    </li>
  </ol>
</details>

This example is based on the [FIWARE's local deployment](https://github.com/FIWARE/data-space-connector/blob/main/doc/deployment-integration/local-deployment/LOCAL.MD). The main difference is that we are using a Kind cluster (with 3 nodes) and Terraform to manage all the resources.

The following diagram shows the main blocks of the architecture of the minimal data space. This example is composed of the following blocks:

- **DS Operator (trust anchor)**: Trust Anchor that manages the issuers and credentials.
- **DS Connector A (provider)**: Entity that provides and consumes data from the data space.
- **DS Connector B (consumer)**: Entity that only consumes data from the data space.

![minimal_ds](./images/minimum_dataspace_arch.png)

> [!NOTE]
>
> See FIWARE [module](../../modules/fiware_ds_connector/) for more details.

## Deployment

```bash
make init_apply
```

To connect to the cluster, there are two options:

1. Using the `KUBECONFIG` variable:
  ```bash
  export KUBECONFIG=./cluster-config.yaml
  kubectl get pods --all-namespaces
  ```
2. Using the `--kubeconfig` flag:
  ```bash
  kubectl get nodes --kubeconfig ./cluster-config.yaml --all-namespaces
  ```
> [!WARNING]
>
> **Temporary Solution** Also to access to the different services, you need to add all domain names to your `/etc/hosts` file.
>
> 1. Check the Traefik IP address: 
>
> ```bash
> kubectl get services -n traefik-ingress --kubeconfig ./cluster-config.yaml
> NAME                        TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)          AGE
> traefik-dashboard-service   LoadBalancer   10.96.97.1    172.18.255.201   8080:30137/TCP   10m
>traefik-web-service         LoadBalancer   10.96.72.80   172.18.255.200   80:31910/TCP     10m
> ```
>
> 2. Add the domain names to your `/etc/hosts` file:
>
> ```bash
> 172.19.255.200     did-helper.consumer-a.local
> 172.19.255.200     keycloak.consumer-a.local
> 172.19.255.200     til.ds-operator.local
> 172.19.255.200     tir.ds-operator.local
> 172.19.255.200     apisix-proxy.provider-a.local
> 172.19.255.200     apisix-api.provider-a.local
> 172.19.255.200     did-helper.provider-a.local
> 172.19.255.200     pap-odrl.provider-a.local
> 172.19.255.200     scorpio-broker.provider-a.local
> 172.19.255.200     tm-forum-api.provider-a.local
> 172.19.255.200     til.provider-a.local
> 172.19.255.200     vc-verifier.provider-a.local
> ```

### Access to the services

Traefik dashboard: `http://172.19.255.201:8080/dashboard#`

>[!IMPORTANT]
>
> More information in the FIWARE's [local deployment](https://github.com/FIWARE/data-space-connector/blob/main/doc/deployment-integration/local-deployment/LOCAL.MD#the-data-space).

**Trust-Anchor**

```bash
curl -s -XGET http://tir.ds-operator.local/v4/issuers | jq


{
  "self": "/v4/issuers/",
  "items": [
    {
      "did": "did:key:zDnaedBWBYNtDsCNqxqBbshP7p5RuEuFo5emku1ack3XzvvoU",
      "href": "/v4/issuers/did:key:zDnaedBWBYNtDsCNqxqBbshP7p5RuEuFo5emku1ack3XzvvoU"
    },
    {
      "did": "did:key:zDnaezQYkXpLUpp4vXRS3DiQFhaHhWkPQphdVqCarsPuNbz95",
      "href": "/v4/issuers/did:key:zDnaezQYkXpLUpp4vXRS3DiQFhaHhWkPQphdVqCarsPuNbz95"
    }
  ],
  "total": 2,
  "pageSize": 2,
  "links": {
    "first": "did:key:zDnaedBWBYNtDsCNqxqBbshP7p5RuEuFo5emku1ack3XzvvoU"
  }
}
```

**Paricipants**

Keycloak:

- Admin console: `http://keycloak.consumer-a.local`
- Realm (*test-user* | *test*): `http://keycloak.consumer-a.local/realms/test-realm/account/oid4vci`


Retrieve an actual credential:

```bash
unset ACCESS_TOKEN; unset OFFER_URI; unset PRE_AUTHORIZED_CODE; \
unset CREDENTIAL_ACCESS_TOKEN; unset VERIFIABLE_CREDENTIAL; unset HOLDER_DID; \
unset VERIFIABLE_PRESENTATION; unset JWT_HEADER; unset PAYLOAD; unset SIGNATURE; unset JWT; \
unset VP_TOKEN; unset DATA_SERVICE_ACCESS_TOKEN;
```

```bash
export ACCESS_TOKEN=$(curl -s -X POST "http://keycloak.consumer-a.local/realms/test-realm/protocol/openid-connect/token" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=password \
  --data client_id=admin-cli \
  --data username=test-user \
  --data password=test | jq '.access_token' -r); echo -e "\n>> Access token: $ACCESS_TOKEN"
```

```bash
curl -s -X GET http://keycloak.consumer-a.local/realms/test-realm/.well-known/openid-credential-issuer | jq
```

```bash
export OFFER_URI=$(curl -s -X GET "http://keycloak.consumer-a.local/realms/test-realm/protocol/oid4vc/credential-offer-uri?credential_configuration_id=user-credential" \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq '"\(.issuer)\(.nonce)"' -r); echo -e "\n>> Offer URI: $OFFER_URI"

export PRE_AUTHORIZED_CODE=$(curl -s -X GET ${OFFER_URI} \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq '.grants."urn:ietf:params:oauth:grant-type:pre-authorized_code"."pre-authorized_code"' -r); echo -e "\n>> Pre-authorized code: $PRE_AUTHORIZED_CODE"

export CREDENTIAL_ACCESS_TOKEN=$(curl -s -X POST "http://keycloak.consumer-a.local/realms/test-realm/protocol/openid-connect/token" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=urn:ietf:params:oauth:grant-type:pre-authorized_code \
  --data code=${PRE_AUTHORIZED_CODE} | jq '.access_token' -r); echo -e "\n>> Credential access token: $CREDENTIAL"

export VERIFIABLE_CREDENTIAL=$(curl -s -X POST "http://keycloak.consumer-a.local/realms/test-realm/protocol/oid4vc/credential" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${CREDENTIAL_ACCESS_TOKEN}" \
  --data '{"credential_identifier":"user-credential", "format":"jwt_vc"}' | jq '.credential' -r);echo -e "\n>> Verifiable credential: $VERIFIABLE_CREDENTIAL"
```

Authenticate via OID4VP

```bash
export TOKEN_ENDPOINT=$(curl -s -X GET 'http:/apisix-proxy.provider-a.local/.well-known/openid-configuration' | jq -r '.token_endpoint'); echo -e "\n>> Token endpoint $TOKEN_ENDPOINT"
```

```bash
docker run -v $(pwd):/cert quay.io/wi_stefan/did-helper:0.1.1
```

```bash
export HOLDER_DID=$(cat did.json | jq '.id' -r); echo -e "\n>> Holder DID: $HOLDER_DID"

export VERIFIABLE_PRESENTATION="{
  \"@context\": [\"https://www.w3.org/2018/credentials/v1\"],
  \"type\": [\"VerifiablePresentation\"],
  \"verifiableCredential\": [
      \"${VERIFIABLE_CREDENTIAL}\"
  ],
  \"holder\": \"${HOLDER_DID}\"
}"; echo -e "\n>> Verifiable presentation: $VERIFIABLE_PRESENTATION"

export JWT_HEADER=$(echo -n "{\"alg\":\"ES256\", \"typ\":\"JWT\", \"kid\":\"${HOLDER_DID}\"}"| base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//); echo -e "\n>> JWT header: $JWT_HEADER"

export PAYLOAD=$(echo -n "{\"iss\": \"${HOLDER_DID}\", \"sub\": \"${HOLDER_DID}\", \"vp\": ${VERIFIABLE_PRESENTATION}}" | base64 -w0 | sed s/\+/-/g |sed 's/\//_/g' |  sed -E s/=+$//); echo -e "\n>> Payload: $PAYLOAD"

export SIGNATURE=$(echo -n "${JWT_HEADER}.${PAYLOAD}" | openssl dgst -sha256 -binary -sign private-key.pem | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//); echo -e "\n >> Signature: $SIGNATURE"

export JWT="${JWT_HEADER}.${PAYLOAD}.${SIGNATURE}"; echo -e "\n>> JWT: $JWT"

export VP_TOKEN=$(echo -n ${JWT} | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//); echo -e "\n>> VP token: $VP_TOKEN"

export DATA_SERVICE_ACCESS_TOKEN=$(curl -s -X POST $TOKEN_ENDPOINT \
    --header 'Accept: */*' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data grant_type=vp_token \
    --data vp_token=${VP_TOKEN} \
    --data scope=default | jq '.access_token' -r ); echo -e "\n>> Data service access token: $DATA_SERVICE_ACCESS_TOKEN"
```



## Cheetsheet

- Get the pods status:
```bash
watch kubectl get pods --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml --all-namespaces
```

```bash
watch kubectl get pods --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml -n provider-a
```

- Get all certificates:
```bash
  kubectl get cert --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml --all-namespaces
```

- Get all secrets:
```bash
  kubectl get secrets --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml --all-namespaces
```

- Get secrect content:
```bash
  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml -n <namespace_name> <secret_name> -o jsonpath="{.data['tls\.crt']}" | base64 --decode

  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml -n ds-operator mysql-database-secret -o json

  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml -n ds-operator mysql-database-secret -o jsonpath="{.data}" | jq

  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml -n ds-operator mysql-database-secret -o json | jq -r '.data | to_entries[] | .key + ": " + (.value | @base64d)'
```