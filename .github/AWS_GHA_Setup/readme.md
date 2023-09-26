# Configure AWS with GitHub Actions to run Terrform(IaC)

### 1. Create an OPenID Connect in AWS 
* IAM > Access Management > Identity Providers > OpenID Connect
  * Provider URL: https://token.actions.githubusercontent.com
  * Audience: sts.amazonaws.com
  ![image](https://github.com/Krishna-kanth95/ghar/assets/93731192/c7cf1efa-bad2-433b-8732-c7f7d3e56473)

### 2. Create an S3 Bucket to store the Terrform remote state
  ![image](https://github.com/Krishna-kanth95/ghar/assets/93731192/97f7edab-d7ad-41da-bbf4-931a8f47dff5)

### 3. Create an IAM Role to give access to GitHub

```
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::YOUR_ACCOUNT_NUMBER:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:*"
                }
            }
        }
    ]
}
```
