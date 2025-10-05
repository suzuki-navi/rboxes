## Dockerfile

```text Dockerfile
FROM debian:bookworm
RUN apt update
RUN apt install -y mandoc less curl unzip
RUN apt install -y jq

WORKDIR /usr/local

# Install AWS CLI v2
RUN curl -SsfLk "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscli-exe-linux-x86_64.zip
RUN unzip awscli-exe-linux-x86_64.zip
RUN ./aws/install --bin-dir /usr/local/aws/bin/

ENV PATH /usr/local/aws/bin:$PATH

COPY . /app
```

## main.sh

```bash main.sh
script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
pwd=$(pwd)

# Show help if no arguments provided
if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    cat "$script_dir/help.txt"
    exit 0
fi

TMP_DIR=$(mktemp -d)
CLEANUP_DIRS=("$TMP_DIR")
trap 'rm -rf "${CLEANUP_DIRS[@]}"' EXIT

# Load environment variables
source $script_dir/load-env.sh
bash $script_dir/write-env.sh "$TMP_DIR/.rx.env" \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    AWS_REGION \
    ;

# Run the main script
$script_dir/rdockrun --envfile "$TMP_DIR/.rx.env" $script_dir bash /app/create-bedrock-api-key.sh "$@"
```

## create-bedrock-api-key.sh

