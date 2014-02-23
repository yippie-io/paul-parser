# Paul-Parser
The Paul-Parser is used by [iUPB](https://github.com/yippie-io/iUPB) to extract all courses of the University of Paderborn. 
The code is a bit messy, but it works quite allright. Feel free to fork it and make it bit more modular and more maintainable.

## API
If you are only interested in the course data, checkout our course API at [dev.yippie.io](http://dev.yippie.io/apis.courses.html)

## Setup
- Install Ruby 1.9+ (tested with 1.9 and 2.1)
- Install MongoDB `brew install mongodb` (on linux, use the 10gen-packages, just google for it.)
- Start `mongodb` at _localhost_
- Install dependencies with `bundle install`
- Download all courses of the current semester into mongodb with `bundle exec ruby crawler.rb`
- In your mongodb, you will find a collection named _raw_pages_ in the database _paul_
- Analyse all courses with `bundle exec ruby parser.rb`
- Open the collection named _courses_ and do what ever you like with the information
- to export the found data, simply run `mongoexport --db paul --collection courses > courses.json`

## Contribute
Fork our repository, change, test and then make a pull-request. :-) Thanks!

