# Use stable slim base image for compatibility
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements and upgrade pip
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the source code
COPY . .

# Expose the port (optional, if needed)
EXPOSE 5001

# Run the application
ENTRYPOINT ["python3", "server.py"]
