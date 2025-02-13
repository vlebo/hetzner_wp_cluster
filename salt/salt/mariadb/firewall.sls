open-galera-ports:
  cmd.run:
    - name: |
        ufw allow 3306/tcp
        ufw allow 4567/tcp
        ufw allow 4567/udp
        ufw allow 4568/tcp
        ufw allow 4444/tcp
        ufw reload
    - unless: ufw status | grep "3306/tcp"

