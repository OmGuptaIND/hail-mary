#!/bin/bash

floating_ip="84.32.215.62"  # Your VIP from globals.yml
gateway="93.115.29.63"  # Your gateway from Cherry script

cat > /etc/netplan/60-floating-ip.yaml <<EOF
network:
    version: 2
    bridges:
        br-ex:
        addresses:
            - ${floating_ip}/32
        mtu: 1500
        nameservers:
            addresses:
                - 46.166.166.46
                - 5.199.160.160
EOF

netplan apply