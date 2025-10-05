create-bedrock-api-key --inference-profile-name <name> --region <region> --cost-tag-key <key> [options]

説明:
    AWS BedrockのApplication Inference Profileを作成し、専用のAPIキーを生成します。
    指定したinference profile名でBedrockリソースを作成し、IAMユーザーと認証情報を自動生成します。

必須オプション:
    --inference-profile-name NAME   作成するinference profileの名前
    --region REGION                 AWS リージョン
    --cost-tag-key KEY              コスト管理用のタグキー

オプション:
    --source-model-arn ARN          ベースとなるモデルのARN
                                    (デフォルト: リージョンのClaude Sonnet 4モデル)
    
    --credential-age-days DAYS      APIキーの有効期限（日数）
                                    (デフォルト: 0 = 無制限)
    
    --help                          このヘルプメッセージを表示

例:
    # 基本的な使用方法
    create-bedrock-api-key --inference-profile-name my-project --region us-east-1 --cost-tag-key ProjectCost
    
    # 有効期限付きの認証情報を作成
    create-bedrock-api-key --inference-profile-name my-project --region us-east-1 --cost-tag-key ProjectCost --credential-age-days 30
    
    # 別のモデルを指定
    create-bedrock-api-key --inference-profile-name my-project --region us-east-1 --cost-tag-key ProjectCost --source-model-arn arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0

出力:
    成功時にServiceCredentialSecretが出力され、これをAPIキーとして使用できます。

前提条件:
    - AWS CLI認証情報が設定済みであること
    - 以下のIAM権限が必要:
      * bedrock:CreateInferenceProfile
      * bedrock:GetInferenceProfile
      * bedrock:TagResource
      * bedrock:ListFoundationModels
      * iam:CreateUser
      * iam:GetUser
      * iam:PutUserPolicy
      * iam:CreateServiceSpecificCredential
      * iam:ListServiceSpecificCredentials
      * sts:GetCallerIdentity
