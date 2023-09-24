import json
import time
import boto3

ec2 = boto3.client('ec2')
instance_id = '<instance-id>'

def instance_state(instance_id):
    response = ec2.describe_instances(
        InstanceIds=[instance_id]
    )
    state_name = response['Reservations'][0]['Instances'][0]['State']['Name']
    return state_name
    
def lambda_handler(event, context):
    
    state_name = instance_state(instance_id)

    if state_name == 'stopped':
        ec2.start_instances(InstanceIds=[instance_id])
        print(f'{instance_id} server is starting up.')
    
    elif state_name == 'stopping':
        print(f'{instance_id} server is currently stopping. Cannot start until fully stopped.')
        
        while instance_state(instance_id) != 'stopped':
            time.sleep(20)
        ec2.start_instances(InstanceIds=[instance_id])
        print(f'{instance_id} server is starting up.')

    else:
        print(f'Nothing to do. Current state is {state_name}.')
