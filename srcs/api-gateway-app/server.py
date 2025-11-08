from app import create_app
from waitress import serve
import os

# Default to port 5000 if APP_PORT is not set
APP_PORT = os.getenv("APP_PORT", "5000")

app = create_app()

# Run the application using Waitress
serve(app, listen=f"*:{APP_PORT}")