# CryptKeeper Development Container

This directory contains the VS Code Dev Container configuration for CryptKeeper development.

## What's Included

### Services

- **Ruby 3.4** development container with all required dependencies
- **PostgreSQL 16** for testing PostgreSQL encryption providers
- **MySQL 8.0** for testing MySQL encryption providers
- **SQLite3** built into the Ruby container

### Pre-installed Tools

- Git, GitHub CLI
- Database clients (psql, mysql, sqlite3)
- Build tools for native gems
- Zsh with Oh My Zsh

### VS Code Extensions

- Ruby LSP
- Database clients for PostgreSQL, MySQL, SQLite
- Git tools (GitLens, GitHub integration)
- Markdown tools
- And many more...

## Getting Started

1. Open this repository in VS Code
2. Click "Reopen in Container" when prompted (or use Command Palette: "Dev Containers: Reopen in Container")
3. Wait for the container to build and start
4. The databases will be automatically created via the postCreateCommand

## Database Configuration

The development databases are pre-configured:

- **PostgreSQL**: `postgres:5432` (user: postgres, pass: deploy)
- **MySQL**: `mysql:3306` (user: root, pass: deploy)
- **SQLite**: In-memory

A sample `database.yml` is provided in `.devcontainer/database.yml`. Copy it to `spec/database.yml` if needed.

## Environment Variables

The following environment variables are set by default:

```bash
CRYPT_KEEPER_KEY=<default-key>
CRYPT_KEEPER_SALT=<default-salt>
DATABASE_HOST=postgres
MYSQL_HOST=mysql
```

You can override these by creating a `.env` file in the project root.

## Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/crypt_keeper/model_spec.rb

# Run with coverage
bundle exec rake spec

# Run tests for specific ActiveRecord version
bundle exec appraisal activerecord-7-2 rspec
```

## Database Management

```bash
# Create test databases
bundle exec rake db:create

# Access PostgreSQL
psql -h postgres -U postgres -d crypt_keeper_providers

# Access MySQL
mysql -h mysql -u root -pdeploy crypt_keeper_providers
```

## Volumes

- **bundle-cache**: Persists installed gems between container rebuilds
- **postgres-data**: Persists PostgreSQL data
- **mysql-data**: Persists MySQL data

## Ports

- **3000**: Application (if running a server)
- **5432**: PostgreSQL (forwarded)
- **3306**: MySQL (forwarded)

## Troubleshooting

### Mac M1: Git Push/Pull SSH Issues

If you're on Mac M1 and getting SSH errors when pushing/pulling from Git:

```text
Bad configuration option: usekeychain
fatal: Could not read from remote repository.
```

**Quick Fix:**

```bash
# Run the SSH fix script
./.devcontainer/fix-ssh-mac.sh
```

**What causes this?**

macOS uses the `UseKeychain` option in SSH config to integrate with the macOS Keychain. This option is not available in Linux (which the container runs), causing SSH to fail.

**How it works:**

The fix script:

1. Filters out `UseKeychain` from your SSH config
2. Creates a Linux-compatible config at `/tmp/ssh_config_filtered`
3. Sets `GIT_SSH_COMMAND` to use the filtered config
4. Adds the setting to your shell profile for persistence

**Manual workaround:**

```bash
export GIT_SSH_COMMAND='ssh -F /tmp/ssh_config_filtered'
```

**For future container rebuilds:**

The devcontainer is now configured to automatically filter the SSH config on startup. After rebuilding, SSH will work without manual intervention.

### Mac M1: pgcrypto Extension Not Installed

If you're on Mac M1 and getting errors like:

```text
PG::UndefinedFunction: ERROR: function pgp_sym_encrypt(...) does not exist
```

**Quick Fix:**

```bash
# Run the fix script
./.devcontainer/fix-postgres-mac.sh
```

**What causes this?**

On Mac M1 (ARM architecture), the PostgreSQL init scripts in `/docker-entrypoint-initdb.d/` sometimes don't execute properly due to timing or volume mounting issues. The `fix-postgres-mac.sh` script:

1. Verifies PostgreSQL connection
2. Ensures the database exists
3. Installs the pgcrypto extension
4. Verifies the extension is working

**Prevention:**

The `docker-compose.yml` now includes `platform: linux/amd64` for PostgreSQL to ensure consistent behavior across architectures. Future container builds should work automatically.

**Manual Fix:**

If you prefer to fix it manually:

```bash
PGPASSWORD=deploy psql -h postgres -U postgres -d crypt_keeper_providers -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
```

### Container won't start

- Check Docker is running
- Try "Dev Containers: Rebuild Container"

Rebuild the container:

- Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
- "Dev Containers: Rebuild Container Without Cache"

### Database connection issues

- Ensure databases are healthy: `docker-compose ps`
- Check logs: `docker-compose logs postgres` or `docker-compose logs mysql`

### Gems not installing

- Rebuild container: "Dev Containers: Rebuild Container"
- Clear bundle cache: `docker-compose down -v` then rebuild
