#!/bin/bash
set -e

echo "🚀 Setting up CryptKeeper development environment..."

# Install system dependencies for native gems
echo "📦 Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq libyaml-dev > /dev/null 2>&1
echo "✅ System dependencies installed"

# Setup SSH for git operations
echo "🔑 Setting up SSH configuration..."
if [ -d /home/developer/.ssh-host ]; then
    # Copy SSH keys and config from host mount
    mkdir -p /home/developer/.ssh
    cp -r /home/developer/.ssh-host/* /home/developer/.ssh/ 2>/dev/null || true
    chmod 700 /home/developer/.ssh
    chmod 600 /home/developer/.ssh/* 2>/dev/null || true
    # Create empty config file if it doesn't exist (required by git)
    touch /home/developer/.ssh/config
    chmod 600 /home/developer/.ssh/config
    echo "✅ SSH keys configured"
else
    echo "⚠️  No SSH keys mounted from host"
fi

# Install gems first
echo "💎 Installing Ruby gems..."
bundle install

# Install IDE tools separately (not in gemspec to avoid CI/Ruby version issues)
echo "🔧 Installing IDE tools (ruby-lsp)..."
if ! gem list -i ruby-lsp > /dev/null 2>&1; then
    gem install ruby-lsp --no-document || echo "⚠️  Warning: Could not install ruby-lsp"
fi

echo "✅ IDE tools installed"

# Install Appraisal gemfiles
if [ -f ./bin/install-appraisals.sh ]; then
    echo "📦 Installing Appraisal gemfiles..."
    ./bin/install-appraisals.sh
else
    echo "⚠️  Warning: ./bin/install-appraisals.sh not found, skipping appraisal installation"
fi

# Copy database config if it doesn't exist
if [ ! -f spec/database.yml ]; then
    echo "📋 Copying database configuration..."
    cp .devcontainer/database.yml spec/database.yml
fi

# Wait for databases to be ready with timeout
echo "⏳ Waiting for PostgreSQL (max 30s)..."
timeout=30
counter=0
until pg_isready -h postgres -U postgres > /dev/null 2>&1 || [ $counter -eq $timeout ]; do
    sleep 1
    counter=$((counter + 1))
done

if [ $counter -eq $timeout ]; then
    echo "⚠️  PostgreSQL not ready, skipping database creation"
else
    echo "🐘 Creating PostgreSQL database..."
    PGPASSWORD=deploy psql -h postgres -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'crypt_keeper_providers'" | grep -q 1 || \
        PGPASSWORD=deploy psql -h postgres -U postgres -c "CREATE DATABASE crypt_keeper_providers;"
fi

echo "⏳ Waiting for MySQL (max 30s)..."
counter=0
until mysqladmin ping -h mysql -u root -pdeploy --silent > /dev/null 2>&1 || [ $counter -eq $timeout ]; do
    sleep 1
    counter=$((counter + 1))
done

if [ $counter -eq $timeout ]; then
    echo "⚠️  MySQL not ready, skipping database creation"
else
    echo "🐬 Creating MySQL database..."
    mysql -h mysql -u root -pdeploy -e "CREATE DATABASE IF NOT EXISTS crypt_keeper_providers;"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "🎉 You can now run tests with:"
echo "   bundle exec rspec"
echo ""
echo "📊 Or run with coverage:"
echo "   bundle exec rake spec"
