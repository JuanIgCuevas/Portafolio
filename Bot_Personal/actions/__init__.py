"""
Custom actions package initializer.

Note:
- Previous versions triggered a Telegram setWebhook on import by reading
    credentials.yml and calling Telegram's API. That caused errors when the
    template placeholders were present and duplicated the webhook management
    that Rasa already performs.

- Rasa should manage Telegram webhooks using the credentials file passed at
    runtime (start.ps1 generates credentials.runtime.yml). To avoid side effects
    and placeholder leaks, we intentionally do nothing here.
"""

__all__ = []