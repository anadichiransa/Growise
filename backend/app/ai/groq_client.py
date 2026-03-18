"""
Groq AI Client
================
Wraps the Groq Python SDK for generating recipe explanations.

Model: llama3-8b-8192 (fast, good at following instructions)
  - 8b = 8 billion parameters — fast enough for 10-15 second responses
  - 8192 = context window — plenty for recipe prompts

Usage:
    from app.ai.groq_client import groq_client
    text = groq_client.generate_explanation("Your prompt here")
"""

from groq import Groq
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)


class GroqClient:
    def __init__(self):
        self.client = Groq(api_key=settings.GROQ_API_KEY)
        self.model  = settings.GROQ_MODEL

    def generate_explanation(self, prompt: str) -> str:
        """
        Send a prompt to Groq and return the AI response as a string.

        If anything fails (API down, rate limit, timeout), returns a safe
        fallback message so the user still sees a result.

        Args:
            prompt: The full prompt string to send to the model

        Returns:
            The model's text response, or a fallback string on error
        """
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": (
                            "You are a pediatric nutritionist helping Sri Lankan mothers "
                            "feed their babies safely. Be warm, clear, and practical."
                        )
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.7,     # Some creativity but stays grounded
                max_tokens=1500,     # ~300-400 words — enough for a thorough explanation
            )
            return response.choices[0].message.content

        except Exception as e:
            logger.error(f"Groq API error: {e}")
            # Return a graceful fallback — the recipe is still shown
            return (
                "AI explanation is temporarily unavailable. "
                "The recipe shown above is medically safe and age-appropriate "
                "according to Sri Lanka Family Health Bureau (FHB) guidelines."
            )


# Singleton — one instance shared across all requests
groq_client = GroqClient()
