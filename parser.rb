#!/usr/bin/env ruby

require 'mongoid'
require 'nokogiri'
require 'pp'
require 'mongo'

Mongoid.load!("mongoid.yml", :development)

class Course 
  include Mongoid::Document
  field :title, type: String
  field :title_downcase, type: String
  field :paul_id, type: String
  field :internal_course_id, type: String
  field :course_data, type: Array
  field :course_type, type: String
  field :paul_url, type: String
  field :group_title, type: String
  field :meta_lecturer_names, type: String
  field :meta_rooms, type: String
  field :sws, type: Integer
  field :description, type: String
#  field :_id, type: String, default: ->{ internal_course_id }
  field :parse_revision, type: Integer
  index({title_downcase: 1})
  index({meta_lecturer_names: 1})
  index({meta_rooms: 1})
end

def clear(value)
  if value and value.is_a? String
    value.strip.force_encoding("ISO-8859-1").encode("UTF-8")
  else
    value
  end
end

def parse(body, url)
  
  date_mapping = {
    'Jan' => '01',
    'Feb' => '02',
    'Mae' => '03',
    'Apr' => '04',
    'Mai' => '05',
    'Jun' => '06',
    'Jul' => '07',
    'Aug' => '08',
    'Sep' => '09',
    'Okt' => '10',
    'Nov' => '11',
    'Dez' => '12'
  }
  
  date_check = 'Apr. 2014'
  semester_check = '#pageTopNavi ul.nav.depth_2 #link000578 a.link000578 span{'
  
  if body and body.include? "Veranstaltungsdetails" and (body.include?(date_check) or body.include?(semester_check))
    doc = Nokogiri::HTML(body)
    html_title = doc.css('form[name=courseform] h1')
    unless html_title
      return
    end
    
    kleingruppe = body.include? "Kleingruppe:"
    inner_title = clear(html_title.first.inner_html)
    title = ''
    course_id = nil
    inner_title.each_line do |line|
      unless course_id
        course_id = line.strip
      else
        title = line.strip
      end
    end
       
    html_internal_course_id = doc.css('table[class=tb]')
    internal_course_id = nil
    html_internal_course_id.each do |table|
      if table.attribute('courseid')
        internal_course_id = clear(table.attribute('courseid').value)
        break
      end
    end
    unless internal_course_id
      internal_course_id = course_id
      return unless internal_course_id
    end
    
    if kleingruppe
      kleingruppe_title = clear(doc.css('form[name=courseform] h2').first.inner_html.strip)
      kleingruppe_title = kleingruppe_title.split(':').last.strip.gsub(Nokogiri::HTML("&nbsp;").text, '')
      #puts kleingruppe_title
    else
      kleingruppe_title = ''
    end

    course_short_desc = doc.css('input[name=shortdescription]').first['value']

    # supress names like K.072.21003
    course_short_desc = "" if course_short_desc.length > 0 && course_short_desc =~ /\AK.\d.*/i
    
    # get SWS (Semesterwochenstunden)
    begin
      sws = doc.css('input[name=sws]').first['value']
    end
    
    # get "Inhalt" / Description
    description = nil
    begin
      description_node = doc.css('td.tbdata p').last
      description = description_node.inner_html if description_node.inner_html.match(/inhalt/i) || description_node.inner_html.match(/kommentartext/i)
    end
    
    course_data = []
    instructors = []
    rooms = []
    doc.css('table.tb').each do |table|
      unless table.css('caption').first and table.css('caption').first.inner_html == 'Termine'
        next
      end
      table.css('tr').each do |tr|
        unless tr.css('td.tbdata').first
          next
        end
        unless tr.css('td[name=appointmentDate]').first
          next
        end
        date_string = clear(tr.css('td[name=appointmentDate]').first.inner_html)
        date_part = date_string.split(',').last.strip
        date_split = date_part.delete('.').split(' ')
        unless date_mapping[date_split[1]]
          next
        end
        date_string = date_split.first + '.' + date_mapping[date_split[1]] + '.' + date_split.last
        if date_string.end_with?('*')
          next
        end
        date_string.delete('*')
        date = Time::strptime(date_string, "%e.%m.%Y")
        date = Time.utc(date.year, date.month, date.day, 12,0,0)
        time_from = Time::strptime(clear(tr.css('td[name=appointmentTimeFrom]').first.inner_html), "%H:%M")
        time_to = Time::strptime(clear(tr.css('td[name=appointmentDateTo]').first.inner_html), "%H:%M")
        if tr.css('a[name=appointmentRooms]').first
          room_element = tr.css('a[name=appointmentRooms]').first
        elsif tr.css('span[name=appointmentRooms]').first
          room_element = tr.css('span[name=appointmentRooms]').first
        end
        if room_element
          room = clear(room_element.inner_html)
        else
          room = ""
        end
        instructor = clear(tr.css('td[name=appointmentInstructors]').first.inner_html)
        instructors << instructor if instructor != "" and not instructors.include? instructor
        rooms << room if rooms != "" and not rooms.include? room
        course_data << {
          date: date,
          time_from: time_from,
          time_to: time_to,
          room: room,
          instructor: instructor
        }
      end
    end 

    begin
      Course.create!(
      title: title,
      title_downcase: kleingruppe ? kleingruppe_title.downcase : title.downcase,
      course_data: course_data,
      paul_id: course_id,
      internal_course_id: internal_course_id,
      course_short_desc: course_short_desc,
      course_short_desc_downcase: course_short_desc.downcase,
      paul_url: url,
      course_type: kleingruppe ? 'group' : 'course',
      group_title: kleingruppe_title,
      meta_lecturer_names: instructors.join(",").downcase,
      meta_rooms: rooms.join(",").downcase,
      sws: sws.to_i,
      description: description,
      parse_revision: 2     ### SET!
      )
    rescue
      puts "!!! FAILed to create document: #{title} (#{url})"
    end

  else
    #print "x"
    #puts "--------------------------\nskipped, veranstalungsdetails: #{body.include? "Veranstaltungsdetails"}, date_check: #{body.include? date_check}, sem_check: #{body.include? semester_check}"
  end
  
end
  

db = Mongo::Connection.new.db("paul")

collection = db['raw_pages']

Course.delete_all

counter = 0
skipped = 0
collection.find.each do |page| 
  counter += 1
  bin_body = page['body']
  unless bin_body
    skipped += 1
  else
    body = bin_body.unpack("C*").pack("C*").force_encoding('ISO-8859-1')
    parse body, page['url']
  end
  puts "[#{counter}/#{collection.count}] (#{counter*100/collection.count}%)" if (counter % 200) === 0
end

puts "Course documents: #{Course.count}, skipped parsing of #{skipped} empty pages."