import json
import boto3
from datetime import datetime
from botocore.exceptions import ClientError

# Initialize AWS clients
ec2_client = boto3.client('ec2')
s3_client = boto3.client('s3')

# S3 bucket name - set via environment variable
import os
BUCKET_NAME = os.environ.get('BUCKET_NAME', 'my-ec2-metadata-bucket')

def get_instance_metadata(instance):
    """Extract metadata from an EC2 instance object"""
    
    # Get tags as a dictionary
    tags = {}
    if instance.get('Tags'):
        tags = {tag['Key']: tag['Value'] for tag in instance['Tags']}
    
    # Get network interfaces info
    network_interfaces = instance.get('NetworkInterfaces', [])
    private_ips = []
    public_ips = []
    security_groups = []
    
    for ni in network_interfaces:
        if ni.get('PrivateIpAddress'):
            private_ips.append(ni['PrivateIpAddress'])
        if ni.get('Association', {}).get('PublicIp'):
            public_ips.append(ni['Association']['PublicIp'])
        security_groups.extend([sg['GroupName'] for sg in ni.get('Groups', [])])
    
    # Build metadata object
    metadata = {
        'collection_timestamp': datetime.utcnow().isoformat() + 'Z',
        'instance_id': instance.get('InstanceId'),
        'instance_type': instance.get('InstanceType'),
        'instance_state': instance.get('State', {}).get('Name'),
        'availability_zone': instance.get('Placement', {}).get('AvailabilityZone'),
        'region': ec2_client.meta.region_name,
        'ami_id': instance.get('ImageId'),
        'launch_time': instance.get('LaunchTime').isoformat() if instance.get('LaunchTime') else None,
        'private_ip_addresses': private_ips,
        'public_ip_addresses': public_ips,
        'vpc_id': instance.get('VpcId'),
        'subnet_id': instance.get('SubnetId'),
        'security_groups': list(set(security_groups)),  # Remove duplicates
        'iam_instance_profile': instance.get('IamInstanceProfile', {}).get('Arn'),
        'monitoring_state': instance.get('Monitoring', {}).get('State'),
        'platform': instance.get('Platform', 'linux'),  # 'windows' or 'linux'
        'architecture': instance.get('Architecture'),
        'virtualization_type': instance.get('VirtualizationType'),
        'root_device_type': instance.get('RootDeviceType'),
        'tags': tags
    }
    
    return metadata

def upload_to_s3(instance_id, metadata):
    """Upload metadata to S3"""
    try:
        timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        key = f"metadata/{instance_id}/{timestamp}.json"
        
        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=key,
            Body=json.dumps(metadata, indent=2, default=str),
            ContentType='application/json'
        )
        
        print(f"✓ Uploaded metadata for {instance_id} to s3://{BUCKET_NAME}/{key}")
        return True
        
    except ClientError as e:
        print(f"✗ Error uploading metadata for {instance_id}: {str(e)}")
        return False

def lambda_handler(event, context):
    """
    Lambda handler function
    Scans all running EC2 instances and collects their metadata
    """
    
    print(f"Starting metadata collection at {datetime.utcnow().isoformat()}")
    print(f"Target S3 bucket: {BUCKET_NAME}")
    print(f"Region: {ec2_client.meta.region_name}")
    
    successful = 0
    failed = 0
    total_instances = 0
    
    try:
        # Get all running instances (you can modify filters as needed)
        response = ec2_client.describe_instances(
            Filters=[
                {
                    'Name': 'instance-state-name',
                    'Values': ['running']  # Only running instances
                }
            ]
        )
        
        # Iterate through all reservations and instances
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                total_instances += 1
                instance_id = instance.get('InstanceId')
                
                print(f"Processing instance: {instance_id}")
                
                # Collect metadata
                metadata = get_instance_metadata(instance)
                
                # Upload to S3
                if upload_to_s3(instance_id, metadata):
                    successful += 1
                else:
                    failed += 1
        
        # Summary
        summary = {
            'status': 'success',
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'region': ec2_client.meta.region_name,
            'total_instances': total_instances,
            'successful_uploads': successful,
            'failed_uploads': failed,
            'bucket': BUCKET_NAME
        }
        
        print(f"\n=== Summary ===")
        print(f"Total instances processed: {total_instances}")
        print(f"Successful uploads: {successful}")
        print(f"Failed uploads: {failed}")
        
        return {
            'statusCode': 200,
            'body': json.dumps(summary)
        }
        
    except Exception as e:
        error_msg = f"Error in lambda execution: {str(e)}"
        print(error_msg)
        
        return {
            'statusCode': 500,
            'body': json.dumps({
                'status': 'error',
                'error': str(e)
            })
        }
