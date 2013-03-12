# Paul-Parser
The Paul-Parser is used by [iUPB](https://github.com/yippie-io/iUPB) to extract all courses of the University of Paderborn. 
The code is a bit messy, but it works quite allright. Feel free to fork it and make it bit more modular and more maintainable.

## Setup
- Install Ruby 1.9
- Install Mongodb `brew install mongodb`
- Start `mongodb` under _localhost_
- Install dependencies with `bundle install`
- Download all courses of the current semester into mongodb with `bundle exec ruby crawler.rb`
- In your mongodb, you will find a collection named _raw_pages_ in the database _paul_
- Analyse all courses with `bundle exec ruby parser.rb`
- Open the collection named _courses_ and do what ever you like with the information

## Contribute
Fork our repository, change, test and then make a pull-request. 

## License
This is GPL v3 software.
