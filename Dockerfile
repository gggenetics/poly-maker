# 1. lightweight image with recent Python
FROM python:3.12-slim

# 2. system packages needed by web3, pandas, etc.
RUN apt-get update && apt-get install -y \
      gcc build-essential git curl && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js (required for poly_merger)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# 3. set workdir and copy only what we need
WORKDIR /app

# Copy package files first (for better Docker layer caching)
COPY requirements.txt .
COPY poly_merger/package*.json ./poly_merger/

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install Node.js dependencies for poly_merger
WORKDIR /app/poly_merger
RUN npm install

# Go back to main working directory
WORKDIR /app

# copy the rest of the code
COPY . .

# Create necessary directories
RUN mkdir -p data positions

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Expose port (if needed for monitoring/health checks)
EXPOSE 8000

# 4. run the main loop
CMD ["python", "main.py"]
