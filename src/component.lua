local extend = require('oop').extend
local gates = require('gate')

local function update_all_from(input_gates)
  local gates_to_update = input_gates
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

local ComponentBase = {
  init = function(Component)
    Component.init = function(instance)
      instance[1](instance)
      local gates_to_update = {}
      for _, gate in ipairs(instance.input_gates or error('component should have specified input_gates', 3)) do
        gates_to_update[gate] = true
      end
      update_all_from(gates_to_update)
    end
  end,
}

local SR = extend(ComponentBase, {
  function(sr)
    local r_nor = extend(gates.Nor)()
    local s_nor = extend(gates.Nor)()
    r_nor.C:connect(s_nor.A)
    s_nor.C:connect(r_nor.B)
    sr.S = s_nor.B
    sr.R = r_nor.A
    sr.Q = r_nor.C
    sr._Q = s_nor.C
    sr.input_gates = {s_nor, r_nor}
  end,
})()

return {
  ComponentBase = ComponentBase,
  update_all_from = update_all_from,
  SR = SR,
}
