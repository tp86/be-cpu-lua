describe('a Source', function()
  local Source = require('gate').Source
  local source

  before_each(function()
    source = Source:new()
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
    local source = Source:new(function() counter = counter + 1; return counter end)
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
    local sink = Sink:new()
    assert.is_true(#sink.inputs > 0)
  end)

  it('has no output', function()
    local sink = Sink:new()
    assert.is_nil(sink.output)
  end)

  it('can have many inputs', function()
    local n_inputs = 3
    local sink = Sink:new(nil, n_inputs)
    assert.equals(n_inputs, #sink.inputs)
  end)

  it('calls provided function on update', function()
    local sink = Sink:new()
    local s = spy.on(sink, 'update_fn')
    sink:update()
    assert.spy(s).was_called()
  end)

  it("calls update function with inputs' signals", function()
    local sink = Sink:new(nil, 3)
    local s = spy.on(sink, 'update_fn')
    sink.inputs[1].signal = 1
    sink.inputs[2].signal = 2
    sink.inputs[3].signal = 3
    sink:update()
    assert.spy(s).was_called_with(1, 2, 3)
  end)

  it('returns empty set on update', function()
    local sink = Sink:new()
    local on_update = sink:update()
    assert.same({}, on_update)
  end)
end)

describe('a Gate', function()
  local Gate = require('gate').Gate

  it('has at least one input and exactly one output', function()
    local gate = Gate:new()
    assert.is_true(#gate.inputs > 0)
    assert.is_not_nil(gate.output)
  end)

  it('has specified number of inputs', function()
    local n_inputs = 3
    local gate = Gate:new(nil, n_inputs)
    assert.equals(n_inputs, #gate.inputs)
  end)

  it("applies provided function on inputs' signals and propagates result through output on update", function()
    local n_inputs = 2
    local gate = Gate:new(function(a, b) return a + b end, n_inputs)
    local propagate = spy.on(gate.output, 'propagate')
    local match = require('luassert.match')
    gate.inputs[1].signal = 2
    gate.inputs[2].signal = 3
    gate:update()
    assert.spy(propagate).was_called_with(match.is_ref(gate.output), 5)
  end)

  it('returns result of output propagation on update', function()
    local gate = Gate:new()
    local return_value = {1}
    stub(gate.output, 'propagate').returns(return_value)
    local result = gate:update()
    assert.equals(return_value, result)
  end)
end)
