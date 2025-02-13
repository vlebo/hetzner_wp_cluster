{% set config = salt['pillar.get']('senec:mariadb') %}
{% set wp = salt['pillar.get']('senec:wordpress') %}

# Ensure backup directory exists
wordpress_backup_dir:
  file.directory:
    - name: {{ config.backup_dir }}
    - user: root
    - group: root
    - mode: 750
    - makedirs: True

# Install required packages
backup_packages:
  pkg.installed:
    - pkgs:
      - mariadb-client
      - gzip
      - python3

# Create backup script
wordpress_backup_script:
  file.managed:
    - name: /usr/local/bin/wp_backup.sh
    - user: root
    - group: root
    - mode: 700
    - contents: |
        #!/bin/bash
        DATE=$(date +%Y%m%d_%H%M%S)
        BACKUP_DIR="{{ config.backup_dir }}"
        DB_NAME="{{ wp.db_name }}"
        DB_USER="{{ config.senec_root_user }}"
        DB_PASS="{{ config.senec_root_password }}"
        DB_HOST="{{ wp.db_host }}"

        # Create backup with compression
        mysqldump --user=$DB_USER --password=$DB_PASS --host=$DB_HOST \
          --single-transaction --quick --lock-tables=false \
          $DB_NAME | gzip > $BACKUP_DIR/wordpress_$DATE.sql.gz

        # Remove backups older than 30 days
        find $BACKUP_DIR -name "wordpress_*.sql.gz" -mtime +30 -delete

        # Check if backup was successful
        if [ $? -eq 0 ]; then
            echo "Backup completed successfully"
            exit 0
        else
            echo "Backup failed"
            exit 1
        fi

# Create cron job for regular backups
wordpress_backup_cron:
  cron.present:
    - name: /usr/local/bin/wp_backup.sh
    - user: root
    - minute: '0'
    - hour: '2'
    - dayweek: '*'
    - require:
      - file: wordpress_backup_script
