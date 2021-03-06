local L = require('signal').L

local MultiInput = {
  init = function(obj, parent)
    obj.parent = parent
    obj.signal = L
    obj.connections = {}
  end,
  connect = function(self, output)
    if self.connections[output] then
      return
    end
    self.connections[output] = true
    if output.connect then
      output:connect(self)
    end
  end,
  disconnect = function(self, output)
    if self.connections[output] then
      if output.disconnect then
        output:disconnect(self)
      end
      self.connections[output] = nil
    end
  end,
  connected = function(self, output)
    return self.connections[output]
  end,
}

local Input = {
  init = function(obj, parent)
    obj.parent = parent
    obj.signal = L
  end,
  connect = function(self, output)
    if self.connection == output then
      return
    end
    self:disconnect()
    self.connection = output
    if output.connect then
      output:connect(self)
    end
  end,
  disconnect = function(self)
    if self.connection then
      if self.connection.disconnect then
        self.connection:disconnect(self)
      end
      self.connection = nil
    end
  end,
  connected = function(self)
    return self.connection
  end,
}

local Output = {
  init = function(obj)
    obj.connections = {}
  end,
  connection_to = function(self, input)
    return self.connections[input]
  end,
  connect = function(self, input)
    if self.connections[input] then
      return
    end
    self.connections[input] = input.parent or true
    if input.connect then
      input:connect(self)
    end
  end,
  disconnect = function(self, input)
    if self.connections[input] then
      self.connections[input] = nil
      if input.disconnect then
        input:disconnect()
      end
    end
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

return {
  MultiInput = MultiInput,
  Input = Input,
  Output = Output,
}
