#!/bin/bash

# From Cherry (use per-server values)
controller_router_id="93.115.29.63"
compute_router_id="93.115.29.45"
router_id="93.115.29.63"
rr1="46.166.166.122"
rr2="46.166.166.123"
local_as="64667"
remote_as="16125"

ifname=$(ip route show default | awk '/default/ {print $5}')
exclude_net=$(ip route show | grep "${router_id}" | awk '{print $1}')

apt update && apt install -y bird2

cat > /etc/bird/bird.conf <<EOF
router id ${router_id};

filter cherry_bgp {
  if net ~ [${exclude_net}] then reject;
  accept;
}

protocol kernel {
  persist;
  scan time 20;
  import all;
  export all;
}

protocol device {
  scan time 10;
}

protocol direct {
  interface "dummy*";
}

protocol bgp neighbor_v4_1 {
  export filter cherry_bgp;
  local as ${local_as};
  multihop 5;
  neighbor ${rr1} as ${remote_as};
}

protocol bgp neighbor_v4_2 {
  export filter cherry_bgp;
  local as ${local_as};
  multihop 5;
  neighbor ${rr2} as ${remote_as};
}
EOF

systemctl restart bird
systemctl enable bird