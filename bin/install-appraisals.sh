#!/bin/bash
# Install Appraisal gemfiles manually
# This script is useful when 'bundle exec appraisal install' fails due to lockfile issues

set -e

echo "🔧 Installing Appraisal gemfiles manually..."
echo ""

cd gemfiles

for gemfile in *.gemfile; do
  echo "📦 Processing $gemfile..."
  BUNDLE_GEMFILE="$gemfile" bundle lock --update
  BUNDLE_GEMFILE="$gemfile" bundle install
  echo "✅ $gemfile installed successfully"
  echo ""
done

cd ..

echo "🎉 All Appraisal gemfiles installed!"
echo ""
echo "You can now run:"
echo "  bundle exec appraisal list"
echo "  bundle exec appraisal rspec spec/"
echo "  bundle exec appraisal activerecord_7_2 rspec spec/"
echo "  bundle exec appraisal rake"
