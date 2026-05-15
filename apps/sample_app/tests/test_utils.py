from botocore.exceptions import ClientError

from app import utils


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


def test_get_app_version_uses_env_var_when_present(monkeypatch):
    monkeypatch.setenv("APP_VERSION", "0.2.0")

    value = utils.get_app_version()

    assert value == "0.2.0"


def test_get_app_version_falls_back_to_package_metadata(monkeypatch):
    monkeypatch.delenv("APP_VERSION", raising=False)

    def fake_version(package_name):
        assert package_name == "sample-app"
        return "0.2.0"

    monkeypatch.setattr(utils, "version", fake_version)

    value = utils.get_app_version()

    assert value == "0.2.0"


def test_get_app_version_returns_unknown_when_package_metadata_missing(monkeypatch):
    monkeypatch.delenv("APP_VERSION", raising=False)

    def raise_package_not_found(package_name):
        raise utils.PackageNotFoundError

    monkeypatch.setattr(utils, "version", raise_package_not_found)

    value = utils.get_app_version()

    assert value == "unknown"
