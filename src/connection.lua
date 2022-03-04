local Input = {}
function Input:new(parent)
  local new = {}
  new.parent = parent
  self.__index = self
  return setmetatable(new, self)
end

function Input:connect(output)
  if self.connection == output then
    return
  end
  self.connection = output
  if output.connect then
    output:connect(self)
  end
end

function Input:disconnect()
  if self.connection then
    if self.connection.disconnect then
      self.connection:disconnect(self)
    end
    self.connection = nil
  end
end

function Input:connected()
  return self.connection
end

local Output = {}
function Output:new()
  local new = {}
  new.connections = {}
  self.__index = self
  return setmetatable(new, self)
end

function Output:connection_to(input)
  return self.connections[input]
end

function Output:connect(input)
  if self.connections[input] then
    return
  end
  self.connections[input] = input.parent or true
  if input.connect then
    input:connect(self)
  end
end

function Output:disconnect(input)
  if self.connections[input] then
    self.connections[input] = nil
    if input.disconnect then
      input:disconnect()
    end
  end
end

function Output:propagate(signal)
  if self.current_signal ~= nil and self.current_signal == signal then
    return
  end
  self.current_signal = signal
  local parents = {}
  for input, parent in pairs(self.connections) do
    input.signal = signal
    parents[parent] = true
  end
  return parents
end

return {
  Input = Input,
  Output = Output,
}
