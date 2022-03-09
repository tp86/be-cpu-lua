local Prototype = require('prototype')
local Component = Prototype:clone()
function Component:configure()
  self.clone = function(...)
    local clone = Prototype.clone(self)
    clone:init_update()
    return clone
  end
  self.input_gates = {}
end
function Component:init_update()
  local gates_to_update = {}
  for _, gate in ipairs(self.input_gates) do
    gates_to_update[gate] = true
  end
  repeat
    local next_gates = {}
    for gate in pairs(gates_to_update) do
      local gates = gate:update()
      for gate in pairs(gates) do
        next_gates[gate] = true
      end
    end
    gates_to_update = next_gates
  until not next(gates_to_update)
end

return {
  Component = Component,
}
