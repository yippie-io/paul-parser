#!/usr/bin/env ruby

#This script will crawl all available course catalogues (past and present) of the university of paderborn
#and store it into a mongdo db collection

require 'anemone'
require 'open-uri'  
require 'pp'
require 'mongo'
db_name = "paul"
collection_name = "raw_pages"
paul_url = "https://paul.uni-paderborn.de/scripts/mgrqispi.dll?APPNAME=CampusNet&PRGNAME=ACTION&ARGUMENTS=-Aw5KEVlEq9AI9PUtudv8Dp9SiLoyreputWWrynNtpZf1GG6Zio5FxXkSisE7Y7RUb-SG2lj0gpXUy8U-poDO6TfXh7PGPBiFDGXiJ7-G-9dthW98oX4g.70shKzN="

#
# This defines when a link should not be followed
#
def delete_link?(link)
  checks = [
    "PRGNAME=EXTERNALPAGES",
    "PRGNAME=CHANGELANGUAGE",
    "A9pGAVlhQw48lvvGg7gsekxlk5KDm2nYnO2JO3.25h069-2tXnZav-G-zUZzr", #veranstaltungssuche,
    "-AywyHPFbM6mYuDoLDB5D02MUKWtFic1sKUh1n3x8V8TvCZA2i9oifScLNeSqjlgLBsj9E8DT6zHbdc0JGTNy9rpDK-I7ucgf6RYZWMWygG4FqqBbVJ7EKu6.g1BV=", #13
    "A9d9HHlEq9mfNWmQzWF-r6P.EmjA9YW8m2IhFxFEyN-9IMkwYVh5cvRQ.M7vAjQFjPr4juhwmXmE3RbXmq6dpYep4w3NDIJOY8A6nUmzKxbPg", #12/13
    "A6qDVVrta9mzOaQzXsFVSthQCqALEl.oZOP90wcXMyqGca-t.TMge9dD5MT2Gw-pQImykoBdF-gookElHzR3THeBLK", #12
    "-A6p9LPegWwsO-JKSW7jEKieMQNxXICKplf5ClWnJZKPhMTiSHnvvxBtDkqFjw7kd4mGVHve2..QnzXXpzs69P4fJLMvj1mwhvpsV7P8emyt25e0M8cA", #11/12
    "AyPaSVJjQ9LVxvz57X2G8cZVxuGlB2K2a1JMmiXbKhdr37cn5RpGvBOeIoYettyQr.BnmW5wPdwJtOYomNz8uvA3KV", #11
    "A-qU17a179L3w22mI2AIHgklrCtDzuWe0.W09Fe5yANu6ssYQippa4fzyytsys-8f0oSm0Re5lgzqUPEsW-1kdKkqwQUmMpeSmmXpS5enj5ClQix1CV7CXtE", #10/11
    "-A-d9LHhEgwAmHG0qWm0jcbf2YpMHMWo4U-3JIlkaPVmGowSCJN-CzMqQFvdThjL6.GWWP.FrV57n0xNLk.7JGDDh.JPtA4bS9sm68", #10
    "A6pAAVFEMwKobl5cjvCKML49zC80fW0Rse3q-L7S1Kn0QS9KB19dNDbc5.DNlJ83cBXk369T870PcX.wJlQw3YLT", #09/10
    "AyYNV3ltKw3C2S.dJtoaRnoeDNq9xm00lQBe4mswiI-BrqArLjDiZJkGroAgDVN6Fw16h9AC2b.sz0-D65E4JdLS", #09
    "CHANGELANGUAGE&ARGUMENTS"
    ]
  checks.any? {|e| link.include? e} 
end
connection = Mongo::Connection.new
db = connection.db(db_name)
pages = 0
Anemone.crawl(paul_url) do |anemone|
  anemone.focus_crawl do |page|
    pages += 1
    page.links.delete_if do |link|
      delete_link? link.to_s
    end 
  end
  anemone.storage = Anemone::Storage.MongoDB(db, collection_name)
end

puts "Crawled #{pages.to_s} html pages... DONE"