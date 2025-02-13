#cloud-config
package_update: true
package_upgrade: true

users:
  - default
  - name: senec
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
    ssh_authorized_keys:
      - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHrpasS2reXghKkRBRuhWBAMsbCKLBaJ6wlLd71I7bYy vlebo@fp"
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/7WVNHJg2ivaf5fah3WLlofZv7AS05472qgC5xirykVOs0ga3pQPLChiePpbYuztAVTc3J9RG7r5GuDLsag5GRXrTKjRomM+0sjGZRkymZOdF2jKACtiwWbA4adJYZ7zgAw0sh3TSuDlCxg8RDSjKaZkaBfkn6TRepT7XWrqBr9OiEFsN+DgW4eQqHxWLWCOZjjaEfQ3vrZ39XId/wgHSBKNv4YDM1Aag6FTVIkOQI2MLq/qCfvDGIRfECWZBIIngHx+AXJmEC/cwmHeRxgInvisRkfeuV6DlbHyXCgm5XCBzNaX4zZrN7NBcYgzFcHCqDgm3WO5/RhR513udEDZHb9UMyhtJQt8miJkcAZ8CLXmFB40R+PsKtdhD2AsHGN6xHKp5VH1BNJsiX4W4o3Y/nSytcnzF5NA0oOHmNNQbKDc+NKwAyhFIFX/701gRITIV2G7qWOQqKKryE+IGte8Bz+ehmPxA71dBRXHE2FFymeVTW8Z81QDBYTdapxXwvWnO4NHGGBlYwSa3phvkm53uOUTmBaFwKyR+8HSsfiJByTGDR2jqFUbvGygZmn8jgJc1V5MDssQud6Imxy3uV+eZN30H+MMQ704cjpGG+Pwak8J+2Ap3Fg4DC+nmTw2NwttL5UKLGcdB/N0Yly5tTOhAEV/XLLlfiyKuCEKWVE4Ibw=="

write_files:
  - path: /root/is_master
    content: |
      ${is_master}
    owner: root:root
    permissions: '0644'

  - path: /etc/netplan/99-floating-ip.yaml
    content: |
      network:
        version: 2
        renderer: networkd
        ethernets:
          eth0:
            addresses:
              - ${floating_ip}/32
    owner: root:root
    permissions: '0600'
    append: false

runcmd:
  # Apply Netplan only if this is the Master (LB), otherwise remove it
  - ["sh", "-c", "grep -q 'true' /root/is_master && netplan apply || rm -f /etc/netplan/99-floating-ip.yaml"]

  # Secure SSH: Disable password authentication
  - ["sh", "-c", "echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config"]
  - ["sh", "-c", "echo 'PermitRootLogin prohibit-password' >> /etc/ssh/sshd_config"]
  - ["sh", "-c", "systemctl restart ssh"]

  # Install SaltStack from the official repository
  - apt-get install -y curl wget gnupg
  - curl -fsSL https://repo.saltproject.io/salt/py3/debian/$(lsb_release -cs)/amd64/latest/SALT-PROJECT-GPG-PUBKEY-2023.pub | gpg --dearmor -o /usr/share/keyrings/salt-archive-keyring.gpg
  - echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg] https://repo.saltproject.io/salt/py3/debian/$(lsb_release -cs)/amd64/latest $(lsb_release -cs) main" > /etc/apt/sources.list.d/salt.list
  - apt-get update
  - apt-get install -y salt-minion

  # Enable and start Salt Minion
  - systemctl enable salt-minion
  - systemctl start salt-minion

  # Configure Salt Minion to connect to the Master (using internal IP)
  - ["sh", "-c", "echo 'master: ${master_ip}' > /etc/salt/minion"]
  - ["sh", "-c", "echo 'retry_dns: 5' >> /etc/salt/minion"]
  - systemctl restart salt-minion

  # If this is the Salt Master (LB), install salt-master
  - ["sh", "-c", "grep -q 'true' /root/is_master && apt-get install -y salt-master && systemctl enable salt-master && systemctl start salt-master"]
  - ["sh", "-c", "grep -q 'true' /root/is_master && mkdir -p /srv/salt /srv/pillar"]
  - ["sh", "-c", "grep -q 'true' /root/is_master && echo 'auto_accept: True' >> /etc/salt/master"]
  - ["sh", "-c", "grep -q 'true' /root/is_master && systemctl restart salt-master"]

  # Wait for Minions to register
  - sleep 10

  # Run Highstate on ALL servers
  - salt-call state.apply
