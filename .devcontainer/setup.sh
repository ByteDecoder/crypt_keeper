#!/bin/bash
set -e

echo "🚀 Setting up CryptKeeper development environment..."

# Install gems first
echo "💎 Installing Ruby gems..."
bundle install

# Install IDE tools separately (not in gemspec to avoid CI/Ruby version issues)
echo "🔧 Installing IDE tools (ruby-lsp, solargraph)..."
if ! gem list -i ruby-lsp > /dev/null 2>&1; then
    gem install ruby-lsp --no-document || echo "⚠️  Warning: Could not install ruby-lsp"
fi
if ! gem list -i solargraph > /dev/null 2>&1; then
    gem install solargraph --no-document || echo "⚠️  Warning: Could not install solargraph"
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
