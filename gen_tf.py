#!/usr/bin/env python3

import yaml
import json
import sys
from pathlib import Path

def read_pillar(pillar_path):
    """Read pillar YAML file"""
    with open(pillar_path, 'r') as f:
        return yaml.safe_load(f)

def generate_tfvars(pillar_data):
    """Extract terraform variables from pillar data"""
    tf_vars = {}
    infra = pillar_data['senec']['infrastructure']
    
    # Map infrastructure section
    tf_vars.update({
        'server_type': infra['server_type'],
        'location': infra['location'],
        'volume_size': infra['volume_size'],
        'image': infra['image'],
        'network_name': infra['network_name'],
        'network_cidr': infra['network_cidr'],
        'ssh_public_keys': infra['ssh_public_keys'],
	'firewall_rules': infra['firewall_rules']
    })

    # Generate servers map
    servers = {}
    web_servers = pillar_data['senec']['common']['web_servers']
    for server in web_servers:
        servers[server] = {
            "ip": infra['server_ips'][server],
            "role": "web"
        }
    # Add LB server
    servers["LB"] = {
        "ip": infra['server_ips']['LB'],
        "role": "lb"
    }
    tf_vars['servers'] = servers

    return tf_vars

def write_tfvars(tf_vars, output_path):
    """Write terraform.tfvars file"""
    with open(output_path, 'w') as f:
        for key, value in tf_vars.items():
            if isinstance(value, (dict, list)):
                f.write(f"{key} = {json.dumps(value, indent=2)}\n")
            elif isinstance(value, bool):
                f.write(f"{key} = {str(value).lower()}\n")
            elif isinstance(value, (int, float)):
                f.write(f"{key} = {value}\n")
            else:
                f.write(f'{key} = "{value}"\n')

def write_env_file(env_name, lb_server_ip, ssh_user, output_dir):
    """Generate .env file with terraform directory and lb_server_ip"""
    env_content = f"""TERRAFORM_DIR=terraform/environments/{env_name}
REMOTE_HOST={lb_server_ip}
SSH_USER={ssh_user}"""
    
    with open('.env', 'w') as f:
        f.write(env_content)

def main():
    if len(sys.argv) != 2:
        print("Usage: ./gen_tf.py path/to/pillar.sls")
        sys.exit(1)

    pillar_path = sys.argv[1]
    
    if not Path(pillar_path).exists():
        print(f"Error: Pillar file {pillar_path} not found")
        sys.exit(1)

    try:
        # Read pillar data
        pillar_data = read_pillar(pillar_path)
        
        # Get environment from pillar
        env = pillar_data['senec']['env']
        ssh_user = pillar_data['senec']['ssh_user']
        lb_server_ip = pillar_data['senec']['infrastructure']['lb_server_ip']
        
        # Create output directory
        output_dir = Path(f"terraform/environments/{env}")
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate and write tfvars
        tf_vars = generate_tfvars(pillar_data)
        output_path = output_dir / 'terraform.tfvars'
        write_tfvars(tf_vars, output_path)
        print(f"Successfully generated {output_path}")
        
        # Generate .env file
        write_env_file(env, lb_server_ip, ssh_user, output_dir)
        print("Successfully generated .env file")
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
