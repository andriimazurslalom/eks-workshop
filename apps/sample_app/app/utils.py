import os

import boto3
from botocore.exceptions import ClientError


def get_secret(secret_name_env_var: str, local_fallback: str = None) -> str:
    """
    Fetch a secret from AWS Secrets Manager using the secret name from an environment variable.

    Args:
        secret_name_env_var: Environment variable name containing the secret name
        local_fallback: Optional fallback value for local development

    Returns:
        The secret value

    Raises:
        ValueError: If secret not found and no fallback provided
    """
    secret_name = os.getenv(secret_name_env_var)

    if not secret_name:
        if local_fallback is not None:
            print(
                f"Warning: Environment variable '{secret_name_env_var}' not set. "
                f"Using local fallback."
            )
            return local_fallback
        raise ValueError(f"Environment variable '{secret_name_env_var}' not set")

    # Try to fetch from AWS Secrets Manager
    try:
        aws_region = os.getenv("AWS_REGION") or os.getenv("AWS_DEFAULT_REGION")
        client_kwargs = {"region_name": aws_region} if aws_region else {}
        client = boto3.client("secretsmanager", **client_kwargs)
        response = client.get_secret_value(SecretId=secret_name)

        # Handle both string and binary secrets
        if "SecretString" in response:
            return response["SecretString"]
        else:
            return response["SecretBinary"].decode("utf-8")

    except ClientError as e:
        # Fallback for local development
        if local_fallback is not None:
            print(
                f"Warning: Failed to fetch secret '{secret_name}' from AWS."
                f"Using local fallback."
            )
            return local_fallback
        else:
            raise ValueError(f"Failed to fetch secret '{secret_name}': {e}")


def secret_is_configured(secret_name_env_var: str, local_fallback: str = None) -> bool:
    try:
        return bool(get_secret(secret_name_env_var, local_fallback))
    except Exception:
        return False
