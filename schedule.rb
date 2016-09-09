class Theater
  attr_reader :hours_of_operation
  
  def initialize(hours_hash)
    @hours_of_operation = hours_hash
  end

  def day_hours(input_day)
    day_of_week = input_day.downcase.to_sym
    opening_time = @hours_of_operation[day_of_week]
  end

  def opening_time_in_seconds(input_day)
    hours = day_hours(input_day)
    hours.gsub!(" ", "") # remove spaces from hours string
    hours_array = hours.split("-") # remove - to leave only array of time values
    opening_time_array = hours_array[0].split(":")

    # separate hour and minute values, convert total to seconds
    if opening_time_array[1].include?("am")
      opening_time_hour = opening_time_array[0].to_i
    else 
      opening_time_hour = opening_time_array[0].to_i + 12
    end

    opening_time_minutes = opening_time_array[1].gsub(/(am|pm)/, "").to_i
    opening_time_in_seconds = opening_time_hour * 3600 + opening_time_minutes * 60
  end

  def closing_time_in_seconds(input_day)
    hours = day_hours(input_day)
    hours.gsub!(" ", "")
    hours_array = hours.split("-")
    closing_time_array = hours_array[1].split(":")

    if closing_time_array[1].include?("am")
      closing_time_hour = closing_time_array[0].to_i
    else 
      closing_time_hour = closing_time_array[0].to_i + 12
    end

    closing_time_minutes = closing_time_array[1].gsub(/(am|pm)/, "").to_i
    closing_time_in_seconds = closing_time_hour * 3600 + closing_time_minutes * 60
  end

  def available_movie_time_in_seconds(input_day)
    seconds_open = closing_time_in_seconds(input_day) - opening_time_in_seconds(input_day)
    theater_opening_prep_seconds = 3600
    total_available_movie_time = seconds_open - theater_opening_prep_seconds
  end
end

class Movie
  attr_reader :title, :release_year, :rating, :run_time, :run_time_seconds, :theater

  def initialize(movie_hash, input_theater)
    @title = movie_hash[:title]
    @release_year = movie_hash[:release_year]
    @rating = movie_hash[:rating]
    @run_time = movie_hash[:run_time]
    @run_time_seconds = movie_hash[:run_time_seconds]
    @theater = input_theater
  end

  def self.movie_info_array
    movie_spreadsheet = ARGV.first
    movie_file = File.open(movie_spreadsheet)
    movie_array = IO.readlines(movie_file)

    movie_array.map! do |line|
      line.gsub(/\n/, "") # remove /n from movie info string
    end

    movie_array.shift # remove input file header row
    movie_array
  end

  def self.movie_objects(theater)
    movie_array = self.movie_info_array
    movie_hashes = []

    movie_array.each do |movie|
      movie_properties = movie.split(", ")
      
      # separate run time hours and minutes, convert total to seconds
      run_time_data = movie_properties[3].split(":")
      hours = run_time_data[0].to_i
      minutes = run_time_data[1].to_i
      run_time_in_seconds = hours * 3600 + minutes * 60

      movie_hashes << { title: movie_properties[0], release_year: movie_properties[1], rating: movie_properties[2], run_time: movie_properties[3], run_time_seconds: run_time_in_seconds }
    end

    movies = []
    movie_hashes.each do |movie_hash|
      movies << Movie.new(movie_hash, theater)
    end
    movies
  end 
end

# Driver Code

theater = Theater.new({ monday: "11:00am - 11:00pm", tuesday: "11:00am-11:00pm", wednesday: "11:00am - 11:00pm", thursday: "11:00am - 11:00pm", friday: "10:30am - 11:30pm", saturday: "10:30am - 11:30pm", sunday: "10:30am - 11:30pm" })
p theater
p theater.day_hours("friday")
p theater.opening_time_in_seconds("friday")
p theater.closing_time_in_seconds("friday")
p theater.available_movie_time_in_seconds("friday")
p Movie.movie_info_array
p Movie.movie_objects(theater)