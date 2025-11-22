#!/bin/bash
# This script runs after the container is fully started
# It sets up the databases when they're ready

echo "🔧 Setting up databases in background..."

# Wait for databases and create them in background
(
    echo "⏳ Waiting for PostgreSQL..."
    for i in {1..60}; do
        if pg_isready -h postgres -U postgres > /dev/null 2>&1; then
            echo "🐘 PostgreSQL ready! Creating database..."
            PGPASSWORD=deploy psql -h postgres -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'crypt_keeper_providers'" | grep -q 1 || \
                PGPASSWORD=deploy psql -h postgres -U postgres -c "CREATE DATABASE crypt_keeper_providers;"
            echo "✅ PostgreSQL database ready"
            break
        fi
        sleep 1
    done

    echo "⏳ Waiting for MySQL..."
    for i in {1..60}; do
        if mysqladmin ping -h mysql -u root -pdeploy --silent > /dev/null 2>&1; then
            echo "🐬 MySQL ready! Creating database..."
            mysql -h mysql -u root -pdeploy -e "CREATE DATABASE IF NOT EXISTS crypt_keeper_providers;"
            echo "✅ MySQL database ready"
            break
        fi
        sleep 1
    done
    
    echo ""
    echo "🎉 All databases are ready! You can now run:"
    echo "   bundle exec rspec"
) &

echo "Container is ready! Database setup is running in background..."
