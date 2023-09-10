import json
import os
import boto3
import requests
import base64

BUCKET_NAME = 'testlambda1bucket'
INSTANCE_FILE_KEY = 'instance-ips.txt'
GITHUB_INVENTORY = 'https://api.github.com/repos/Krishna-kanth95/ghar/contents/inventory.ini'
GITHUB_ACTIONS = 'https://api.github.com/repos/Krishna-kanth95/ghar/actions/workflows/ghar.yml/dispatches'

headers = {}
headers['Authorization'] = f'Bearer {os.environ["GIT_TOKEN"]}'
headers['Accept'] = 'application/vnd.github.v3+json'
headers['X-GitHub-Api-Version'] = '2022-11-28'

def encode_ips(private_ip):
    encoded_ips = []
    for ip in private_ip:
        encoded_ip = base64.b64encode(ip.encode('utf-8')).decode('utf-8')
        encoded_ips.append(encoded_ip)
    return encoded_ips


def update_git_inventory_file(private_ips):
    try:
        git_sha = requests.get(GITHUB_INVENTORY, headers=headers)
        git_sha.raise_for_status()  # Raise an exception for non-2xx status codes
    except Exception as e:
        print(f"SHA Get request update failed: {e}")
        raise

    sha = json.loads(git_sha.text)["sha"]
    print(sha)

    # Replace existing private IPs with new private IPs
    new_content = '[servers]\n' + '\n'.join(private_ips)

    data = {
        "sha": sha,
        "message": "Updating inventory with new private IPs",
        "content": base64.b64encode(new_content.encode('utf-8')).decode('utf-8')
    }

    try:
        update_inv = requests.put(GITHUB_INVENTORY, headers=headers, json=data)
        update_inv.raise_for_status()  # Raise an exception for non-2xx status codes
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
    ghar.raise_for_status()  # Raise an exception for non-2xx status codes
    print(ghar.text)

def lambda_handler(event, context):
    region = 'us-east-1'
    ec2 = boto3.client('ec2', region_name=region)
    s3 = boto3.client('s3')
    
    # Read known private IPs from S3 bucket
    response = s3.get_object(Bucket=BUCKET_NAME, Key=INSTANCE_FILE_KEY)
    known_private_ips = set(ip.strip() for ip in response['Body'].read().decode('utf-8').split('\n') if ip.strip())

    # Get information about all instances
    ec2_response = ec2.describe_instances()

    # Initialize set to store current private IP addresses
    current_private_ips = set()

    for reservation in ec2_response['Reservations']:
        for instance in reservation['Instances']:
            # Check if 'PrivateIpAddress' key exists
            if 'PrivateIpAddress' in instance:
                current_private_ips.add(instance['PrivateIpAddress'])


    # Find new private IPs
    new_private_ips = current_private_ips - known_private_ips

    if new_private_ips:
        # Update Git inventory file with new private IP addresses
        is_update_successful = update_git_inventory_file(list(new_private_ips))

        if is_update_successful:
            # Trigger GitHub Actions workflow only if the update was successful and there are new instances
            trigger_github_actions(GITHUB_ACTIONS, os.environ["GIT_TOKEN"])

            # Update known_private_ips and write to S3 only if there are new private IPs
            known_private_ips.update(new_private_ips)
            s3.put_object(Body='\n'.join(known_private_ips), Bucket=BUCKET_NAME, Key=INSTANCE_FILE_KEY)

            return {
                'statusCode': 200,
                'body': json.dumps(f'New instances with IPs {new_private_ips} added and GitHub Actions triggered.')
            }
    else:
        return {
            'statusCode': 200,
            'body': json.dumps('No new instances; no action taken.')
        }
