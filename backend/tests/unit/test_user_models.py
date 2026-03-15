import pytest
from pydantic import ValidationError
from app.models.user import UserCreate


class TestUserCreateValidation:

    def test_valid_user_passes(self):
        user = UserCreate(
            uid="test-uid-123",
            full_name="Test User",
            email="test@example.com",
            phone_number="+94771234567",
            language_preference="English",
        )
        assert user.email == "test@example.com"
        assert user.full_name == "Test User"

    def test_invalid_email_rejected(self):
        with pytest.raises(ValidationError):
            UserCreate(
                uid="test-uid",
                full_name="Test User",
                email="notanemail",
                phone_number="+94771234567",
            )

    def test_short_name_rejected(self):
        with pytest.raises(ValidationError):
            UserCreate(
                uid="test-uid",
                full_name="A",
                email="test@example.com",
                phone_number="+94771234567",
            )

    def test_invalid_phone_rejected(self):
        with pytest.raises(ValidationError):
            UserCreate(
                uid="test-uid",
                full_name="Test User",
                email="test@example.com",
                phone_number="0771234567",
            )

    def test_valid_phone_accepted(self):
        user = UserCreate(
            uid="test-uid",
            full_name="Test User",
            email="test@example.com",
            phone_number="+94771234567",
        )
        assert user.phone_number == "+94771234567"

    def test_default_language_is_english(self):
        user = UserCreate(
            uid="test-uid",
            full_name="Test User",
            email="test@example.com",
            phone_number="+94771234567",
        )
        assert user.language_preference == "English"

    def test_name_too_long_rejected(self):
        with pytest.raises(ValidationError):
            UserCreate(
                uid="test-uid",
                full_name="A" * 51,
                email="test@example.com",
                phone_number="+94771234567",
            )