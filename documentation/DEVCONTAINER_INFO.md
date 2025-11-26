# DevContainer Info

VS Code Dev Containers provide a consistent, containerized environment for development, which streamlines the setup process and ensures everyone on a team is working with the exact same tools and configurations. This approach can feel like incorporating "DevOps tools and knowledge" into the development phase because it applies core DevOps principles like **consistency, immutability, and infrastructure as code** directly to the developer's local workspace.

Here's how they align with DevOps principles:

- **Consistency Across Environments**: A fundamental goal of DevOps is to eliminate the "it works on my machine" problem. Dev containers ensure the development environment perfectly mirrors the staging and production environments, as they can use the same Docker images and configuration files.
- **Infrastructure as Code**: The configuration of the development environment (operating system, installed software, extensions, dependencies) is defined in configuration files (like devcontainer.json and Dockerfiles) and is version-controlled [1, 2]. This means the environment itself is code, which can be shared, reviewed, and automated.
- **Rapid Onboarding**: New team members can start contributing almost immediately. Instead of spending hours or days installing dependencies, they simply clone the repository, open it in a container, and the pre-configured environment is ready to go, demonstrating a "shift-left" of operational readiness.
- **Isolation and Immutability**: The development environment is isolated from the host machine, preventing conflicts with local system configurations. If something goes wrong, the container can be quickly rebuilt from the original configuration, ensuring immutability.

In essence, while they don't replace the full spectrum of DevOps tools and practices (like CI/CD pipelines, monitoring, or deployment strategies), Dev Containers are a powerful tool that brings DevOps principles right to the developer's desktop, improving efficiency and reducing discrepancies between environments. You can learn more about this approach by reviewing the official VS Code documentation.

## Key Components

- Base Image: Ruby 3.4-slim (latest recommended version)
- System Dependencies:
  - Build tools for compiling native gems
  - PostgreSQL, MySQL, and SQLite clients and development libraries
  - Common development utilities (git, vim, curl, etc.)
- Ruby Environment:
  - Latest Bundler and Rake
  - Proper gem path configuration
  - No-document gem installation for faster builds
- Security & Best Practices:
  - Non-root user (developer) for running the application
  - Proper file permissions
  - Health check to ensure Ruby is working
  - Multi-stage copy for better caching
  Database Support:
- PostgreSQL client and dev libraries
  - MySQL client and dev libraries
  - SQLite3 support
  - All required for the CryptKeeper test suite
- Development Features:
- Working directory set to /workspace
- Bundle path properly configured
- Gemfile copying optimized for Docker layer caching

This Dockerfile is specifically tailored for the CryptKeeper gem development environment, supporting all the databases and tools mentioned in your project's setup documentation. You can build and run it with:

```bash
docker build -t crypt-keeper-dev .
docker run -it -v $(pwd):/workspace crypt-keeper-dev
```

The container will start with a bash shell as the developer user in the /workspace directory, ready for development and testing.

Executing from terminal

```bash
docker exec -it 2bafc71281fb9d4f4d2f118a667557948b3dfdab5963dbc3bbc6ef6ed7c03c59 bash
```
