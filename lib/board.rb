require_relative 'translate_coordinates'
# require './lib/translate_coordinates.rb'

class Board
	
  include TranslateCoordinates

  DEFAULT_SIZE = 10
  # require 'constants'
  WATER = 0
  BOAT = 1
  MISS = 2
  HIT = 3
  KILL = 4

  attr_reader :size

	def initialize(options = {})
    @size = options.fetch(:size,DEFAULT_SIZE)
    @ships = []
    create(@size)
	end

  def create(size)
    @matrix = Array.new(size) { Array.new(size) { WATER } }
  end

  def handle_shot(coord)
    coordinates = translate_coordinates(coord)
    x = coordinates.first
    y = coordinates.last

    if is_valid?(x,y) && !is_shot?(x,y)
      hit_ship = ships.select.first {|ship| ship.take_hit(x,y)}
      # hit_ship != nil ? @matrix[x][y] = HIT : @matrix[x][y] = MISS
      
      if hit_ship != nil 
        if hit_ship.sunk?
          hit_ship.hit_list.each {|x,y| matrix[x][y] = KILL} 
        else
          @matrix[x][y] = HIT
        end
      else
        @matrix[x][y] = MISS
      end

    else 
      false  
    end
  end

  def show
    @matrix
  end

  def add_ship(ship)

    # 1. validate ship coordinates are between boundaries
    ship.coordinates.each {|c| return false if !is_valid?(c.first,c.last)}
    
    # 2. valid ship coord are not occupied by other ships
    ship.coordinates.each {|c| return false if is_taken?(c.first,c.last)}

    # 3. mark matrix coordinates
    ship.coordinates.each do |cell| 
      @matrix[cell.first][cell.last] = BOAT
    end

    # 4. add it to the collection of ships
    @ships << ship
  end

  def empty?
    @matrix.all? {|column| column.all? {|cell| cell == WATER} }
  end

  def ships
    @ships
  end

  def any_floating_ships_left?
    @ships.any? {|ship| !ship.sunk? }
  end

  private

  def is_shot?(x,y)
    @matrix[x][y] != BOAT && @matrix[x][y] != WATER 
  end

  def is_valid?(x,y)
    return x >= 0 && y >= 0 && x < @size && y < @size
  end

  def is_taken?(x,y)
    @matrix[x][y] != WATER
  end

end
