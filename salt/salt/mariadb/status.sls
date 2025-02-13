# Define connection details in a single state
mysql_connection:
  mysql_query.run:
    - database: information_schema
    - query: SELECT 1
    - connection_user: {{ salt['pillar.get']('senec:mariadb:senec_root_user') }}
    - connection_pass: {{ salt['pillar.get']('senec:mariadb:senec_root_password') }}
    - connection_host: {{ salt['pillar.get']('senec:wordpress:db_host') }}
    - connection_port: {{ salt['pillar.get']('senec:wordpress:db_port') }}

# All other queries use the connection details from mysql_connection
check_cluster_size:
  mysql_query.run:
    - database: information_schema
    - query: >-
        SELECT VARIABLE_VALUE 
        FROM global_status 
        WHERE VARIABLE_NAME = 'wsrep_cluster_size';
    - use:
      - mysql_query: mysql_connection

check_cluster_status:
  mysql_query.run:
    - database: information_schema
    - query: >-
        SELECT VARIABLE_NAME, VARIABLE_VALUE 
        FROM global_status 
        WHERE VARIABLE_NAME IN (
          'wsrep_cluster_size',
          'wsrep_cluster_status',
          'wsrep_connected',
          'wsrep_ready',
          'wsrep_local_state_comment'
        );
    - use:
      - mysql_query: mysql_connection

check_cluster_members:
  mysql_query.run:
    - database: information_schema
    - query: >-
        SELECT VARIABLE_VALUE 
        FROM global_status 
        WHERE VARIABLE_NAME = 'wsrep_incoming_addresses';
    - use:
      - mysql_query: mysql_connection
