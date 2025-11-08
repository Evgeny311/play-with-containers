from waitress import serve
from app import create_app
import os

# --- Use default port 5002 if APP_PORT is not set ---
PORT = os.getenv("APP_PORT", "5002")

app = create_app()

print(f"Inventory app listening on port {PORT}...")

# --- Start the server ---
serve(app, listen=f"*:{PORT}")
