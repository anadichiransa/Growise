import pytest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


class TestHealthEndpoints:

    def test_root_endpoint_returns_200(self):
        response = client.get("/")
        assert response.status_code == 200
        assert response.json()["message"] == "Growise API is running"

    def test_health_endpoint_returns_ok(self):
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "ok"


class TestSaveProfileEndpoint:

    def test_save_profile_success(self):
        mock_doc = MagicMock()
        mock_doc.exists = False
        mock_ref = MagicMock()
        mock_ref.get.return_value = mock_doc

        with patch('app.services.auth_service.db') as mock_db:
            mock_db.collection.return_value.document.return_value = mock_ref

            response = client.post("/api/v1/auth/profile", json={
                "uid": "firebase-uid-001",
                "full_name": "Sahan Perera",
                "email": "sahan@example.com",
                "phone_number": "+94771234567",
                "language_preference": "English",
            })

            assert response.status_code == 201
            data = response.json()
            assert data["uid"] == "firebase-uid-001"
            assert data["email"] == "sahan@example.com"

    def test_save_profile_duplicate_rejected(self):
        mock_doc = MagicMock()
        mock_doc.exists = True
        mock_ref = MagicMock()
        mock_ref.get.return_value = mock_doc

        with patch('app.services.auth_service.db') as mock_db:
            mock_db.collection.return_value.document.return_value = mock_ref

            response = client.post("/api/v1/auth/profile", json={
                "uid": "firebase-uid-001",
                "full_name": "Sahan Perera",
                "email": "sahan@example.com",
                "phone_number": "+94771234567",
                "language_preference": "English",
            })

            assert response.status_code == 400

    def test_save_profile_invalid_email_rejected(self):
        response = client.post("/api/v1/auth/profile", json={
            "uid": "test-uid",
            "full_name": "Nilmini Silva",
            "email": "notanemail",
            "phone_number": "+94771234567",
        })
        assert response.status_code == 422

    def test_save_profile_invalid_phone_rejected(self):
        response = client.post("/api/v1/auth/profile", json={
            "uid": "test-uid",
            "full_name": "Nilmini Silva",
            "email": "nilmini@example.com",
            "phone_number": "0771234567",
        })
        assert response.status_code == 422

    def test_save_profile_missing_fields_rejected(self):
        response = client.post("/api/v1/auth/profile", json={
            "email": "nilmini@example.com",
        })
        assert response.status_code == 422


class TestGetProfileEndpoint:

    def test_get_existing_profile(self):
        mock_doc = MagicMock()
        mock_doc.exists = True
        mock_doc.to_dict.return_value = {
            "uid": "firebase-uid-001",
            "full_name": "Sahan Perera",
            "email": "sahan@example.com",
            "phone_number": "+94771234567",
            "language_preference": "English",
            "created_at": "2024-01-01T00:00:00+00:00",
        }

        with patch('app.services.auth_service.db') as mock_db:
            mock_db.collection.return_value.document.return_value\
                .get.return_value = mock_doc

            response = client.get("/api/v1/auth/profile/firebase-uid-001")
            assert response.status_code == 200
            assert response.json()["uid"] == "firebase-uid-001"

    def test_get_nonexistent_profile_returns_404(self):
        mock_doc = MagicMock()
        mock_doc.exists = False

        with patch('app.services.auth_service.db') as mock_db:
            mock_db.collection.return_value.document.return_value\
                .get.return_value = mock_doc

            response = client.get("/api/v1/auth/profile/nonexistent-uid")
            assert response.status_code == 404