from google import genai
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)


class GeminiClient:
    def __init__(self):
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.model = settings.GEMINI_MODEL

    def generate_explanation(self, prompt: str) -> str:
        try:
            response = self.client.models.generate_content(
                model=self.model,
                contents=prompt,
            )

            if hasattr(response, "text") and response.text:
                return response.text

            return (
                "AI explanation is temporarily unavailable. "
                "The recipe shown above is medically safe and age-appropriate "
                "according to Sri Lanka Family Health Bureau (FHB) guidelines."
            )

        except Exception as e:
            logger.error(f"Gemini API error: {e}")
            return (
                "AI explanation is temporarily unavailable. "
                "The recipe shown above is medically safe and age-appropriate "
                "according to Sri Lanka Family Health Bureau (FHB) guidelines."
            )


gemini_client = GeminiClient()