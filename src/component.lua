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

local D = extend(ComponentBase, {
  function(d)
    local sr = extend(SR)()
    local s_and = extend(gates.And)()
    local r_and = extend(gates.And)()
    local d_not = extend(gates.Not)()
    local e_in = extend(gates.support.Broadcast)()
    local d_in = extend(gates.support.Broadcast)()
    d_in.output:connect(d_not.A)
    d_in.output:connect(s_and.B)
    e_in.output:connect(r_and.B)
    e_in.output:connect(s_and.A)
    d_not.B:connect(r_and.A)
    r_and.C:connect(sr.R)
    s_and.C:connect(sr.S)
    d.D = d_in.input
    d.EN = e_in.input
    d.Q = sr.Q
    d._Q = sr._Q
    d.input_gates = {d_in, e_in}
  end,
})()

return {
  ComponentBase = ComponentBase,
  Clock = Clock,
  SR = SR,
  D = D,
}
