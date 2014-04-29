require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :session

def random_sudoku
	seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
	sudoku = Sudoku.new(seed.join)
	sudoku.solve!
	sudoku.to_s.chars
end

# def puzzle(sudoku)
# end

get '/' do
	session[:solution] = sudoku
	@current_solution = random_sudoku
	erb :index
end 