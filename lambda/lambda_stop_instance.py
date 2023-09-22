import json
import boto3

ec2 = boto3.client('ec2')
instance_id = '<instance-id>'

def instance_state(instance_id):
    response = ec2.describe_instances(
        InstanceIds=[instance_id]
    )
    instance = response['Reservations'][0]['Instances'][0]
    state_name = instance['State']['Name']
    return state_name
    
def lambda_handler(event, context):
    
    state_name = instance_state(instance_id)

    if state_name == 'running' or state_name == 'pending':
        if state_name == 'running':
            ec2.stop_instances(InstanceIds=[instance_id])
            print(f'{instance_id} server is shutting down.')
        else:
            print(f'{instance_id} server is currently starting up. Cannot stop until fully started.')
    else:
        print(f'Nothing to do. Current state is {state_name}.')