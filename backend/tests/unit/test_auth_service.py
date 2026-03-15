import pytest
from unittest.mock import MagicMock, patch
from app.services.auth_service import AuthService
from app.models.user import UserCreate


def make_user(
    uid="test-uid-123",
    full_name="Test User",
    email="test@example.com",
    phone_number="+94771234567",
    language_preference="English"
):
    return UserCreate(
        uid=uid,
        full_name=full_name,
        email=email,
        phone_number=phone_number,
        language_preference=language_preference,
    )


class TestSaveUserProfile:

    def test_saves_new_user_successfully(self):
        mock_doc = MagicMock()
        mock_doc.exists = False

        mock_ref = MagicMock()
        mock_ref.get.return_value = mock_doc

        with patch('app.services.auth_service.db') as mock_db:
            mock_db.collection.return_value.document.return_value = mock_ref

            user = make_user()
            result = AuthService.save_user_profile("test-uid-123", user)

            assert "error" not in result
            assert result["uid"] == "test-uid-123"
            assert result["email"] == "test@example.com"
            assert result["full_name"] == "Test User"
            mock_ref.set.assert_called_once()

    def test_rejects_duplicate_user(self):
        mock_doc = MagicMock()
        mock_doc.exists = True

        mock_ref = MagicMock()
        mock_ref.get.return_value = mock_doc

        with patch('app.services.auth_service.db') as mock_db:
            mock_db.collection.return_value.document.return_value = mock_ref

            user = make_user()
            result = AuthService.save_user_profile("test-uid-123", user)

            assert "error" in result
            assert result["error"] == "User profile already exists"

    def test_handles_database_error_gracefully(self):
        with patch('app.services.auth_service.db') as mock_db:
            mock_db.collection.return_value.document.side_effect = \
                Exception("DB connection failed")

            user = make_user()
            result = AuthService.save_user_profile("test-uid-123", user)

            assert "error" in result

    def test_saves_all_required_fields(self):
        mock_doc = MagicMock()
        mock_doc.exists = False

        mock_ref = MagicMock()
        mock_ref.get.return_value = mock_doc

        with patch('app.services.auth_service.db') as mock_db:
            mock_db.collection.return_value.document.return_value = mock_ref

            user = make_user(
                uid="uid-456",
                full_name="Sahan Perera",
                email="sahan@example.com",
                phone_number="+94712345678",
                language_preference="Sinhala"
            )
            result = AuthService.save_user_profile("uid-456", user)

            saved_data = mock_ref.set.call_args[0][0]
            assert saved_data["full_name"] == "Sahan Perera"
            assert saved_data["phone_number"] == "+94712345678"
            assert saved_data["language_preference"] == "Sinhala"
            assert "created_at" in saved_data


class TestGetUserProfile:

    def test_returns_existing_user(self):
        mock_doc = MagicMock()
        mock_doc.exists = True
        mock_doc.to_dict.return_value = {
            "uid": "test-uid-123",
            "full_name": "Test User",
            "email": "test@example.com",
            "phone_number": "+94771234567",
            "language_preference": "English",
            "created_at": "2024-01-01T00:00:00",
        }

        with patch('app.services.auth_service.db') as mock_db:
            mock_db.collection.return_value.document.return_value\
                .get.return_value = mock_doc

            result = AuthService.get_user_profile("test-uid-123")

            assert result["uid"] == "test-uid-123"
            assert result["full_name"] == "Test User"

    def test_returns_error_for_missing_user(self):
        mock_doc = MagicMock()
        mock_doc.exists = False

        with patch('app.services.auth_service.db') as mock_db:
            mock_db.collection.return_value.document.return_value\
                .get.return_value = mock_doc

            result = AuthService.get_user_profile("nonexistent-uid")

            assert "error" in result
            assert result["error"] == "User not found"

    def test_handles_database_error_gracefully(self):
        with patch('app.services.auth_service.db') as mock_db:
            mock_db.collection.return_value.document.return_value\
                .get.side_effect = Exception("DB error")

            result = AuthService.get_user_profile("test-uid-123")

            assert "error" in result