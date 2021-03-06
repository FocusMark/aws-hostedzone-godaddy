if [ -z "$deployed_environment" ]
    then 
        echo "\$deployed_environment environment variable is unset!"
        echo "Aborting deployment."
        exit
fi

product_name=$focusmark_productname

echo Deploying into the $deployed_environment environment.

# Execute the AWS CloudFormation for deploying the GoDaddy Secrets stack.
secrets_stack_name=$product_name-global-cf-godaddy-secrets
secrets_template_file='secrets-template.yaml'

cfn-lint $secrets_template_file

echo Deploying the $secrets_stack_name stack.
aws cloudformation deploy \
    --template-file $secrets_template_file \
    --stack-name $secrets_stack_name \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        TargetEnvironment=$deployed_environment \
        ProductName=$product_name \
        TargetDomain=$target_domain \
        TargetApiKey=$target_api_key \
        TargetApiSecret=$target_api_secret

# Execute the SAM CLI Deploy command to upload the Lambdas to S3 and deploy them
sam_stack_name=$product_name-global-sam-hostedzone-godaddy
sam_template_file='template.sam'
sam_s3_bucket_name=$product_name-global-s3-deployments

echo Deploying the $sam_stack_name stack.
cd src/godaddy-resolver
npm install
cfn-lint $sam_template_file

sam deploy \
  --template-file $sam_template_file \
  --stack-name $sam_stack_name \
  --s3-bucket $sam_s3_bucket_name \
  --s3-prefix $sam_stack_name \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
      ProductName=$product_name \
      TargetDomain=$target_domain \
      TargetApiUrl=$target_api_url