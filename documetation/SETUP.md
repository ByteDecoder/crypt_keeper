# Gem Development Setup

The CI will now test:

Ruby 2.7 with Rails 5.0-7.1
Ruby 3.0-3.1 with Rails 6.0-7.2
Ruby 3.2-3.3 with Rails 6.0-8.0
Ruby 3.4 with Rails 7.1-8.1

✅ Full devcontainer setup with PostgreSQL & MySQL
✅ CI testing across Ruby 2.7-3.4 and Rails 5.0-8.1
✅ Proper bundler/RubyGems version handling
✅ Logger fix for Rails 6.x compatibility
✅ Conditional Appraisals for Ruby version compatibility
✅ GitHub Actions CI testing all Ruby/Rails combinations
✅ Handy install-appraisals.sh script for quick setup

**Dont forget** to start the devcontainer to get all the stuff properly configured and running. Tested by Windows/WSL2 and MAC ARM MX.

**if you decide not use the devcontainer** you need to create and configure everything manually in you local dev machine. Is stronger recommened that you use the **devcontianer**, so everyone will have the same local working environment.

Starting point, Ruby 3.4, then:

```bash
bundle install
./bin/install-appraisals.sh
bundle exec appraisal rspec spec/
```

If you need to change Ruby version to a new one run:

```bash
bundle install
bundle exec appraisal clean
bundle exec appraisal generate
./bin/install-appraisals.sh
bundle exec appraisal rspec spec/
```

If you have weird warming messages from VSCode, about plugins outside/inside the **devcontainer**, install in your local(outside/inside the devconainter) the next gems:

```bash
gem install ruby-lsp 
```

Don't worry about the previous Ruby and ActiveRecord versions, their Apprasial are generated with the **Github Actions CI**.

## Overview

This gem uses **Appraisal** to test against multiple Rails versions. The `Appraisals` file conditionally defines which Rails versions are available based on your Ruby version:

- **Ruby 3.4+**: Only Rails 7.1, 7.2, 8.0, 8.1 (older versions incompatible)
- **Ruby 3.0-3.3**: Rails 6.0+ (varies by Ruby version)
- **Ruby 2.7**: Rails 5.0-7.1
- **CI**: Tests all compatible Ruby/Rails combinations via GitHub Actions matrix

This approach allows local development with modern Ruby while maintaining support for older Rails versions in CI.

### Why Can't I Generate All Appraisals Locally?

**Important:** You cannot generate Appraisal gemfiles for ActiveRecord versions that are incompatible with your current Ruby version. This is because:

1. **Appraisal uses your current Ruby interpreter** - When you run `bundle exec appraisal generate` or `bundle exec appraisal install`, it attempts to resolve and install gems using your active Ruby version.

2. **ActiveRecord has strict Ruby version requirements** - Each Rails/ActiveRecord version specifies minimum (and sometimes maximum) Ruby versions in their gemspecs. For example:

   - ActiveRecord 5.x requires Ruby < 3.0
   - ActiveRecord 6.0 requires Ruby < 3.4
   - ActiveRecord 7.2+ requires Ruby >= 3.1
   - ActiveRecord 8.0+ requires Ruby >= 3.2

3. **Bundler will fail if versions are incompatible** - If you try to install ActiveRecord 5.2 with Ruby 3.4, Bundler will error out because the gem's metadata explicitly rejects that Ruby version.

### How GitHub Actions CI Solves This

The `.github/workflows/ruby.yml` file uses a **matrix strategy** to test all compatible Ruby/Rails combinations:

```yaml
strategy:
  matrix:
    ruby-version: ["2.7", "3.0", "3.1", "3.2", "3.3", "3.4"]
    rails:
      ["5_0", "5_1", "5_2", "6_0", "6_1", "7_0", "7_1", "7_2", "8_0", "8_1"]
    exclude:
      - ruby-version: "3.4"
        rails: "6_0" # And many other incompatible combinations
```

**How it works:**

1. **Each matrix job runs independently** with its own Ruby version
2. **Appraisals are generated dynamically** in each job using that Ruby version
3. **Only compatible combinations run** - The `exclude` list prevents invalid Ruby/Rails pairings
4. **Each job installs its specific Rails version** and runs the test suite

This means:

- Ruby 2.7 job generates and tests Rails 5.0-7.1 appraisals
- Ruby 3.4 job generates and tests Rails 7.1-8.1 appraisals
- All combinations are tested without requiring you to switch Ruby versions locally

**Local Development Workflow:**

Use your preferred modern Ruby version (e.g., 3.4) for development. You'll only be able to test against compatible Rails versions locally, but CI will ensure comprehensive coverage across all supported combinations when you push your changes.

## Add .env file

You dont need to do this, is already configured in the devcontainer, just mentioned for information purposes.

Example of settings:

