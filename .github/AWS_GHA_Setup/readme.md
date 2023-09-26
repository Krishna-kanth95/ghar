# Configure AWS with GitHub Actions to run Terrform(IaC)

### 1. Create an OPenID Connect in AWS 
* IAM > Access Management > Identity Providers > OpenID Connect
  ** Provider URL: https://token.actions.githubusercontent.com
  ** Audience: sts.amazonaws.com
  ![image](https://github.com/Krishna-kanth95/ghar/assets/93731192/c7cf1efa-bad2-433b-8732-c7f7d3e56473)

