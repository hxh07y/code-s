#!/bin/bash
set -e

mkdir -p /workspace
cd /workspace

# --- Check required environment variables ---
if [ -z "$GITHUB_TOKEN" ]; then
  echo "❌ GITHUB_TOKEN not set. Please configure it in Render environment."
  exit 1
fi
if [ -z "$GIT_REPO" ]; then
  echo "❌ GIT_REPO not set. Example: yourusername/your-private-repo"
  exit 1
fi

# --- Clone or update your repo ---
if [ ! -d "/workspace/app/.git" ]; then
  echo "📦 Cloning repository for the first time..."
  git clone https://${GITHUB_TOKEN}@github.com/${GIT_REPO}.git app
else
  echo "🔁 Repository already exists. Pulling latest changes..."
  cd app
  git fetch origin main || git fetch origin master
  git reset --hard origin/$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's@^origin/@@')
  cd ..
fi

cd app

# --- Create local.properties if missing ---
if [ ! -f "local.properties" ]; then
  echo "🛠️ Creating local.properties..."
  cat <<EOF > local.properties
sdk.dir=/opt/android-sdk
EOF
else
  echo "✅ local.properties already exists, skipping."
fi

# --- SDK setup ---
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# --- Verify Gradle wrapper ---
if [ ! -f "./gradlew" ]; then
  echo "⚙️ gradlew not found! Initializing Gradle wrapper..."
  gradle wrapper
fi
chmod +x ./gradlew

# --- Print environment summary ---
echo "-----------------------------------"
echo "Workspace: $(pwd)"
echo "SDK Root: $ANDROID_SDK_ROOT"
echo "Repo: $GIT_REPO"
echo "-----------------------------------"

# --- Launch code-server ---
echo "🚀 Starting code-server..."
exec code-server --auth password --port 8080 /workspace/app
