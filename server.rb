require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'
require_relative './helpers/application' 

require 'sinatra/partial'
set :partial_template_engine, :erb

require 'rack-flash'
use Rack::Flash, :sweep =>true

enable :sessions
set :session_secret, 'This is a secret key' 

def random_sudoku
	seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
	sudoku = Sudoku.new(seed.join)
	sudoku.solve!
	sudoku.to_s.chars
end

def puzzle(sudoku,number)
	puzzle_sudoku = sudoku.dup
	number.times {puzzle_sudoku[rand(sudoku.length)] = "0"}
	puzzle_sudoku
end

def box_order_to_row_order(cells)
  boxes = cells.each_slice(9).to_a
  (0..8).to_a.inject([]) {|memo, i|
  first_box_index = i / 3 * 3
  three_boxes = boxes[first_box_index, 3]
  three_rows_of_three = three_boxes.map do |box|
    row_number_in_a_box = i % 3
    first_cell_in_the_row_index = row_number_in_a_box * 3 
    box[first_cell_in_the_row_index, 3]
  end
    memo += three_rows_of_three.flatten
  }
  end

def generate_new_puzzle_if_necessary(number = 50)
    return if session[:current_solution]
    sudoku = random_sudoku
    session[:solution] = sudoku
    session[:puzzle] = puzzle(sudoku,number)
    session[:current_solution] = session[:puzzle]
  end
  
  def prepare_to_check_solution
    @check_solution = session[:check_solution]
    if @check_solution
      flash.now[:notice] = "Incorrect values are highlighted in red"
    end
    session[:check_solution] = nil
  end

  get '/solution' do
    @current_solution = session[:solution]
    @solution = session[:solution]
    @puzzle = session[:puzzle]  
    erb :index
  end

  post '/reset' do
    @current_solution = session[:current_solution] || session[:puzzle]
    @solution = session[:solution]
    @puzzle = session[:puzzle]
    session[:current_solution] = session[:puzzle]
    erb :index
  end

  get '/' do
    prepare_to_check_solution
    generate_new_puzzle_if_necessary
    @current_solution = session[:current_solution] || session[:puzzle]
    @solution = session[:solution]
    @puzzle = session[:puzzle]  
    erb :index
  end

  post '/' do
    cells = box_order_to_row_order(params["cell"])
    session[:current_solution] = cells.map{ |value| value.to_i  }.join
    session[:check_solution] = true
    redirect to("/")
  end

  post '/easy' do
    session.clear
    generate_new_puzzle_if_necessary(10)
    redirect to('/')
  end

   post '/medium' do
    session.clear
    generate_new_puzzle_if_necessary(30)
    redirect to('/')
  end

    post '/hard' do
    session.clear
    generate_new_puzzle_if_necessary(45)
    redirect to('/')
  end

  #  post '/' do
  #   session.clear
  #   level(medium)
  #   erb :index
  # end

  #  post '/' do
  #   session.clear
  #   level(hard)
  #   erb :index
  # end
