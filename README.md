# Paul-Parser
The Paul-Parser is used by [iUPB](https://github.com/dirkschumacher/iupb) to extract all courses of the University of Paderborn. 
The code is a bit messy, but it works quite allright. Feel free to fork it and make it bit more modular and more maintainable.

## Setup
- Install Ruby 1.9
- Install Mongodb `brew install mongodb`
- Start mongodb and use it under localhost
- Download all courses of the current semester into mongodb `ruby crawler.rb`
- In your mongodb, you will find a collection named `raw_pages` in the database `paul`
- Analyse all courses with `ruby parser.rb`
- Open the collection named `courses` and do what ever you like with the information

## Contribute
Fork our repository, change, test and then make a pull-request. 

## License
This is GPL v3 software.
