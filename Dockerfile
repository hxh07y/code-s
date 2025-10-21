# ============================
# Android + code-server image
# ============================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# --- Install dependencies ---
RUN apt-get update && apt-get install -y \
    git curl wget unzip zip \
    openjdk-17-jdk \
    python3 jq \
    && rm -rf /var/lib/apt/lists/*

# --- Install Android SDK Command-line Tools ---
RUN mkdir -p /opt/android-sdk/cmdline-tools && \
    cd /opt/android-sdk/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip commandlinetools-linux-*.zip && \
    rm commandlinetools-linux-*.zip && \
    mkdir -p /opt/android-sdk/cmdline-tools/latest && \
    mv cmdline-tools/* /opt/android-sdk/cmdline-tools/latest/

# --- Environment setup ---
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:/opt/android-sdk/platform-tools:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/build-tools/35.0.0

# --- Install Android SDK components (Android 15 / API 35) ---
RUN yes | sdkmanager --sdk_root=/opt/android-sdk \
    "platform-tools" \
    "build-tools;35.0.0" \
    "platforms;android-35" && \
    yes | sdkmanager --licenses

# --- Install code-server ---
RUN curl -fsSL https://code-server.dev/install.sh | sh

# --- Prepare workspace and startup script ---
RUN mkdir -p /workspace
WORKDIR /workspace
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# --- Expose code-server port ---
EXPOSE 8080

# --- Default entrypoint ---
ENTRYPOINT ["/usr/local/bin/start.sh"]
