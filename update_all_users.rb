# simply paste in (heroku) rails console, and run 'my_update!'. 
# it will print out an estimate and then run

def update_non_custom_courses!(user)
  courses = user.events.map(&:course_id).uniq
  courses.each do |c|
    begin
      old_course = Course.find(c)
      paul_id = old_course.paul_id
      new_course = Course.where(paul_id: paul_id).where(parse_revision: 2).first
      user.events.where(course_id: c).where(custom: false).delete_all
      user.add_course!(new_course)
    rescue
      user.events.where(course_id: c).where(custom: false).delete_all
    end
  end
end

def estimate!
  puts "updating first five users to estimate time needed"
  user_count = User.count

  beginning = Time.now
  User.desc(:created_at).limit(5).each_with_index do |user, i|
    print "#{i+1} .. "
    update_non_custom_courses!(user)
  end
  puts 'done.'
  (Time.now - beginning)/5
end

def course_avg
  event_counts = User.all.map do |user|
    user.events.count
  end
  event_counts.reject do |count|
    count == 0
  end.sum.to_f / event_counts.length
end

def my_update!
  skip_c=0 # set to the last printed number if something failed or your connection went down

  seconds_per = estimate!

  puts "=> #{(1.0/seconds_per).round(1)} users per second"
  
  user_count = User.count

  eta = (user_count - 5)/seconds_per/60
  puts "So this will take about #{eta.round} minutes (estimated finish @ #{(Time.now + eta.minutes).strftime("%R")})."

  puts "now updating the other #{user_count - 5} users\nnote: first number in status lines can be used to resume via skip_c.\nnow GO!"
  User.desc(:created_at).skip(5+skip_c).each_with_index do |user, i|
    puts "#{i+5+skip_c} - #{((100*i+5+skip_c).to_f/user_count).round(1)}%" if i % 20 == 0
    update_non_custom_courses!(user)
  end
end