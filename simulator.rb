class Simulator
  INSTRUCTIONS = {
      'L' => :turn_left,
      'R' => :turn_right,
      'A' => :advance
  }

  def instructions(instructions_string)
    (0...instructions_string.length).map {|i| INSTRUCTIONS[instructions_string[i]]}
  end

  def place(robot, x:, y:, direction:)
    robot.at(x, y)
    robot.orient(direction)
  end

  def evaluate(robot, instructions_string)
    instructions(instructions_string).each {|command| robot.send(command) }
  end
end