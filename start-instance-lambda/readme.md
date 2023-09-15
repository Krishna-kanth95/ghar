# Trigger Lmabda with CW and SNS when server CPU util>x%

## Cloudwatch -> SNS
CW can trigger SNS out of the box. No role needed
SNS access policy needs to allow SNS publish by CW

```
{
  "Version": "2008-10-17",
  "Id": "example-ID",
  "Statement": [
    {
      "Sid": "example-statement-ID",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudwatch.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:REGION:ACCOUNT_ID:TOPIC_NAME"
    }
  ]
}
```
