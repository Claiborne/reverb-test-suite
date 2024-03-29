Reverb Functional and Acceptance Test Suite
=================

This framework will be the entry point for writing and running high-level test automation (regression, integration, acceptance) for frontend and backend applications

## REQUIRED SOFTWARE
Below are the required software and gems you need to install to run this framework. (Note: This framework has not yet been set up for iOS UI test automation; more about that to come shortly)

### Ruby
All tests are developed in Ruby (versions 2.0.0-p247 through 2.1.1 are supported). Highly recommended using RVM to install Ruby and manage Gemsets http://www.rvm.io/

### Ruby Gems
- rspec version 2.14.0 (the test framework all tests are developed in https://www.relishapp.com/rspec)
- json_pure (a json parser, mainly used to parse APIs)
- nokogiri (an HTML parser, maoinly used to parse webpages that don't require javascript testing)
- rake (used to run tests)
- rest-client (an HTTP client)
- selenium-webdriver (browser automation tool http://docs.seleniumhq.org/projects/webdriver/)
- colorize (easy way to make console output colorful, e.g.: "hello world".green)
- bunny (for RabbitMQ)

### Git
How to set up Github on a Mac - http://help.github.com/mac-set-up-git/

## FRAMEWORK 

All tests are written using the Rspec2 framework - https://www.relishapp.com/rspec

The current folder structure:

- The 'config' folder contains a list of all known DNS entires for all apps.
- The 'spec' folder is a repository for all tests.
- The 'lib' folder contains all helper classes required by tests.

To run all tests suites:

    rake all [OPTIONS] [TAGS] 
(options and tags explained below)

To run all bifrost tests:

    rake bifrost [OPTIONS] [TAGS]

### What are [OPTIONS]?

To run tests for each application, you need to pass more than "rake [APPLICATION]". You also have to pass options. All tests require an 'env' variable to determine which environment to run against. E.g.:

    rake some-feature env=prd # environments are defined in the .yml files under the config dir

### What are [TAGS]?

Tags are used to label tests. You can then run tests with only certain labels or run tests excluding certain labels.

- For smoke/basic assertions, use the tag 'smoke'
- For assertions that spam the site or take a long time to run (for example, checking all the links on the page), use the tag 'spam'
- For assertions only valid in a staging environment, use the tag 'stg'
- For assertion only valid in the production environment, use the tag 'prd'

Here's an example of using an RSpec tag in your spec file:

      it "should have at least one link", :smoke => true do
          check_have_a_link('div#right-col-outnow-tabs')
      end
