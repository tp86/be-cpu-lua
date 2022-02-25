local metal = require('metal')
local Input = metal.Input
local Output = metal.Output

-- Input can be connected to Output
local input = Input.new()
local output = Output.new()
input:connect(output)
assert(output.connections[input],
      "output's `connections` should contain input")
assert(input.connected == output,
      "input's `connected` field should be equal to output")

-- Output can be connected to Input
local input = Input.new()
local output = Output.new()
output:connect(input)
assert(output.connections[input],
      "output's `connections` should contain input")
assert(input.connected == output,
      "input's `connected` field should be equal to output")

-- Input can be connected to only one Output
local input = Input.new()
local output1 = Output.new()
local output2 = Output.new()
input:connect(output1)
input:connect(output2)
assert(input.connected == output2,
      "input's `connected` field should be last connected output")
assert(not output1.connections[input],
      "output1's `connections` should not contain input")
assert(output2.connections[input],
      "output2's `connections` should contain input")

-- only one Output can be connected to given Input
local input = Input.new()
local output1 = Output.new()
local output2 = Output.new()
output1:connect(input)
output2:connect(input)
assert(input.connected == output2,
      "input's `connected` field should be last connected output")
assert(not output1.connections[input],
      "output1's `connections` should not contain input")
assert(output2.connections[input],
      "output2's `connections` should contain input")

-- Output can be connected to multiple Inputs
local input1 = Input.new()
local input2 = Input.new()
local output = Output.new()
output:connect(input1)
input2:connect(output)
assert(input1.connected == output,
      "input1's `connected` should be equal to output")
assert(input2.connected == output,
      "input2's `connected` should be equal to output")
assert(output.connections[input1],
      "output's `connections` should contain input1")
assert(output.connections[input2],
      "output's `connections` should contain input2")

-- Input can be disconnected from (any) Output
local input = Input.new()
local output = Output.new()
input:connect(output)
input:disconnect()
assert(not output.connections[input],
      "output's `connections` should not contain input")
assert(not input.connected,
      "input should not be connected")

-- Output can be disconnected from (specific) Input
local input = Input.new()
local output = Output.new()
output:connect(input)
output:disconnect(input)
assert(not output.connections[input],
      "output's `connections` should not contain input")
assert(not input.connected,
      "input should not be connected")

-- Output disconnects one (connected) input at time
local input1 = Input.new()
local input2 = Input.new()
local output = Output.new()
output:connect(input1)
output:connect(input2)
output:disconnect(input1)
assert(not output.connections[input1],
      "output's `connections` should not contain input1")
assert(output.connections[input2],
      "output's `connections` should contain input2")
assert(not input1.connected,
      "input1 should not be connected")
assert(input2.connected == output,
      "input2 should be connected to output")

-- Output disconnect only inputs connected to it
local input = Input.new()
local output1 = Output.new()
local output2 = Output.new()
output1:connect(input)
output2:disconnect(input)
assert(output1.connections[input],
      "output1 is still connected to input")
assert(input.connected == output1,
      "input is still connected to output1")

-- Output propagates signal's value to all inputs
local component = {}
local input1 = Input.new(component)
local input2 = Input.new(component)
local output = Output.new()
output:connect(input1)
output:connect(input2)
local function set_len(set)
  local items = 0
  for _, _ in pairs(set) do
    items = items + 1
  end
  return items
end
-- current signal value is not propagated
output.current = 1
assert(set_len(output:propagate(output.current)) == 0,
      "output does not propagate current signal")
new_signal = 2
assert(not input1.signal,
      "input should not have signal")
assert(not input2.signal,
      "input should not have signal")
components_to_be_updated = output:propagate(new_signal)
assert(output.current == new_signal,
      "output updates current signal value on change")
assert(input1.signal == new_signal,
      "input should have updated signal value")
assert(input2.signal == new_signal,
      "input should have updated signal value")
assert(components_to_be_updated[component]
       and set_len(components_to_be_updated) == 1,
      "output returns set of components to be updated")

-- Output connects to same Input only once (multiple connections are disallowed)
local input = Input.new()
local output = Output.new()
output:connect(input)
output:connect(input)
assert(set_len(output.connections) == 1,
      "same input should not be duplicated in output connections")
output:disconnect(input)
assert(not output.connections[input],
      "output should not contain any connections to input")
assert(not input.connected,
      "input should not be connected")


io.write('PASSED\n')
