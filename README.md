## README
## LogFileParser App.

This is Rails 5 LogFileParser app.
Consist of two parts:

* Command line tool to parse and store data in sqlite db.
> run ./lib/log_file_parser file_path ('./lib/votes.txt')

  file_path by default is 'lib/votes.txt'.

  Will parse DEFAULT_FILE ('lib/votes.txt') if the file_path is not provided.

* Second part is basic web front-end to view the results.

  > run rails s

  > type in the browser http://localhost:3000/

  Click any campaign link to see output.
  Will list all users with its scores for selected campaign.

* Ruby version

  ruby-2.3.4

* System dependencies

  Rails 5

* Configuration

* Database creation

  >rake db:create

  >rake db:migrate

* Populate db with Users and Campaigns

  >./lib/log_file_parser file_path

* How to run the test suite

  >rspec
