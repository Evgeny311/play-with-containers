from app.consume_queue import consume_and_store_order
from app.orders import Base
from sqlalchemy import create_engine
import os

if __name__ == "__main__":
    # --- Load environment variables with defaults ---
    BILLING_DB_USER = os.getenv("BILLING_DB_USER", "postgres")
    BILLING_DB_PASSWORD = os.getenv("BILLING_DB_PASSWORD", "postgres")
    BILLING_DB_NAME = os.getenv("BILLING_DB_NAME", "billing_db")
    BILLING_DB_HOST = os.getenv("BILLING_DB_HOST", "localhost")
    BILLING_DB_PORT = os.getenv("BILLING_DB_PORT", "5432")

    # --- Build DB connection URI ---
    DB_URI = (
        f"postgresql://{BILLING_DB_USER}:{BILLING_DB_PASSWORD}"
        f"@{BILLING_DB_HOST}:{BILLING_DB_PORT}/{BILLING_DB_NAME}"
    )

    # --- Create engine and initialize tables ---
    engine = create_engine(DB_URI, echo=True, future=True)
    Base.metadata.create_all(engine)

    # --- Start consuming orders from queue ---
    consume_and_store_order(engine)
