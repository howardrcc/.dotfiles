#!/run/current-system/sw/bin/bash

openconnect     --os=linux-64           \
    --local-hostname=biacws01           \
    --server=ravpn.radboudumc.nl        \
    --user=z157425                      \
    --protocol=f5                       

--printcookie                       \
    --no-xmlpost                        \
    --allow-insecure-crypto             \

    --no-system-trust                       \
    --no-dtls