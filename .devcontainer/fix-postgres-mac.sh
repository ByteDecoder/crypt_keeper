#!/bin/bash
# Fix PostgreSQL pgcrypto extension for Mac M1
# Run this script if you get "function pgp_sym_encrypt does not exist" errors

echo "🔧 PostgreSQL pgcrypto Extension Fix for Mac M1"
echo "================================================"
echo ""

# Check if postgres is accessible
echo "1️⃣  Checking PostgreSQL connection..."
if ! pg_isready -h postgres -U postgres > /dev/null 2>&1; then
    echo "❌ PostgreSQL is not accessible"
    echo "   Make sure your devcontainer is running"
    exit 1
fi
echo "✅ PostgreSQL is accessible"
echo ""

# Check if database exists
echo "2️⃣  Checking if database exists..."
DB_EXISTS=$(PGPASSWORD=deploy psql -h postgres -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'crypt_keeper_providers'" | tr -d '[:space:]')
if [ "$DB_EXISTS" != "1" ]; then
    echo "⚠️  Database doesn't exist, creating it..."
    PGPASSWORD=deploy psql -h postgres -U postgres -c "CREATE DATABASE crypt_keeper_providers;"
else
    echo "✅ Database exists"
fi
echo ""

# Check if pgcrypto extension is installed
echo "3️⃣  Checking pgcrypto extension..."
EXTENSION_EXISTS=$(PGPASSWORD=deploy psql -h postgres -U postgres -d crypt_keeper_providers -tc "SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto'" | tr -d '[:space:]')
if [ "$EXTENSION_EXISTS" != "1" ]; then
    echo "⚠️  pgcrypto extension not installed, installing it now..."
    PGPASSWORD=deploy psql -h postgres -U postgres -d crypt_keeper_providers -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
    echo "✅ pgcrypto extension installed"
else
    echo "✅ pgcrypto extension already installed"
fi
echo ""

# Verify pgcrypto functions are available
echo "4️⃣  Verifying pgcrypto functions..."
FUNCTION_CHECK=$(PGPASSWORD=deploy psql -h postgres -U postgres -d crypt_keeper_providers -tc "SELECT COUNT(*) FROM pg_proc WHERE proname LIKE 'pgp_%'" | tr -d '[:space:]')
if [ "$FUNCTION_CHECK" -gt "0" ]; then
    echo "✅ pgcrypto functions are available (found $FUNCTION_CHECK functions)"
else
    echo "❌ pgcrypto functions not found"
    exit 1
fi
echo ""

# Show all installed extensions
echo "5️⃣  Installed extensions:"
PGPASSWORD=deploy psql -h postgres -U postgres -d crypt_keeper_providers -c "\dx"
echo ""

echo "🎉 PostgreSQL is properly configured!"
echo ""
echo "You can now run your tests:"
echo "  bundle exec rspec"
echo "  bundle exec appraisal rspec spec/"
