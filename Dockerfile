# Build the bgutil POT provider server (needs node >= 22; final image ships the
# node binary from this stage). Version must match the pip plugin pin in
# requirements.txt (bgutil-ytdlp-pot-provider).
FROM node:bookworm-slim AS pot-final
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates

RUN mkdir -p /build \
    && git clone https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git /build \
    && cd /build/server \
    && npm ci --no-audit --no-fund \
    && npx tsc \
    && test -f build/main.js \
    && npm ci --omit=dev --no-audit --no-fund \
    && mkdir -p /opt/bgutil-pot-provider/bin \
    && cp -r build node_modules package.json /opt/bgutil-pot-provider/ \
    && cp /usr/local/bin/node /opt/bgutil-pot-provider/bin/node

FROM python:3.12-slim

COPY --from=pot-final /opt/bgutil-pot-provider /opt/bgutil-pot-provider

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
RUN pip install --no-cache-dir -r requirements.txt --upgrade

# Git version for /info endpoint (passed during build)
ARG GIT_VERSION=""
ENV GIT_VERSION=${GIT_VERSION}

# Create downloads and data directories
RUN mkdir -p /downloads /app/data /app/static/vendor

# Download js and css (alpinejs & videojs)
RUN curl -L https://unpkg.com/alpinejs -o static/vendor/alpine.min.js
RUN curl -L https://unpkg.com/video.js/dist/video-js.min.css -o static/vendor/video-js.css
RUN curl -L https://unpkg.com/video.js/dist/video.min.js -o static/vendor/video.min.js

# For DNS trick
COPY ./start.sh /app/start.sh

RUN chmod +x /app/start.sh

# Environment variables
ENV HOST=
ENV PORT=8085
ENV DOWNLOAD_DIR=/downloads
ENV DATA_DIR=/app/data

EXPOSE 8085

#CMD ["uvicorn", "server:app", "--host", "", "--port", "8085", "--log-level", "info"]
CMD ["/app/start.sh"]
