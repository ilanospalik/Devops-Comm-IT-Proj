import jwt
import json
import boto3
import random
import datetime
from botocore.exceptions import BotoCoreError, ClientError
client = boto3.client('ssm')
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    # fetch username from token payload
    token = event['headers']['Authorization'].split(" ")[1]  # get token from 'Bearer <token>'
    decoded_token = jwt.decode(token, algorithms=[], verify=False, options={'verify_signature': False})
    username = decoded_token.get('cognito:username', 'No username found')
    print (username)
    # post username and timestamp into the dymanodb 
    table = dynamodb.Table("UsersSigninData")
    table.put_item(Item= {'Username': username, 'SigninTime': str(datetime.datetime.now())})
    parameter_list = ['Hello', 'Hi', 'HEY']
    # Randomly select a parameter name from the list
    param_name = random.choice(parameter_list)
    response = client.get_parameter(Name=param_name)
    # Extract the parameter value from the response
    parameter_value = response['Parameter']['Value']
    
    statusCode = 200
    body = f"{parameter_value} {username}"

    return {
        "statusCode": statusCode,
        "body": json.dumps(body),
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin" : "*", # Allows from any origin
            "Access-Control-Allow-Credentials" : True ,# Required for cookies, authorization headers with HTTPS
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        }
    }