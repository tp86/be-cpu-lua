local use = require('use')
local L = require('signal').L

local multiinput_connections = {}
local function multiinput_connect(input, output)
  local input_connections = multiinput_connections[input] or {}
  if input_connections[output] then return end
  input_connections[output] = true
  multiinput_connections[input] = input_connections
end
local MultiInput = {
  connected = function(self, output)
    return (multiinput_connections[self] or {})[output]
  end,
}

local input_connections = {}
local function input_connect(input, output)
  if input_connections[input] then
    if input_connections[input] == output then return end
    error('attempt to connect to already connected input!', 3)
  end
  input_connections[input] = output
end
local Input = {
  connected = function(self)
    return input_connections[self]
  end,
}
local function connect(output, input)
  local input_obj = (getmetatable(input) or {}).__index
  while input_obj do
    if input_obj == Input then
      return input_connect(input, output)
    elseif input_obj == MultiInput then
      return multiinput_connect(input, output)
    end
    input_obj = (getmetatable(input_obj) or {}).__index
  end
end

local Output = {
  connection_to = function(self, input)
    return self.connections[input]
  end,
  connect = function(self, input)
    if self.connections[input] then return end
    self.connections[input] = input.parent or true
    connect(self, input)
  end,
  propagate = function(self, signal)
    if self.current_signal ~= nil and self.current_signal == signal then
      return {}
    end
    self.current_signal = signal
    local parents = {}
    for input, parent in pairs(self.connections) do
      input.signal = signal
      parents[#parents + 1] = parent
    end
    return parents
  end,
}

local function new_input(obj)
  return function(parent)
    return use(obj, {
      parent = parent,
      signal = L
    })
  end
end

return {
  MultiInput = new_input(MultiInput),
  Input = new_input(Input),
  Output = function()
    return use(Output, {
      connections = {},
    })
  end,
}
