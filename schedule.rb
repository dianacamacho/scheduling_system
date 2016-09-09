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

  def schedule(movies, input_day)
    day_of_week = input_day.capitalize
    full_schedule = "#{day_of_week}\n\n"
    movies.each do |movie|
      full_schedule += movie.print_schedule(input_day) + "\n\n"
    end
    puts full_schedule
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

  def run_time_for_easy_read
    if @run_time.end_with?("1") || @run_time.end_with?("6")
      @easy_run_time_seconds = @run_time_seconds + 4 * 60
    elsif @run_time.end_with?("2") || @run_time.end_with?("7")
      @easy_run_time_seconds = @run_time_seconds + 3 * 60
    elsif @run_time.end_with?("3") || @run_time.end_with?("8")
      @easy_run_time_seconds = @run_time_seconds + 2 * 60
    elsif @run_time.end_with?("4") || @run_time.end_with?("9")
      @easy_run_time_seconds = @run_time_seconds + 60
    end
    @easy_run_time_seconds    
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

  def latest_start_time_in_seconds(input_day)
    start_time_in_seconds = @theater.closing_time_in_seconds(input_day) - run_time_for_easy_read
  end

  def available_playing_time_before_final_show(input_day)
    available_time_in_seconds = @theater.available_movie_time_in_seconds(input_day) - run_time_for_easy_read
  end

  def movie_run_time_before_final_show
    theater_clean_up_in_seconds = 35 * 60
    pre_final_movie_run_time = run_time_for_easy_read + theater_clean_up_in_seconds
  end

  def showings_per_day(input_day)
    # showings before final show + last showing
    showings = available_playing_time_before_final_show(input_day) / movie_run_time_before_final_show + 1
  end

  def schedule_start_times(input_day)
    start_times = []
    early_showings = showings_per_day(input_day) - 1
    last_start_time_in_seconds = latest_start_time_in_seconds(input_day)
    last_start_time_hours = last_start_time_in_seconds / 3600
    last_start_time_minutes = last_start_time_in_seconds % 3600 / 60

    # convert time to 12 hour am/pm format
    if last_start_time_hours > 12
      last_start_time_hours -= 12
      if last_start_time_minutes < 10 # add 0 before single digit minute values
        last_start_time = "#{last_start_time_hours}:0#{last_start_time_minutes}pm"
      else 
        last_start_time = "#{last_start_time_hours}:#{last_start_time_minutes}pm"
      end
    else
      last_start_time = "#{last_start_time_hours}:#{last_start_time_minutes}am"
    end

    start_times.insert(0, last_start_time)
    previous_start_time_in_seconds = last_start_time_in_seconds
  
    early_showings.times do 
      start_time_in_seconds = previous_start_time_in_seconds - movie_run_time_before_final_show
      start_time_hours = start_time_in_seconds / 3600
      start_time_minutes = start_time_in_seconds % 3600 / 60
      
      if start_time_minutes < 10 
        start_time_minutes = "0#{start_time_minutes}"
      end

      if start_time_hours > 12
        start_time_hours -= 12
        start_time = "#{start_time_hours}:#{start_time_minutes}pm"
      elsif start_time_hours == 12
        start_time = "#{start_time_hours}:#{start_time_minutes}pm"
      else
        start_time = "#{start_time_hours}:#{start_time_minutes}am"
      end
      
      start_times.insert(0, start_time)
      previous_start_time_in_seconds = start_time_in_seconds
    end
    start_times
  end

  def schedule_end_times(input_day)
    end_times = []
    early_showings = showings_per_day(input_day) - 1
    last_end_time_in_seconds = latest_start_time_in_seconds(input_day) + @run_time_seconds
    last_end_time_hours = last_end_time_in_seconds / 3600
    last_end_time_minutes = last_end_time_in_seconds % 3600 / 60

    if last_end_time_hours > 12
      last_end_time_hours -= 12
      if last_end_time_minutes < 10
        last_end_time = "#{last_end_time_hours}:0#{last_end_time_minutes}pm"
      else 
        last_end_time = "#{last_end_time_hours}:#{last_end_time_minutes}pm"
      end
    else
      last_end_time = "#{last_end_time_hours}:#{last_end_time_minutes}am"
    end

    end_times.insert(0, last_end_time)
    previous_end_time_in_seconds = last_end_time_in_seconds
  
    early_showings.times do 
      end_time_in_seconds = previous_end_time_in_seconds - movie_run_time_before_final_show
      end_time_hours = end_time_in_seconds / 3600
      end_time_minutes = end_time_in_seconds % 3600 / 60
      
      if end_time_minutes < 10 
        end_time_minutes = "0#{end_time_minutes}"
      end

      if end_time_hours > 12
        end_time_hours -= 12
        end_time = "#{end_time_hours}:#{end_time_minutes}pm"
      elsif end_time_hours == 12
        end_time = "#{end_time_hours}:#{end_time_minutes}pm"
      else
        end_time = "#{end_time_hours}:#{end_time_minutes}am"
      end
      
      end_times.insert(0, end_time)
      previous_end_time_in_seconds = end_time_in_seconds
    end
    end_times
  end

  def print_schedule(input_day)
    show_times = []
    start_times = schedule_start_times(input_day)
    end_times = schedule_end_times(input_day)
   
    loop_times = start_times.count
    index = 0

    loop_times.times do
      show_time = []
      show_time << start_times[index]
      show_time << end_times[index]
      index += 1
      show_times << show_time
    end

    movie_schedule = "#{@title} - Rated #{@rating}, #{@run_time}\n"
    show_times.each do |show_time| 
      movie_schedule += "\n\t#{show_time[0]} - #{show_time[1]}"
    end
    movie_schedule
  end
end

# Driver Code

theater = Theater.new({ monday: "11:00am - 11:00pm", tuesday: "11:00am-11:00pm", wednesday: "11:00am - 11:00pm", thursday: "11:00am - 11:00pm", friday: "10:30am - 11:30pm", saturday: "10:30am - 11:30pm", sunday: "10:30am - 11:30pm" })
# p theater
# p theater.day_hours("thursday")
# p theater.opening_time_in_seconds("thursday")
# p theater.closing_time_in_seconds("thursday")
# p theater.available_movie_time_in_seconds("thursday")
# p Movie.movie_info_array
# p Movie.movie_objects(theater)
# p Movie.movie_objects(theater).first.latest_start_time_in_seconds("thursday")
# p Movie.movie_objects(theater).first.available_playing_time_before_final_show("thursday")
# p Movie.movie_objects(theater).first.movie_run_time_before_final_show
# p Movie.movie_objects(theater).first.showings_per_day("thursday")
# p Movie.movie_objects(theater).first.schedule_start_times("thursday")
# p Movie.movie_objects(theater).first.schedule_end_times("thursday")
# p Movie.movie_objects(theater).first.print_schedule("thursday")
movies = Movie.movie_objects(theater)
theater.schedule(movies, "thursday")