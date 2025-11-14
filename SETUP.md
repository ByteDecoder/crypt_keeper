# Gem Development Setup

## Add .env file

Example of settings:

```.env
CRYPT_KEEPER_KEY=75d942f3d3b3492772e0330f717eaf5e689673ea8b983475ef8f6551f6e99d280cd89972706e46b48240cc01c4d0f7df5ffa3524566b789d147ed04cc4ea4eab
CRYPT_KEEPER_SALT=b16a153e99a5db616a861ea5a6febc64d8a758c4aef3b8c8fc6675ac9daf03f7965f16e8b4b2bdfd28ff65f5203afb8102b8f41c514c3667bb3512015b1e77e8
```

## Datbase setup

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
  database: ':memory:'
```

## Creating Testing Databases

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

Works with Ruby 3.0.4, next:

```bash
bundle install
appraisal install
appraisal rake test
bundle exec appraisal rake test
```

```bash
appraisal activerecord_4_2 rspec spec/
appraisal activerecord_6_1 rspec spec/
```

Fix problem that causes conflict with Rails 7

```
gem.add_runtime_dependency 'activerecord',  '>= 4.2', '< 7.0.0'
gem.add_runtime_dependency 'activesupport', '>= 4.2', '< 7.0.0'
```

## Testiong with a Ruby version + Apprassial Bundle

Ruby 2.5.9 (all tests until rails_6_1 run ok)

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

Ruby 2.6.10 (all tests until rails_6_1 run ok)

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

Ruby 2.7.8 (all tests until rails_6_1 run ok)

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

Ruby 3.0.7 (all tests works from rails_6_0 to rails_6_1, prior 6.0 doesnt work. Seems the api changed)

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

Ruby 3.1.7 (all tests works from rails_6_0 to rails_6_1, prior 6.0 doesnt work. Seems the api changed)

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

Ruby 3.2.9 (WIP)

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

## Apraisal

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