```.env
CRYPT_KEEPER_KEY=75d942f3d3b3492772e0330f717eaf5e689673ea8b983475ef8f6551f6e99d280cd89972706e46b48240cc01c4d0f7df5ffa3524566b789d147ed04cc4ea4eab
CRYPT_KEEPER_SALT=b16a153e99a5db616a861ea5a6febc64d8a758c4aef3b8c8fc6675ac9daf03f7965f16e8b4b2bdfd28ff65f5203afb8102b8f41c514c3667bb3512015b1e77e8
```

## Datbase setup

You dont need to do this, is already configured in the devcontainer, just mentioned for information purposes.

create ./spec/database.yml

These are example settings if you are running psql and mysql in a docker container:

```yml
postgres:
  adapter: postgresql
  encoding: utf8
  reconnect: false
  database: crypt_keeper_providers
  pool: 5
  username: postgres
  password: deploy
  min_messages: WARNING
mysql:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: crypt_keeper_providers
  pool: 5
  username: root
  password: deploy
  host: 127.0.0.1 # <--- Change from localhost to 127.0.0.1
  port: 3306
sqlite:
  adapter: sqlite3
  encoding: utf8
  reconnect: false
  database: ":memory:"
```

## Creating Testing Databases

You dont need to do this, is already configured in the devcontainer, just mentioned for information purposes.

Enter into the shell of each container and do the next:

psql

```bash
psql -c 'CREATE DATABASE crypt_keeper_providers;' -U postgres
psql crypt_keeper_providers -c 'CREATE EXTENSION IF NOT EXISTS pgcrypto;' -U postgres
```

mysql: will prompt your password

```bash
mysql -e 'CREATE DATABASE crypt_keeper_providers' -p
```

## Testing with a previous Ruby version + Apprassial Bundle

You dont need to do this, is already configured in the devcontainer, just mentioned for information purposes.

In order to test with older Ruby versions, you need to install them with **rbenv**. Check each bulk of commands per Ruby versions. Locally is not needed since the CI is in charge or running all these conbinations by installing the proper version of ruby and ActiveRecord for testing all these version combinations where are supported.

### Ruby 2.5.9 (all tests until rails_6_1 run ok)

```bash
rm Gemfile.lock
rbenv install 2.5.9
rbenv local 2.5.9
gem update --system 3.2.3
gem install bundler -v 2.3.27
bundle install
bundle exec appraisal clean
bundle exec appraisal generate
bundle exec appraisal install
bundle exec appraisal activerecord_4_2 rspec spec/
bundle exec appraisal rspec spec/
```

### Ruby 2.6.10 (all tests until rails_6_1 run ok)

```bash
rm Gemfile.lock
rbenv install 2.6.10
rbenv local 2.6.10
gem update --system 3.2.3
gem install bundler -v 2.4.22
bundle install
bundle exec appraisal clean
bundle exec appraisal generate
bundle exec appraisal install
bundle exec appraisal activerecord_4_2 rspec spec/
bundle exec appraisal rspec spec/
```

### Ruby 2.7.8 (Rails 4.2, 5.0, 5.1, 5.2, 6.0, 6.1, 7.0, 7.1)

```bash
rm Gemfile.lock
rbenv install 2.7.8
rbenv local 2.7.8
gem update --system 3.2.3
gem install bundler -v 2.4.22
bundle install
bundle exec appraisal clean
bundle exec appraisal generate
bundle exec appraisal install
bundle exec appraisal activerecord_4_2 rspec spec/
bundle exec appraisal rspec spec/
```

### Ruby 3.0.7 (Rails 4.2, 6.0, 6.1, 7.0, 7.1)

Not working with Rails 5, need to check why. (Apparently Rails 5 does not work with Ruby 3)

```bash
rm Gemfile.lock
rbenv install 3.0.7
rbenv local 3.0.7
bundle install
bundle exec appraisal clean
bundle exec appraisal generate
bundle exec appraisal install
bundle exec appraisal activerecord_4_2 rspec spec/
bundle exec appraisal rspec spec/
```

### Ruby 3.1.7 (Rails 4.2, 6.0, 6.1, 7.0, 7.1, 7.2)

(Rails 5 does not work with Ruby 3)

```bash
rm Gemfile.lock
rbenv install 3.1.7
rbenv local 3.1.7
bundle install
bundle exec appraisal clean
bundle exec appraisal generate
bundle exec appraisal install
bundle exec appraisal activerecord_6_0 rspec spec/
bundle exec appraisal activerecord_6_1 rspec spec/
bundle exec appraisal rspec spec/
```

### Ruby 3.2.9 (Rails 6.0, 6.1, 7.0, 7.1, 7.2, 8.0, 8.1)

```bash
rm Gemfile.lock
rbenv install 3.2.9
rbenv local 3.2.9
bundle install
bundle exec appraisal clean
bundle exec appraisal generate
bundle exec appraisal install
bundle exec appraisal activerecord_6_0 rspec spec/
bundle exec appraisal activerecord_6_1 rspec spec/
bundle exec appraisal rspec spec/
```

### Ruby 3.3.10 (Rails 6.0, 6.1, 7.0, 7.1, 7.2, 8.0, 8.1)

