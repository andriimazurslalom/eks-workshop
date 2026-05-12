from app import utils
from botocore.exceptions import ClientError


def test_get_secret_uses_local_fallback_when_env_var_missing(monkeypatch):
    monkeypatch.delenv("DATABASE_URL_SECRET_NAME", raising=False)

    value = utils.get_secret(
        "DATABASE_URL_SECRET_NAME", local_fallback="sqlite://local"
    )

    assert value == "sqlite://local"


def test_get_secret_raises_when_env_var_missing_and_no_fallback(monkeypatch):
    monkeypatch.delenv("DATABASE_URL_SECRET_NAME", raising=False)

    try:
        utils.get_secret("DATABASE_URL_SECRET_NAME")
        assert False, "Expected ValueError"
    except ValueError as exc:
        assert "DATABASE_URL_SECRET_NAME" in str(exc)


def test_get_secret_reads_secret_string(monkeypatch):
    monkeypatch.setenv("JWT_SECRET_NAME", "sample-app/jwt-secret")
    monkeypatch.setenv("AWS_REGION", "eu-central-1")

    class FakeClient:
        def get_secret_value(self, SecretId):
            assert SecretId == "sample-app/jwt-secret"
            return {"SecretString": "super-secret-value"}

    monkeypatch.setattr(utils.boto3, "client", lambda service, **kwargs: FakeClient())

    value = utils.get_secret("JWT_SECRET_NAME")

    assert value == "super-secret-value"


def test_secret_is_configured_returns_false_on_client_error(monkeypatch):
    monkeypatch.setenv(
        "THIRD_PARTY_API_KEY_SECRET_NAME", "sample-app/third-party-api-key"
    )

    error = ClientError(
        error_response={
            "Error": {"Code": "AccessDeniedException", "Message": "denied"}
        },
        operation_name="GetSecretValue",
    )

    class FakeClient:
        def get_secret_value(self, SecretId):
            raise error

    monkeypatch.setattr(utils.boto3, "client", lambda service, **kwargs: FakeClient())

    assert utils.secret_is_configured("THIRD_PARTY_API_KEY_SECRET_NAME") is False
