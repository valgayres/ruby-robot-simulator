require 'state_machine'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/enumerable'

class Robot
  cattr_accessor(:robots)   { [] }
  cattr_accessor(:next_id)  { 0  }

  class AlreadyUsedCoordinates < Exception

  end

  POSSIBLE_DIRECTION = [
      :north,
      :east,
      :south,
      :west
  ]

  attr_accessor :coordinates,
                :id

  def initialize
    self.class.robots << self
    self.coordinates = [0,0]
    self.id          = (self.class.next_id += 1)
    super()
  end

  def self.delete_robot(id)
    self.robots.select! {|r| r.id != id}
  end

  def orient(direction)
    raise ArgumentError unless POSSIBLE_DIRECTION.include?(direction)
    self.bearing = direction
  end

  def at(*coordinates)
    self.coordinates = coordinates
  end

  def advance
    return unless super
    at(*next_position)
  end

  def next_position
    case bearing
      when :north
        [0, 1]
      when :east
        [1, 0]
      when :south
        [0, -1]
      when :west
        [-1, 0]
    end.zip(self.coordinates).map(&:sum)
  end

  def check_position_validity
    raise AlreadyUsedCoordinates if self.class.robots.map(&:coordinates).include?(next_position)
  end

  state_machine :bearing, initial: :north do
    after_transition do |robot, _transition|
      robot.check_position_validity
    end

    event :turn_right do
      (0..3).each { |i| transition POSSIBLE_DIRECTION[i] => POSSIBLE_DIRECTION[(i + 1) % 4] }
    end

    event :turn_left do
      (0..3).each { |i| transition POSSIBLE_DIRECTION[i] => POSSIBLE_DIRECTION[(i - 1) % 4] }
    end

    event :advance do
      transition any => any
    end

    states.each do |state|
      self.state(state.name, value: state.name.to_sym)
    end
  end

end