```bash
rm Gemfile.lock
rbenv install 3.3.10
rbenv local 3.3.10
bundle install
bundle exec appraisal clean
bundle exec appraisal generate
bundle exec appraisal install
bundle exec appraisal activerecord_6_0 rspec spec/
bundle exec appraisal activerecord_6_1 rspec spec/
bundle exec appraisal rspec spec/
```

### Ruby 3.4.7 (Rails 7.1, 7.2, 8.0, 8.1)

**Note:** Ruby 3.4 only supports Rails 7.1+. The Appraisals file conditionally excludes older Rails versions for Ruby 3.4+. Older Rails versions are tested in CI with appropriate Ruby versions.

```bash
rm Gemfile.lock
rbenv install 3.4.7
rbenv local 3.4.7
bundle install
bundle exec appraisal clean
bundle exec appraisal generate
bundle exec appraisal install
# Available appraisals for Ruby 3.4: activerecord_7_1, activerecord_7_2, activerecord_8_0, activerecord_8_1
bundle exec appraisal activerecord_7_2 rspec spec/
bundle exec appraisal rspec spec/
```

**Troubleshooting Appraisal Install Issues:**

If `bundle exec appraisal install` fails with "No such file or directory @ rb_sysopen - gemfile.lock", the lock files weren't created properly. Fix by manually generating them:

```bash
cd gemfiles
for gemfile in *.gemfile; do
  BUNDLE_GEMFILE="$gemfile" bundle lock --update
  BUNDLE_GEMFILE="$gemfile" bundle install
done
cd ..
```

Then `bundle exec appraisal install` should work correctly.

What is running Apprasial behind the scenes. In case of problems you can run it manually per gemset

```bash
bundle check --gemfile='/home/bytedecoder24/workspace/crypt_keeper_byte_repo/gemfiles/activerecord_7_0.gemfile' || bundle install --gemfile='/home/bytedecoder24/workspace/crypt_keeper_byte_repo/gemfiles/activerecord_7_0.gemfile
```

## Apraisal

Youd dont need to do this, is alredy setup in the devcontainer, just mentioned for information porpuses.

The Appraisal gem is used by Rails gem developers
to test their library against multiple versions of dependencies, most commonly different versions of Rails. It works by generating separate Gemfile files for each test scenario, allowing developers to ensure their gem remains compatible with a wide range of framework versions. This automates testing and helps prevent regressions as dependencies evolve, which is particularly useful for gems that provide plugin-like functionality for a framework.
How it works

- Appraisals file: You create a file named "Appraisals" (note the capitalization) in your project's root directory.
- Define scenarios: Inside this file, you define different "appraisals," which are essentially test scenarios. For example, you can define one for each major version of Rails you want to support.
- Generate Gemfiles: The appraisal command reads your Appraisals file and your main Gemfile to generate new Gemfile files in a gemfiles subdirectory, one for each appraisal.
- Run tests: When you run a command like appraisal rake test, Appraisal uses the correct Gemfile to install the dependencies for that specific appraisal and then runs the command (e.g., rake test).

```ruby
# Appraisals
appraise "rails-4" do
  gem "rails", "4.2.0"
end

appraise "rails-5" do
  gem "rails", "~> 5.0.0"
end
```

In this example, running appraisal rake test would first run your tests with rails-4.2.0 and then run them again with a 5.x version of Rails, ensuring compatibility across both versions.

To run RSpec with Appraisal for gem development, follow these steps:

Install Appraisal: Add the appraisal gem to your gem's Gemfile (typically in the development group) and run bundle install.

```ruby
# Gemfile
group :development do
  gem 'appraisal'
end
```

Define Appraisals: Create an Appraisals file in your gem's root directory (e.g., Appraisals) to define different dependency sets you want to test against.

```ruby
# Appraisals
appraise 'rails_6_1' do
  gem 'rails', '~> 6.1.0'
end

appraise 'rails_7_0' do
  gem 'rails', '~> 7.0.0'
end
```

Generate Gemfiles: Run appraisal generate to create individual Gemfile and Gemfile.lock files for each appraisal in a gemfiles directory.

```bash
appraisal generate
appraisal generate --travis
```

Install Dependencies for Appraisals: Run appraisal install to resolve and install the dependencies for all generated Gemfiles.

```bash
appraisal install
```

Run RSpec with Appraisal: Use the appraisal command to prefix your rspec command. This will execute RSpec using the specific Gemfile and dependencies defined for that appraisal.

```bash
appraisal rails_6_1 rspec spec/
appraisal rails_7_0 rspec spec/
```

You can also run all appraisals sequentially:

```bash
appraisal rake rspec # if you have a Rake task for running specs
```

Or, to run a specific RSpec file with a particular appraisal:

```bash
appraisal rails_6_1 rspec spec/models/my_model_spec.rb
```

This setup allows you to ensure your gem works correctly across different versions of its dependencies, which is crucial for maintaining compatibility and reliability in gem development.
