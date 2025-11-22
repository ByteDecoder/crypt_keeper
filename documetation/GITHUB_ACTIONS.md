# Github Actions

Changes made:

- Added step to generate Appraisal gemfiles - Each matrix job now runs bundle exec appraisal generate to create the gemfiles for that specific Ruby version
- Added step to install dependencies for the specific Rails version - Runs bundle exec appraisal activerecord_${{ matrix.rails }} bundle install to install gems for that specific Rails version
- Updated test command - Changed from bundle exec rake to bundle exec appraisal activerecord_${{ matrix.rails }} rake to run tests with the correct gemfile

How it works now:

- Each matrix combination (e.g., Ruby 2.7 + Rails 6.0, Ruby 3.3 + Rails 7.2) will:
  - Install the base gems (via bundler-cache)
  - Generate all Appraisal gemfiles (only the compatible ones will work)
  - Install dependencies specifically for that Rails version
  - Run tests using that specific gemfile
  
This way, Rails 6.x will be tested with Ruby 2.7-3.3 (as per your exclusions), and you don't need to manually generate Appraisal gemfiles locally for incompatible Ruby/Rails combinations.

The workflow will handle everything automatically in CI! 🎉
