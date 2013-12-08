#!/usr/bin/env ruby

#This script will crawl all available course catalogues (past and present) of the university of paderborn
#and store it into a mongdo db collection
#for each NEW SEMESTER: change the paul_url (L 13) to the semester link at "Vorlesungsverzeichnis",
#also include the last semester in the checks array, L 20).
#don't forget to change the conditions (a month/year pair and a css rule) in the parser.rb!

require 'anemone'
require 'open-uri'  
require 'pp'
require 'mongo'
db_name = "paul"
collection_name = "raw_pages"
paul_url = "https://paul.uni-paderborn.de/scripts/mgrqispi.dll?APPNAME=CampusNet&PRGNAME=ACTION&ARGUMENTS=-AyICXs5BFMOuEGBBQIaX4907mTyTliGVJScN1vUhbYU83tJRnW7ER4ostO-Wynes9yWldZvZeqwtKXIxs4mInpw0Fz9fEWP3QWsanhy7jdoSYtRniIyB26Jrjbef="

#
# This defines when a link should not be followed
#
def delete_link?(link)
  checks = [
    "PRGNAME=EXTERNALPAGES",
    "PRGNAME=CHANGELANGUAGE",
    "-A6grKs5PHq2rFF2cazDrKQT4oecxio0CjK9Y7W9Jd3DdiHke0Qf8QZdI4tyCkNAXXLn5WwUf1J-8nbwl3GO3wniMX-TGs97==", #veranstaltungssuche,
    "-AywyHPFbM6mYuDoLDB5D02MUKWtFic1sKUh1n3x8V8TvCZA2i9oifScLNeSqjlgLBsj9E8DT6zHbdc0JGTNy9rpDK-I7ucgf6RYZWMWygG4FqqBbVJ7EKu6.g1BV=", "AwQ3RgPcAE1ilWQyqTYVi.pw2IS5PTRZryEtxYuNdfaS9c4-gjZTAjLJ7see7ppiNp8kbrAVC18pvNvOuFatCHfhAi-svOVHmvIfV3mweid-9V0n7NVks13ilfXa", #13
    "A9d9HHlEq9mfNWmQzWF-r6P.EmjA9YW8m2IhFxFEyN-9IMkwYVh5cvRQ.M7vAjQFjPr4juhwmXmE3RbXmq6dpYep4w3NDIJOY8A6nUmzKxbPg", "-A6fvR.5BFM1kfBjzhqHtD2xDA4OUg2DY6pPEe0iSJDg4LMztEmFN", #12/13
    "A6qDVVrta9mzOaQzXsFVSthQCqALEl.oZOP90wcXMyqGca-t.TMge9dD5MT2Gw-pQImykoBdF-gookElHzR3THeBLK", "-A9BzcsdVdM17TWofOpYpWsigNVcARx.mxa3x7zqFjowDxXynycu5uUvZB63yANbsov4PzNv9yIK9HbMl", #12
    "-A6p9LPegWwsO-JKSW7jEKieMQNxXICKplf5ClWnJZKPhMTiSHnvvxBtDkqFjw7kd4mGVHve2..QnzXXpzs69P4fJLMvj1mwhvpsV7P8emyt25e0M8cA", "-A9gvmgwRCqcJfHZAsqLZzp4WQi1M2DU2DzC4EGH5pJDvkYlN9LD43CfCJMjfMrGhFEpF4hH49kTT", #11/12
    "AyPaSVJjQ9LVxvz57X2G8cZVxuGlB2K2a1JMmiXbKhdr37cn5RpGvBOeIoYettyQr.BnmW5wPdwJtOYomNz8uvA3KV", "-Aw-8usqLHMTeSX4nKsNICnzAgvmltp.y0MKU-GB", #11
    "A-qU17a179L3w22mI2AIHgklrCtDzuWe0.W09Fe5yANu6ssYQippa4fzyytsys-8f0oSm0Re5lgzqUPEsW-1kdKkqwQUmMpeSmmXpS5enj5ClQix1CV7CXtE", "-A0BSTbpo3MTmpV7EHdjhNwSwN-bEnJ4Zg9itRlvmglN5roQgWa0SU1QCIve8brkIMk7koZnY6okkkc0QGtFPupQhJrXZntMJ7tTZhVQz6udhU43t8MrGZmzpuZuD", #10/11
    "-A-d9LHhEgwAmHG0qWm0jcbf2YpMHMWo4U-3JIlkaPVmGowSCJN-CzMqQFvdThjL6.GWWP.FrV57n0xNLk.7JGDDh.JPtA4bS9sm68", "-A0fvm.zBGqOJv25S-g8JVKaYOILOv8pgbruoTPYG1KCb4Qpg02vQ64clJRwjgAT3TajL8POoegHxc6ABTnDfMcYqRcZA.st7HV8LxQldBdOEG7hdcV9fiu49POcf", #10
    "A6pAAVFEMwKobl5cjvCKML49zC80fW0Rse3q-L7S1Kn0QS9KB19dNDbc5.DNlJ83cBXk369T870PcX.wJlQw3YLT", "aGA4nSmiaBE1.I5YRTcyqkyUyw0xoB5qlOSaUgojVGpazL6ugz0VSH7kFJfAM7Em7oeAXPDIyzFURK3gBVvvLoxnoovrLB88Ocdp0H59Ouygm9", #09/10
    "AyYNV3ltKw3C2S.dJtoaRnoeDNq9xm00lQBe4mswiI-BrqArLjDiZJkGroAgDVN6Fw16h9AC2b.sz0-D65E4JdLS", "-AwNYc25Vjqyr6Iopu73VLG5yqcxO0ofwNuKBqHexDPjgDnwJq1xUx2tJJudq4jpXH-qHVxpMfWW1NB8S9EnpIkpujmu2mmKMieX6rYeAHPmA6pX0bFCNYrbxn5ie", #09
    "CHANGELANGUAGE&ARGUMENTS"
    ]
  checks.any? {|e| link.include? e} 
end

# Mongo setup, those 6000 HTML files may not fit in your memory...
connection = Mongo::Connection.new
db = connection.db(db_name)

# for status updates
$estimate = 6250
$pages = 0
$start_time = Time.now

def time_diff(unit = :seconds)
  dif = Time.now - $start_time
  if unit == :seconds
    dif
  elsif unit == :minutes
    (dif/60).round(1)
  end
end

def new_page_event(interval = 500, first_after = 100)
  $pages += 1
  if $pages % interval == 0 || $pages == first_after
    eta = [0, ($estimate - $pages) / ($pages/time_diff) / 60].max
    puts "avg. speed: #{($pages/time_diff).round(1)} pages/sec - downloaded: #{$pages} pages - elapsed: #{time_diff(:minutes)} min - ETA: #{eta.round(1)} min"
  end
end


# main entry point
Anemone.crawl(paul_url) do |anemone|
  anemone.focus_crawl do |page|
    new_page_event
    page.links.delete_if do |link|
      delete_link? link.to_s
    end 
  end
  anemone.storage = Anemone::Storage.MongoDB(db, collection_name)
end

# finished, print out some stats.
puts "Crawled #{$pages.to_s} html pages in #{time_diff(:minutes)} min... DONE"