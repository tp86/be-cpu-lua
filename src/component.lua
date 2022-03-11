local ComponentBase = {
  init = function(Component)
    Component.init = function(instance)
      instance[1](instance)
      local gates_to_update = {}
      for _, gate in ipairs(instance.input_gates or error('component should have specified input_gates', 3)) do
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
  end,
}

return {
  ComponentBase = ComponentBase,
}
