import json
import time
import boto3
import logging

logging.basicConfig(level=logging.INFO)

ec2 = boto3.client('ec2')
instance_ids = ['i-zzzzzzzzzzzzzzzz', 'i-xxxxxxxxxxxxxxxxx', 'i-yyyyyyyyyyyyyyyyy']  # Replace with your actual instance IDs

def instance_state(instance_id):
    try:
        response = ec2.describe_instances(InstanceIds=[instance_id])
        state_name = response['Reservations'][0]['Instances'][0]['State']['Name']
        return state_name
    except Exception as e:
        logging.error(f"An error occurred: {e}")
        return None

def handle_instance(instance_id):
    try:
        state_name = instance_state(instance_id)
        if state_name is None:
            logging.error("Could not retrieve instance state.")
            return

        if state_name == 'running':
            ec2.stop_instances(InstanceIds=[instance_id])
            logging.info(f'{instance_id} server is shutting down.')
        elif state_name == 'pending':
            logging.info(f'{instance_id} server is currently starting up. Waiting to stop until fully started.')
            while instance_state(instance_id) != 'running':
                time.sleep(10)  # Sleep for 10 seconds before checking again
            ec2.stop_instances(InstanceIds=[instance_id])
            logging.info(f'{instance_id} server has started and is now being shut down.')
        else:
            logging.info(f'Nothing to do. Current state is {state_name}.')

    except Exception as e:
        logging.error(f"An error occurred: {e}")

def lambda_handler(event, context):
    for instance_id in instance_ids:
        handle_instance(instance_id)
