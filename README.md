Reverb Test Suite
=================

In order to consolidate various test scripts, this "unified framework" will be the main entry point for all automated tests and scripts. 

## REQUIRED SOFTWARE
Below are the required software and gems you need to install to run this framework.

### Ruby
All tests are developed in Ruby (version 2.0.0-p247). Highly recommended using RVM to install and set-up Ruby http://www.rvm.io/

### Ruby Gems
rspec (the test framework all tests are developed in https://www.relishapp.com/rspec)

json_pure (a json parser, mainly used to parse APIs)

nokogiri (an HTML parser, maoinly used to parse IGN webpages that don't require javascript testing)

rake (used to run tests)

rest-client (an HTTP client)

selenium-webdriver (browser automation tool http://docs.seleniumhq.org/projects/webdriver/)

colorize (easy way to make console output colorful, e.g.: "hello world".green)

### Git
How to set up GIT on a Mac - http://help.github.com/mac-set-up-git/

## FRAMEWORK 

All tests will be written using the Rspec2 framework - https://www.relishapp.com/rspec

The current folder structure:

The 'config' folder contains a list of all known DNS entires for all apps.

The 'spec' folder is a repository for all tests.

The 'lib' folder contains all helper classes required by tests.

The 'scripts' folder contains one-off scripts used for improptu needs.

To run all tests suites:

   rake all [OPTIONS] [TAGS] options and tags explained below

To run all bifrost tests:

   rake bifrost [OPTIONS] [TAGS]

### What are [OPTIONS]?

To run tests for each application, you need to pass more than "rake [APPLICATION]". You also have to pass options. All tests require an 'env' variable to determine which environment to run against. E.g.:

	rake some-feature env=prd # environments are defined in the .yml files under the config dir

### What are [TAGS]?

Tags are used to label tests. You can then run tests with only certain labels or run tests excluding certain labels.

For smoke/basic assertions, use the tag 'smoke'

For assertions that spam the site or take a long time to run (for example, checking all the links on the page), use the tag 'spam'

For assertions only valid in a staging environment, use the tag 'stg'

For assertion only valid in the production environment, use the tag 'prd'

Here's an example of using an RSpec tag in your spec file:

      it "should have at least one link", :smoke => true do
          check_have_a_link('div#right-col-outnow-tabs')
      end
      
