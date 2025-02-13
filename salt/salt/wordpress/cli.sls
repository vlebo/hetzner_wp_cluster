wordpress_cli:
  file.managed:
    - name: /usr/local/bin/wp
    - source: https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    - source_hash: https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar.sha512
    - mode: '0755'
    - user: root
    - group: root

  cmd.run:
    - name: wp --info
    - require:
      - file: wordpress_cli
