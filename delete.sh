ENTS=("c14675b2-f268-76ec-2b20-2519eb11850c" "7d3d743a-c76b-a715-18ae-369aa8821f46" "add829f9-d243-0f27-20e1-7934bb4b3d8d" "eb282c93-2de3-c27a-590a-488a94b5725e"
"9460c80e-f787-08ca-a52f-e24a644b2dd0" "9c90dea1-1878-56ae-1d48-c80e343d6b2c" "af6a9b5d-164c-92c0-e619-1b230cc595df" "10081cc2-1244-fe43-08de-75b1de43e0ba")

TOKEN=JLykHVWlgcpdIa07y2KrVEpH
VAULT_ADDR="https://127.0.0.1:8200"


for e in ${ENTS[@]}
do
  echo $e
  echo "------"
  curl -k --silent \
        --header "X-Vault-Token: ${TOKEN}" \
        --request DELETE \
        ${VAULT_ADDR}/v1/identity/entity/id/${e}
done
