class Theater
  attr_accessor :hours_of_operation
  
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
