install_php_packages:
  pkg.installed:
    - names:
      - php
      - php-cli
      - php-fpm
      - php-mysql
      - php-gd
      - php-mbstring
      - php-xml
      - php-curl
      - php-zip
      - unzip
      - wget

remove_apache:
  pkg.removed:
    - name: apache2
    - require:
      - pkg: install_php_packages
