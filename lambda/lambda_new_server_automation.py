import json
import os
import boto3
import requests
import base64

BUCKET_NAME = 'testlambda1bucket11'
INSTANCE_FILE_KEY = 'instance-ips.txt'
GITHUB_INVENTORY = 'https://api.github.com/repos/Krishna-kanth95/ghar/contents/inventory.ini'
GITHUB_ACTIONS = 'https://api.github.com/repos/Krishna-kanth95/ghar/actions/workflows/ghar.yml/dispatches'

headers = {}
headers['Authorization'] = f'Bearer {os.environ["GIT_TOKEN"]}'
headers['Accept'] = 'application/vnd.github.v3+json'
headers['X-GitHub-Api-Version'] = '2022-11-28'

def update_git_inventory_file(server_details):
    try:
        git_sha = requests.get(GITHUB_INVENTORY, headers=headers)
        git_sha.raise_for_status()
    except Exception as e:
        print(f"SHA Get request update failed: {e}")
        raise

    sha = json.loads(git_sha.text)["sha"]

    inventory_lines = ['[servers]']
    for details in server_details:
        name, ip = details.split(':')
        inventory_lines.append(f'{name} ansible_host={ip}')

    new_content = '\n'.join(inventory_lines)

    data = {
        "sha": sha,
        "message": "Updating inventory with new private IPs and server names",
        "content": base64.b64encode(new_content.encode('utf-8')).decode('utf-8')
    }

    try:
        update_inv = requests.put(GITHUB_INVENTORY, headers=headers, json=data)
        update_inv.raise_for_status()
    except Exception as e:
        print(f"Inventory file update failed: {e}")
        raise

    print(update_inv.text)
    return True

def trigger_github_actions(repo, token):
    data2 = {
        "ref": "main"
    }

    ghar = requests.post(GITHUB_ACTIONS, headers=headers, json=data2)
    ghar.raise_for_status()
    print(ghar.text)

def lambda_handler(event, context):
    region = 'us-east-1'
    ec2 = boto3.client('ec2', region_name=region)
    s3 = boto3.client('s3')
    
    # Retrieve the list of known servers from the S3 bucket
    response = s3.get_object(Bucket=BUCKET_NAME, Key=INSTANCE_FILE_KEY)
    known_servers = set(response['Body'].read().decode('utf-8').split('\n'))

    # Obtain current servers from EC2 instances
    ec2_response = ec2.describe_instances()
    current_servers = set()
    
    for reservation in ec2_response['Reservations']:
        for instance in reservation['Instances']:
            if 'PrivateIpAddress' in instance:
                ip_address = instance['PrivateIpAddress']
                instance_name = next((tag['Value'] for tag in instance['Tags'] if tag['Key'] == 'Name'), 'Unknown')
                current_servers.add(f'{instance_name}:{ip_address}')

    new_servers = current_servers - known_servers

    if new_servers:
        is_update_successful = update_git_inventory_file(list(new_servers))

        if is_update_successful:
            trigger_github_actions(GITHUB_ACTIONS, os.environ["GIT_TOKEN"])

            known_servers.update(new_servers)
            updated_servers_content = '\n'.join(known_servers)
            s3.put_object(Body=updated_servers_content, Bucket=BUCKET_NAME, Key=INSTANCE_FILE_KEY)

            return {
                'statusCode': 200,
                'body': json.dumps(f'New servers {new_servers} added, GitHub Actions triggered, and S3 updated.')
            }
    else:
        return {
            'statusCode': 200,
            'body': json.dumps('No new servers; no action taken.')
        }
