FROM python:3.11-slim-bookworm

# Chrome dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl gnupg unzip xvfb \
    libglib2.0-0 libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libdbus-1-3 libxkbcommon0 libxcomposite1 \
    libxdamage1 libxfixes3 libxrandr2 libgbm1 libpango-1.0-0 \
    libcairo2 libasound2 libatspi2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY solver.py service.py clientsend.py ./

ENV CHROME_PATH=/usr/bin/google-chrome-stable
ENV TS_PROFILE_DIR=/tmp/ts_profile
ENV PORT=8191
ENV MAX_WORKERS=2
ENV DISPLAY=:99

EXPOSE 8191

CMD Xvfb :99 -screen 0 1280x900x24 & \
    python service.py
