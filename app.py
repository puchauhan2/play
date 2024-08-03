import subprocess
import json
import boto3
import time
import os

# Static values
repo_url = os.getenv('GITHUB_REPO_URL')
github_api_base_url = os.getenv('GITHUB_API_BASE_URL')
github_token = os.getenv('GITHUB_TOKEN_SECRET_NAME')

client = boto3.client('codebuild')
secrets_client = boto3.client('secretsmanager')

# # Fetch the PAT from AWS Secrets Manager
# def get_github_token(secret_name):
#     try:
#         response = secrets_client.get_secret_value(SecretId=secret_name)
#         secret = response['SecretString']
#         return secret
#     except Exception as e:
#         raise e

def lambda_handler(event, context):

    try:
        #dynamodb_record = event['checkCodePipelineStatusResult']['dynamodbRecord']
        request_id = 'xyz'
        account_name = 'puneet'
        branch_name = f"prc-{account_name}-{request_id}-{int(time.time())}"
  
        account_new_lines = 'Multi space character test'   

        #argument = "Java c++ python"
        command = f"./script.sh '{repo_url}' '{github_api_base_url}' '{github_token}' '{request_id}' '{account_name}' {branch_name} '{account_new_lines}'"
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()
        if process.returncode != 0:
            return {
                'statusCode': 500,
                'body': f"Error executing script: {stderr.decode('utf-8')}",
                'branch_merge_status':'fail'
            }
    
        return {
            'statusCode': 200,
            'body': f"Script output: {stdout.decode('utf-8')}",
            'branch_merge_status':'success'
        }
    except Exception as e:
        raise e

