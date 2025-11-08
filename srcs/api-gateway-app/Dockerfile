# Use a stable and lightweight base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy dependency list
COPY requirements.txt .

# Upgrade pip and install dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the source code
COPY . .

# Expose the port your Flask app runs on (optional, adjust if needed)
EXPOSE 5000

# Run the application
CMD ["python3", "server.py"]
