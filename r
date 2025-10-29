 script will never even come close to 15 minutes.
Realistic Execution Times:
Instance CountLambda Execution TimeCodeBuild Time10 instances~1-2 seconds~2 minutes (cold start)100 instances~3-5 seconds~2 minutes1,000 instances~15-30 seconds~2.5 minutes10,000 instances~2-4 minutes~4 minutes
Why It's So Fast:
The script just makes AWS API calls - no heavy processing:
python# This is VERY fast
response = ec2_client.describe_instances()  # ← 1-2 seconds for 1000 instances

# Then just loops and uploads
for instance in instances:
    metadata = extract_metadata(instance)    # ← Instant (just dict operations)
    s3_client.put_object(...)                # ← ~50ms per upload
Math Breakdown (1,000 instances):

EC2 API call: 2 seconds
Process metadata: 1,000 × 0.001s = 1 second
Upload to S3: 1,000 × 0.05s = 50 seconds
Total: ~53 seconds

Even with 10,000 instances, you're looking at ~5 minutes max.
Lambda's 15-Minute Limit is For:

Video processing
Large data transformations
Machine learning inference
Complex ETL jobs
Image manipulation at scale

Not for simple API calls and JSON uploads!
Bottom Line:
You could monitor 100,000 instances and still finish in under 10 minutes. The 15-minute Lambda timeout is more than enough.
Lambda is absolutely the right choice here. CodeBuild is unnecessary overhead (cost + complexity) for this use case.
