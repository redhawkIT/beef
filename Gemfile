# BeEF's Gemfile

#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# Gems only required on Windows, or with specific Windows issues
if RUBY_PLATFORM.downcase.include?("mswin") || RUBY_PLATFORM.downcase.include?("mingw")
  gem "win32console"
  gem "eventmachine", "1.0.0.beta.4.1"
else
  gem "eventmachine", "0.12.10"
end

gem "thin"
gem "sinatra", "1.3.2"
gem "ansi"
gem "term-ansicolor", :require => "term/ansicolor"
gem "dm-core"
gem "json"
gem "data_objects"
gem "dm-sqlite-adapter"
gem "parseconfig"
gem "erubis"
gem "dm-migrations"
gem "msfrpc-client"

if ENV['BEEF_TEST']
# for running unit tests
  gem "test-unit"
  gem "test-unit-full"
  gem "curb"
  gem "test-unit"
  gem "selenium"
  gem "selenium-webdriver"
  # nokogirl is needed by capybara which may require one of the below commands
  # sudo apt-get install libxslt-dev libxml2-dev
  # sudo port install libxml2 libxslt
  gem "capybara"
end

source "http://rubygems.org"
