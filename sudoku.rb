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

def puzzle(sudoku)
	40.times do
		random_index = rand(sudoku.length)
		sudoku[random_index] = 0
	end
	sudoku
end

get '/' do
	sudoku = random_sudoku
	session[:solution] = sudoku
	@current_solution = puzzle(sudoku)
	erb :index
end 