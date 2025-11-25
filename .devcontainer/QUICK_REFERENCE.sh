#!/bin/bash
# Quick Reference: Common DevContainer Commands for CryptKeeper Development

echo "🔧 CryptKeeper DevContainer - Quick Reference"
echo "=============================================="
echo ""

cat << 'EOF'
## Database Management

### PostgreSQL
# Check if pgcrypto is installed
PGPASSWORD=deploy psql -h postgres -U postgres -d crypt_keeper_providers -c "\dx"

# Install pgcrypto extension
PGPASSWORD=deploy psql -h postgres -U postgres -d crypt_keeper_providers -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

# Connect to PostgreSQL
PGPASSWORD=deploy psql -h postgres -U postgres -d crypt_keeper_providers

# Run the Mac M1 fix script
./.devcontainer/fix-postgres-mac.sh

### MySQL
# Connect to MySQL
mysql -h mysql -u root -pdeploy crypt_keeper_providers

# Check database
mysql -h mysql -u root -pdeploy -e "SHOW DATABASES;"

## Testing

### RSpec Tests
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/crypt_keeper/provider/postgres_pgp_spec.rb

# Run specific test example
bundle exec rspec spec/crypt_keeper/provider/postgres_pgp_spec.rb -e "reads and writes"

### Appraisal (Multiple Rails Versions)
# Run all appraisals
bundle exec appraisal rspec spec/

# Run specific Rails version
bundle exec appraisal activerecord_7_1 rspec spec/
bundle exec appraisal activerecord_7_2 rspec spec/
bundle exec appraisal activerecord_8_0 rspec spec/
bundle exec appraisal activerecord_8_1 rspec spec/

# Regenerate appraisal gemfiles
bundle exec appraisal generate
bundle exec appraisal install

# Clean appraisal gemfiles
bundle exec appraisal clean

## Development

### Bundle Management
# Install dependencies
bundle install

# Update dependencies
bundle update

# Install appraisals
./bin/install-appraisals.sh

### Container Management
# Rebuild container (from VS Code Command Palette)
# Ctrl+Shift+P / Cmd+Shift+P -> "Dev Containers: Rebuild Container"

# Rebuild without cache
# Ctrl+Shift+P / Cmd+Shift+P -> "Dev Containers: Rebuild Container Without Cache"

## Troubleshooting

### Mac M1 Issues

# PostgreSQL pgcrypto extension not installed:
./.devcontainer/fix-postgres-mac.sh

# Git push/pull SSH errors (Bad configuration option: usekeychain):
./.devcontainer/fix-ssh-mac.sh

# Manual fixes:
# PostgreSQL:
PGPASSWORD=deploy psql -h postgres -U postgres -d crypt_keeper_providers -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

# SSH:
export GIT_SSH_COMMAND='ssh -F /tmp/ssh_config_filtered'

### Check Service Health
# From host machine (outside container):
docker-compose -f .devcontainer/docker-compose.yml ps

# View logs:
docker-compose -f .devcontainer/docker-compose.yml logs postgres
docker-compose -f .devcontainer/docker-compose.yml logs mysql

### Database Connection Test
# Test PostgreSQL
pg_isready -h postgres -U postgres && echo "✅ PostgreSQL OK" || echo "❌ PostgreSQL Failed"

# Test MySQL
mysqladmin ping -h mysql -u root -pdeploy --silent && echo "✅ MySQL OK" || echo "❌ MySQL Failed"

## Coverage

# Run tests with coverage
bundle exec rake spec

# View coverage report
# Open coverage/index.html in browser

## Git Workflow

# Check status
git status

# Create new branch
git checkout -b feature/my-feature

# Commit changes
git add .
git commit -m "Description of changes"

# Push to remote
git push origin feature/my-feature

EOF
