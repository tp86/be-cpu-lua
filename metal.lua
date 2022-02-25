local function disconnect(i, o)
  if i.connected == o then
    o.connections[i] = nil
    i.connected = nil
  end
end

local function connect(i, o)
  i:disconnect()
  i.connected = o
  o.connections[i] = i.component or i
end

local function flipped(f)
  return function(b, a)
    return f(a, b)
  end
end

local Input = {}
Input.__index = Input

function Input.new(parent)
  new = {}
  new.component = parent
  return setmetatable(new, Input)
end

Input.connect = connect

function Input:disconnect()
  if self.connected then
    disconnect(self, self.connected)
  end
end

Output = {}
Output.__index = Output

function Output.new()
  new = {}
  new.connections = {}
  return setmetatable(new, Output)
end

Output.connect = flipped(connect)
Output.disconnect = flipped(disconnect)

function Output:propagate(signal)
  -- components to be updated (as set)
  local components = {}
  -- if signal has not changed, do not propagate
  if signal == self.current then
    return components
  end
  -- update current signal
  self.current = signal
  for input, component in pairs(self.connections) do
    -- propagate signal downstream
    input.signal = signal
    -- add downstream component to be updated
    components[component] = component
  end
  return components
end

return {
  Input = Input,
  Output = Output,
}
