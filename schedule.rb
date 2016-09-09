require_relative 'theater.rb'
require_relative 'movie.rb'

# Driver Code

theater = Theater.new({ monday: "11:00am - 11:00pm", tuesday: "11:00am-11:00pm", wednesday: "11:00am - 11:00pm", thursday: "11:00am - 11:00pm", friday: "10:30am - 11:30pm", saturday: "10:30am - 11:30pm", sunday: "10:30am - 11:30pm" })
movies = Movie.movie_objects(theater)
theater.schedule(movies, "Thursday")