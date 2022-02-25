local utils = require('test_utils')
local gates = require('gate')
local H = require('logic').H
local L = require('logic').L

--[=[
build circuit
--]=]

-- components
local broadcast = gates.support.Broadcast.new()
local not1 = gates.NotGate.new()
local not2 = gates.NotGate.new()
local and_gate = gates.AndGate.new()
local checker = utils.Checker.new()

-- connections
broadcast.output:connect(not1.A)
broadcast.output:connect(not2.A)
not1.B:connect(and_gate.A)
not2.B:connect(and_gate.B)
and_gate.C:connect(checker.input)

local entrypoint_components = {
  [broadcast] = true,
}

--[=[
test simulations
--]=]

utils.test_simulation(entrypoint_components,
{
  [broadcast.input] = L,
},
{
  [checker.input] = H,
})
utils.test_simulation(entrypoint_components,
{
  [broadcast.input] = H,
},
{
  [checker.input] = L,
})


io.write('PASSED\n')
