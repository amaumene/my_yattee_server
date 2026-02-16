FROM python:3.12-slim


# Install system dependencies including deno for yt-dlp JS challenge solving
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    curl \
    unzip \
    nodejs \
    npm \
    git \
    && curl -fsSL https://deno.land/install.sh | sh \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/yattee/yattee-server.git /app

WORKDIR /app

# Add deno to PATH
ENV DENO_INSTALL="/root/.deno"
ENV PATH="${DENO_INSTALL}/bin:${PATH}"

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Git version for /info endpoint (passed during build)
ARG GIT_VERSION=""
ENV GIT_VERSION=${GIT_VERSION}

# Install vendor JS/CSS (Alpine.js, Video.js) from npm
RUN npm install && rm -rf node_modules

# Create downloads and data directories
RUN mkdir -p /downloads /app/data /app/static

COPY ./start.sh /app/start.sh

RUN chmod +x /app/start.sh

# Environment variables
ENV HOST=::
ENV PORT=8085
ENV DOWNLOAD_DIR=/downloads
ENV DATA_DIR=/app/data

# Optional: auto-provisioning (set via docker-compose or .env)
# ADMIN_USERNAME + ADMIN_PASSWORD - auto-create/update admin user on startup
# INVIDIOUS_INSTANCE_URL - configure Invidious instance and enable proxy

EXPOSE 8085

#CMD ["uvicorn", "server:app", "--host", "", "--port", "8085", "--log-level", "info"]
CMD ["/app/start.sh"]
