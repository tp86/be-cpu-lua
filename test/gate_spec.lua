describe('a Source', function()
  local Source = require('gate').Source
  local source

  before_each(function()
    source = Source:clone()
  end)

  it('has exactly one output', function()
    assert.is_not_nil(source.output)
  end)

  it('has no inputs', function()
    assert.is_nil(source.inputs)
  end)

  it('propagates signal through output on update', function()
    local propagate = spy.on(source.output, 'propagate')
    source:update()
    assert.spy(propagate).was_called()
  end)

  it("passes output's return value on update", function()
    local return_value = {1}
    stub(source.output, 'propagate').returns(return_value)
    local result = source:update()
    assert.equals(return_value, result)
  end)

  it('propagates values produced by update function', function()
    local counter = 0
    local source = Source:clone(function() counter = counter + 1; return counter end)
    local match = require('luassert.match')
    local propagate = spy.on(source.output, 'propagate')
    for _ = 1, 3 do
      source:update()
    end
    assert.spy(propagate).was_called_with(match.is_ref(source.output), 1)
    assert.spy(propagate).was_called_with(match.is_ref(source.output), 2)
    assert.spy(propagate).was_called_with(match.is_ref(source.output), 3)
  end)
end)

describe('a Sink', function()
  local Sink = require('gate').Sink

  it('has at least one input', function()
    local sink = Sink:clone()
    assert.is_true(#sink.inputs > 0)
  end)

  it('has no output', function()
    local sink = Sink:clone()
    assert.is_nil(sink.output)
  end)

  it('can have many inputs', function()
    local n_inputs = 3
    local sink = Sink:clone(nil, n_inputs)
    assert.equals(n_inputs, #sink.inputs)
  end)

  it('calls provided function on update', function()
    local sink = Sink:clone()
    local s = spy.on(sink, 'update_fn')
    sink:update()
    assert.spy(s).was_called()
  end)

  it("calls update function with inputs' signals", function()
    local sink = Sink:clone(nil, 3)
    local s = spy.on(sink, 'update_fn')
    sink.inputs[1].signal = 1
    sink.inputs[2].signal = 2
    sink.inputs[3].signal = 3
    sink:update()
    assert.spy(s).was_called_with(1, 2, 3)
  end)

  it('returns empty set on update', function()
    local sink = Sink:clone()
    local on_update = sink:update()
    assert.same({}, on_update)
  end)
end)

describe('a Gate', function()
  local Gate = require('gate').Gate

  it('has at least one input and exactly one output', function()
    local gate = Gate:clone()
    assert.is_true(#gate.inputs > 0)
    assert.is_not_nil(gate.output)
  end)

  it('has specified number of inputs', function()
    local n_inputs = 3
    local gate = Gate:clone(nil, n_inputs)
    assert.equals(n_inputs, #gate.inputs)
  end)

  it("applies provided function on inputs' signals and propagates result through output on update", function()
    local n_inputs = 2
    local gate = Gate:clone(function(a, b) return a + b end, n_inputs)
    local propagate = spy.on(gate.output, 'propagate')
    local match = require('luassert.match')
    gate.inputs[1].signal = 2
    gate.inputs[2].signal = 3
    gate:update()
    assert.spy(propagate).was_called_with(match.is_ref(gate.output), 5)
  end)

  it('returns result of output propagation on update', function()
    local gate = Gate:clone()
    local return_value = {1}
    stub(gate.output, 'propagate').returns(return_value)
    local result = gate:update()
    assert.equals(return_value, result)
  end)
end)

describe('a connection between Gates', function()
  local Gate = require('gate').Gate
  local source_gate
  local sink_gate

  before_each(function()
    source_gate = Gate:clone()
    sink_gate = Gate:clone()
  end)

  it('can be established by upstream (source) gate', function()
    source_gate.output:connect(sink_gate.inputs[1])
    assert.is_not_nil(source_gate.output.connections[sink_gate.inputs[1]])
    assert.equals(source_gate.output, sink_gate.inputs[1]:connected())
  end)

  it('can be established by downstream (sink) gate', function()
    sink_gate.inputs[1]:connect(source_gate.output)
    assert.is_not_nil(source_gate.output.connections[sink_gate.inputs[1]])
    assert.equals(source_gate.output, sink_gate.inputs[1]:connected())
  end)
end)

describe('an upstream Gate', function()
  local Gate = require('gate').Gate

  it('returns (set of) downstream gates on update', function()
    local upstream = Gate:clone()
    local downstream1 = Gate:clone()
    local downstream2 = Gate:clone()
    upstream.output:connect(downstream1.inputs[1])
    upstream.output:connect(downstream2.inputs[1])
    local downstreams = upstream:update()
    assert.same({[downstream1] = true, [downstream2] = true}, downstreams)
  end)
end)

describe('a downstream Gate', function()
  local Gate = require('gate').Gate

  it('receives results of upstream gates updates', function()
    local upstream1 = Gate:clone(function() return 1 end)
    local upstream2 = Gate:clone(function() return 2 end)
    local downstream = Gate:clone(nil, 2)
    upstream1.output:connect(downstream.inputs[1])
    upstream2.output:connect(downstream.inputs[2])
    local downstream_update = spy.on(downstream, 'update_fn')
    upstream1:update()
    upstream2:update()
    downstream:update()
    assert.spy(downstream_update).was_called_with(1, 2)
  end)
end)

local L = require('signal').L
local H = require('signal').H
local function assert_all(gate, data)
  local match = require('luassert.match')
  for _, inputs_outputs in ipairs(data) do
    local inputs, outputs = table.unpack(inputs_outputs)
    for input, signal in pairs(inputs) do
      gate[input].signal = signal
    end
    local output_spies = {}
    for output in pairs(outputs) do
      output_spies[output] = spy.on(gate[output], 'propagate')
    end
    gate:update()
    for output, expected in pairs(outputs) do
      assert.spy(output_spies[output]).was_called_with(match.is_ref(gate[output]), expected)
    end
  end
end

describe('a Not gate', function()
  it('implements signal negation function', function()
    local gate = require('gate').Not:clone()
    assert_all(gate, {
      {{A = L}, {B = H}},
      {{A = H}, {B = L}}
    })
  end)
end)

describe('an And gate', function()
  it('implements Boolean And function', function()
    local gate = require('gate').And:clone()
    assert_all(gate, {
      {{A = L, B = L}, {C = L}},
      {{A = H, B = L}, {C = L}},
      {{A = L, B = H}, {C = L}},
      {{A = H, B = H}, {C = H}},
    })
  end)
end)

describe('a Nand gate', function()
  it('implements Boolean Nand function', function()
    local gate = require('gate').Nand:clone()
    assert_all(gate, {
      {{A = L, B = L}, {C = H}},
      {{A = H, B = L}, {C = H}},
      {{A = L, B = H}, {C = H}},
      {{A = H, B = H}, {C = L}},
    })
  end)
end)

describe('an Or gate', function()
  it('implements Boolean Or function', function()
    local gate = require('gate').Or:clone()
    assert_all(gate, {
      {{A = L, B = L}, {C = L}},
      {{A = H, B = L}, {C = H}},
      {{A = L, B = H}, {C = H}},
      {{A = H, B = H}, {C = H}},
    })
  end)
end)

describe('a Nor gate', function()
  it('implements Boolean Nor function', function()
    local gate = require('gate').Nor:clone()
    assert_all(gate, {
      {{A = L, B = L}, {C = H}},
      {{A = H, B = L}, {C = L}},
      {{A = L, B = H}, {C = L}},
      {{A = H, B = H}, {C = L}},
    })
  end)
end)

describe('an Xor gate', function()
  it('implements Boolean Xor function', function()
    local gate = require('gate').Xor:clone()
    assert_all(gate, {
      {{A = L, B = L}, {C = L}},
      {{A = H, B = L}, {C = H}},
      {{A = L, B = H}, {C = H}},
      {{A = H, B = H}, {C = L}},
    })
  end)
end)

describe('a Nxor gate', function()
  it('implements Boolean Nxor function', function()
    local gate = require('gate').Nxor:clone()
    assert_all(gate, {
      {{A = L, B = L}, {C = H}},
      {{A = H, B = L}, {C = L}},
      {{A = L, B = H}, {C = L}},
      {{A = H, B = H}, {C = H}},
    })
  end)
end)

describe('a Broadcast gate', function()
  local Broadcast = require('gate').support.Broadcast

  it('has single input', function()
    local broadcast = Broadcast:clone()
    assert.equals(1, #broadcast.inputs)
    assert.is_not_nil(broadcast.input)
  end)

  it('passes signal from input to all connected inputs', function()
    local Sink = require('gate').Sink
    local broadcast = Broadcast:clone()
    local sink1 = Sink:clone()
    local sink2 = Sink:clone()
    sink1.inputs[1]:connect(broadcast.output)
    sink2.inputs[1]:connect(broadcast.output)
    broadcast.input.signal = 1
    assert.is_nil(sink1.inputs[1].signal)
    assert.is_nil(sink2.inputs[1].signal)
    broadcast:update()
    assert.equals(1, sink1.inputs[1].signal)
    assert.equals(1, sink2.inputs[1].signal)
  end)
end)

describe('a Probe gate', function()
  local Probe = require('gate').support.Probe

  it('has one input', function()
    local probe = Probe:clone()
    assert.equals(1, #probe.inputs)
    assert.is_not_nil(probe.input)
  end)

  it('has no outputs', function()
    local probe = Probe:clone()
    assert.is_nil(probe.output)
  end)

  it('calls provided closure on update', function()
    local result
    local callback = function(signal) result = signal end
    local probe = Probe:clone(callback)
    probe.input.signal = 2
    assert.is_nil(result)
    probe:update()
    assert.equals(2, result)
  end)
end)

describe('a Printer gate', function()
  local Printer = require('gate').support.Printer
  local old_out
  local out

  before_each(function()
    old_out = io.output()
    out = io.tmpfile()
    io.output(out)
  end)

  after_each(function()
    io.output(old_out)
  end)

  it('has one input', function()
    local printer = Printer:clone()
    assert.equals(1, #printer.inputs)
    assert.is_not_nil(printer.input)
  end)

  it('has no outputs', function()
    local printer = Printer:clone()
    assert.is_nil(printer.output)
  end)

  it('prints received signal value', function()
    local printer = Printer:clone()
    local input = 3
    printer.input.signal = input
    printer:update()
    out:seek('end', -1)
    local result = out:read('n')
    assert.equals(result, input)
  end)

  it('prints custom-labeled signal value', function()
    local label = 'custom'
    local printer = Printer:clone(label)
    printer.input.signal = 3
    printer:update()
    out:seek('set')
    local result = out:read()
    assert.is_truthy(string.match(result, label))
  end)
end)
