local Input = require('metal').Input
local update_all = require('loop')

local Checker = {}
Checker.__index = Checker

function Checker.new()
  local new = {}
  new.input = Input.new(new)
  return setmetatable(new, Checker)
end

function Checker:reset()
  self.input.signal = nil
end

function Checker:update()
  return {}
end

local function test_simulation(entrypoint_components, inputs, --[[{input = signal_value}]] expected_outputs --[[{input = signal_value}]])
  for input, signal_value in pairs(inputs) do
    input.signal = signal_value
  end
  local start_time = os.clock()
  update_all(entrypoint_components)
  local end_time = os.clock()
  print(string.format('simulation took %f seconds', end_time - start_time))
  for input, signal_value in pairs(expected_outputs) do
    assert(input.signal == signal_value)
  end
end

return {
  Checker = Checker,
  test_simulation = test_simulation,
}
