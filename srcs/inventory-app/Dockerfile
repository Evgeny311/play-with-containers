# Use stable slim image for compatibility
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements and upgrade pip
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Expose port (optional)
EXPOSE 5002

# Run the application
CMD ["python3", "server.py"]
