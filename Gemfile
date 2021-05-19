# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.2"

gem "axlsx", git: "https://github.com/randym/axlsx.git", ref: "c8ac844"
gem "axlsx_rails"
gem "bcrypt", "~> 3.1.7"
gem "bootsnap", ">= 1.1.0", require: false
gem "carrierwave"
gem "faker"
gem "fog-aws"
gem "httparty"
gem "jbuilder", "~> 2.5"
gem "letter_opener_web"
gem "mailjet"
gem "nexmo"
gem "pg"
gem "prawn"
gem "prawn-rails"
gem "puma", "~> 4.3"
gem "rails", "~> 5.2.1"
gem "redcarpet"
gem "roo"
gem "roo-xls"
gem "rubycas-client"
gem "rubyzip", ">= 1.2.1"
gem "sass-rails", "~> 5.0"
gem "sentry-raven"
gem "simple_form"
gem "therubyracer"
gem "turbolinks", "~> 5"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "uglifier", ">= 1.3.0"
gem "will_paginate"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "concurrent-ruby"
  gem "fabrication"
  gem "simplecov"
end

group :development do
  gem "awesome_print"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "rubocop", require: false
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "chromedriver-helper"
  gem "poltergeist"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "webmock"
end
