local extend = require('oop').extend
local gates = require('gate')

local ComponentBase = {
  init = function(Component)
    Component.init = function(instance, ...)
      instance[1](instance, ...)
      gates.update_all_connected_gates(instance.input_gates or error('component should have specified input_gates', 3))
    end
  end,
}

local Clock = extend(ComponentBase, {
  function(clock, signal)
    local flipper = extend(gates.support.Flipper)()
    flipper.signal = ~(signal or flipper.signal)
    clock.CLK = flipper.output
    clock.input_gates = {flipper}
  end,
})()

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
  Clock = Clock,
  SR = SR,
}