```bash create-bedrock-api-key.sh
set -euo pipefail

# Option argument defaults
region="${AWS_REGION:-}"
source_model_arn=""
cost_tag_key=""
credential_age_days="0"
inference_profile_name=""

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        --inference-profile-name)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --inference-profile-name requires a value" >&2
                exit 1
            fi
            inference_profile_name="$2"
            shift 2
            ;;
        --region)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --region requires a value" >&2
                exit 1
            fi
            region="$2"
            shift 2
            ;;
        --source-model-arn)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --source-model-arn requires a value" >&2
                exit 1
            fi
            source_model_arn="$2"
            shift 2
            ;;
        --cost-tag-key)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --cost-tag-key requires a value" >&2
                exit 1
            fi
            cost_tag_key="$2"
            shift 2
            ;;
        --credential-age-days)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --credential-age-days requires a value" >&2
                exit 1
            fi
            credential_age_days="$2"
            shift 2
            ;;
        --help)
            cat /app/help.txt
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

# Validate required inputs
if [[ -z "$inference_profile_name" ]]; then
    echo "Error: --inference-profile-name is required" >&2
    echo "Usage: create-bedrock-api-key --inference-profile-name <name> --region <region> --cost-tag-key <key> [options]" >&2
    exit 1
fi

if [[ -z "$region" ]]; then
    echo "Error: --region is required" >&2
    echo "Usage: create-bedrock-api-key --inference-profile-name <name> --region <region> --cost-tag-key <key> [options]" >&2
    exit 1
fi

if [[ -z "$cost_tag_key" ]]; then
    echo "Error: --cost-tag-key is required" >&2
    echo "Usage: create-bedrock-api-key --inference-profile-name <name> --region <region> --cost-tag-key <key> [options]" >&2
    exit 1
fi

# Set default source_model_arn if not specified
if [[ -z "$source_model_arn" ]]; then
    source_model_arn="arn:aws:bedrock:${region}::foundation-model/anthropic.claude-sonnet-4-20250514-v1:0"
fi

if [[ ! "$inference_profile_name" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
    echo "Error: inference_profile_name must contain only alphanumeric characters, hyphens, and underscores" >&2
    exit 1
fi

if [[ ! "$credential_age_days" =~ ^[0-9]+$ ]] || [[ "$credential_age_days" -lt 0 ]]; then
    echo "Error: credential_age_days must be a non-negative number (0 = unlimited)" >&2
    exit 1
fi

echo "========================================="
echo "Creating Bedrock API Key"
echo "========================================="
echo
echo "Profile name: $inference_profile_name"
echo "Region: $region"
echo "Source model ARN: $source_model_arn"
echo "Cost tag: $cost_tag_key=$inference_profile_name"
if [[ "$credential_age_days" -eq 0 ]]; then
    echo "Credential age: Unlimited"
else
    echo "Credential age: $credential_age_days days"
fi
echo

# Step 1: Check prerequisites
echo "Step 1: Checking prerequisites..."

# Check AWS CLI credentials
if ! aws sts get-caller-identity --region "$region" >/dev/null 2>&1; then
    echo "Error: AWS CLI credentials not configured or invalid" >&2
    exit 1
fi

# Check if Bedrock is available in the region
if ! aws bedrock list-foundation-models --region "$region" >/dev/null 2>&1; then
    echo "Error: Bedrock is not available in region $region or insufficient permissions" >&2
    exit 1
fi

echo "✓ AWS credentials verified"
echo "✓ Bedrock available in region $region"

# Step 2: Create Application Inference Profile
echo
echo "Step 2: Creating Application Inference Profile..."

inference_profile_name_full="AIP-$inference_profile_name"

# Check if profile already exists
if aws bedrock get-inference-profile --inference-profile-identifier "$inference_profile_name_full" --region "$region" >/dev/null 2>&1; then
    echo "Warning: Inference profile $inference_profile_name_full already exists"
    inference_profile_arn=$(aws bedrock get-inference-profile --inference-profile-identifier "$inference_profile_name_full" --region "$region" --query 'inferenceProfileArn' --output text)
else
    # Create new profile
    create_result=$(aws bedrock create-inference-profile \
        --inference-profile-name "$inference_profile_name_full" \
        --model-source copyFrom="$source_model_arn" \
        --region "$region" \
        --output json)
    
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create inference profile" >&2
        exit 1
    fi
    
    inference_profile_arn=$(echo "$create_result" | jq -r '.inferenceProfileArn')
    echo "✓ Created inference profile: $inference_profile_arn"
fi

# Step 3: Add cost tag
echo
echo "Step 3: Adding cost tag..."

if aws bedrock tag-resource \
    --resource-arn "$inference_profile_arn" \
    --tags key="$cost_tag_key",value="$inference_profile_name" \
    --region "$region" >/dev/null 2>&1; then
    echo "✓ Added cost tag: $cost_tag_key=$inference_profile_name"
else
    echo "Warning: Failed to add cost tag (may already exist)"
fi

# Step 4: Create IAM User
echo
echo "Step 4: Creating IAM User..."

iam_user_name="BedrockAPIKeyUser_$inference_profile_name"

# Check if user already exists
if aws iam get-user --user-name "$iam_user_name" >/dev/null 2>&1; then
    echo "Warning: IAM user $iam_user_name already exists"
else
    # Create new user
    if aws iam create-user --user-name "$iam_user_name" >/dev/null 2>&1; then
        echo "✓ Created IAM user: $iam_user_name"
    else
        echo "Error: Failed to create IAM user" >&2
        exit 1
    fi
fi

# Step 5: Attach policy
echo
echo "Step 5: Attaching IAM policy..."

policy_document=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowUsingBedrockBearerToken",
            "Effect": "Allow",
            "Action": [
                "bedrock:CallWithBearerToken"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "AllowUseOfOnlyThisApplicationInferenceProfile",
            "Effect": "Allow",
            "Action": [
                "bedrock:InvokeModel"
            ],
            "Resource": [
                "$inference_profile_arn"
            ]
        },
        {
            "Sid": "AllowInvocationsOnlyWhenUsingThatProfile",
            "Effect": "Allow",
            "Action": [
                "bedrock:InvokeModel"
            ],
            "Resource": [
                "arn:aws:bedrock:$region::foundation-model/*"
            ],
            "Condition": {
                "StringLike": {
                    "bedrock:InferenceProfileArn": "$inference_profile_arn"
                }
            }
        }
    ]
}
EOF
)

if aws iam put-user-policy \
    --user-name "$iam_user_name" \
    --policy-name "Bedrock-Application-Inference-Profile-Only" \
    --policy-document "$policy_document" >/dev/null 2>&1; then
    echo "✓ Attached IAM policy"
else
    echo "Error: Failed to attach IAM policy" >&2
    exit 1
fi

# Step 6: Create service-specific credentials
echo
echo "Step 6: Creating service-specific credentials..."

# Check if credentials already exist
existing_creds=$(aws iam list-service-specific-credentials --user-name "$iam_user_name" --service-name bedrock.amazonaws.com --query 'ServiceSpecificCredentials[?Status==`Active`]' --output json)

#if [[ $(echo "$existing_creds" | jq length) -gt 0 ]]; then
#    echo "Warning: Active service-specific credentials already exist for this user"
#    service_credential_id=$(echo "$existing_creds" | jq -r '.[0].ServiceSpecificCredentialId')
#    echo "Using existing credential ID: $service_credential_id"
#    
#    # We can't retrieve the secret for existing credentials
#    echo "Error: Cannot retrieve the secret for existing credentials." >&2
#    echo "Please delete existing credentials or use a different profile name." >&2
#    exit 1
#else
    # Create new credentials
    # Create credentials with or without age limit
    if [[ "$credential_age_days" -eq 0 ]]; then
        # Unlimited credentials (no age limit)
        cred_result=$(aws iam create-service-specific-credential \
            --user-name "$iam_user_name" \
            --service-name bedrock.amazonaws.com \
            --output json)
    else
        # Limited credentials with age limit
        cred_result=$(aws iam create-service-specific-credential \
            --user-name "$iam_user_name" \
            --service-name bedrock.amazonaws.com \
            --credential-age-days "$credential_age_days" \
            --output json)
    fi
    
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create service-specific credentials" >&2
        exit 1
    fi
    
    api_key=$(echo "$cred_result" | jq -r '.ServiceSpecificCredential.ServiceCredentialSecret')
    
    echo "✓ Created service-specific credentials"
#fi

# Step 7: Output results
echo
echo "========================================="
echo "Bedrock API Key created successfully"
echo "========================================="
echo
echo "Environment variables for Claude Code:"
echo "export AWS_BEARER_TOKEN_BEDROCK='$api_key'"
echo "export AWS_REGION='$region'"
echo "export ANTHROPIC_MODEL='$inference_profile_arn'"
echo "export CLAUDE_CODE_USE_BEDROCK=1"
echo
echo "Resources created:"
echo "- Inference Profile: $inference_profile_arn"
echo "- IAM User: $iam_user_name"
if [[ "$credential_age_days" -eq 0 ]]; then
    echo "- Credential expires: Never (unlimited)"
else
    echo "- Credential expires in: $credential_age_days days"
fi
echo
```