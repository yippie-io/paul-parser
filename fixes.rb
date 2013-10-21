require "mongoid"

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
  field :_id, type: String, default: ->{ internal_course_id }
  index({title_downcase: 1})
  index({meta_lecturer_names: 1})
  index({meta_rooms: 1})
end

[350243511369765, 350243511278761, 350243511280757, 350243511254749, 350243511295753].each do |c|
  course = Course.find(c.to_s)
  puts course.title
end

exit unless ARGV.first

#bwl a ws2013

[350243511369765, 350243511278761, 350243511280757].each do |c|
  course = Course.find(c.to_s)
  course.update_attribute(:course_short_desc_downcase, course.course_short_desc_downcase + " bwl a")
end

[350243511369765, 350243511278761, 350243511280757].each do |c|
  course = Course.find(c.to_s)
  course.update_attribute(:course_short_desc, "BWL A: " + course.course_short_desc)
  course.update_attribute(:title, "BWL A: " + course.title)
end

# winfo ws2013
[350243511254749, 350243511295753].each do |c|
  course = Course.find(c.to_s)
  puts course.title
  course.update_attribute(:description, 'Weitere Infos: <a href="http://dsor.upb.de/fileadmin/materials/GdW-2013-Infos.pdf">http://dsor.upb.de/fileadmin/materials/GdW-2013-Infos.pdf</a>, offizielle Termine: <a href="http://bit.ly/gdw-ws13">http://bit.ly/gdw-ws13</a><br>' + (course.description || ''))
end