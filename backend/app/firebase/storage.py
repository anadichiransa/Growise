import uuid
from fastapi import UploadFile
from firebase_admin import storage


async def upload_avatar_to_storage(file: UploadFile, storage_path: str) -> str:
    """
    Upload avatar image to Firebase Storage.
    Returns the public download URL.
    """
    bucket = storage.bucket()

    extension = _get_extension(file.content_type)
    blob_name = f"{storage_path}/{uuid.uuid4().hex}{extension}"

    blob = bucket.blob(blob_name)
    contents = await file.read()
    blob.upload_from_string(contents, content_type=file.content_type)
    blob.make_public()

    return blob.public_url


def _get_extension(content_type: str) -> str:
    return {
        "image/jpeg": ".jpg",
        "image/png":  ".png",
        "image/webp": ".webp",
    }.get(content_type, ".jpg")