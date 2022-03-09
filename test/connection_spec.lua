describe('an Input', function()
  local Input = require('connection').Input
  local input

  before_each(function()
    input = Input:clone()
  end)

  it('can be connected', function()
    local output = {}
    input:connect(output)
    assert.equals(output, input:connected())
  end)

  it('can be disconnected', function()
    input:disconnect()
    assert.is_falsy(input:connected())
  end)

  it('can be connected to one output at a time', function()
    local output1 = {}
    local output2 = {}
    input:connect(output1)
    assert.equals(output1, input:connected())
    input:connect(output2)
    assert.equals(output2, input:connected())
  end)

  it('has parent (gate)', function()
    local parent = {}
    input = Input:clone(parent)
    assert.equals(input.parent, parent)
  end)
end)

describe('an Output', function()
  local Output = require('connection').Output
  local output

  before_each(function()
    output = Output:clone()
  end)

  it('can be connected', function()
    local input = {}
    output:connect(input)
    assert.is_truthy(output:connection_to(input))
  end)

  it('can be connected to multiple inputs', function()
    local input1 = {}
    local input2 = {}
    output:connect(input1)
    output:connect(input2)
    assert.is_truthy(output:connection_to(input1))
    assert.is_truthy(output:connection_to(input2))
  end)

  it('can be disconnected given connected input', function()
    local input1 = {}
    local input2 = {}
    output:connect(input1)
    output:connect(input2)
    output:disconnect(input1)
    assert.is_falsy(output:connection_to(input1))
    assert.is_truthy(output:connection_to(input2))
  end)

  it('propagates signal to all connected inputs', function()
    local input1 = {}
    local input2 = {}
    output:connect(input1)
    output:connect(input2)
    output:propagate(1)
    assert.equals(1, input1.signal)
    assert.equals(1, input2.signal)
  end)

  it('propagates only changed signal', function()
    local input = {}
    output:propagate(1)
    -- connect after signal propagation
    output:connect(input)
    output:propagate(1)
    -- signal not propagated
    assert.is_nil(input.signal)
    output:propagate(2)
    -- signal propagated
    assert.equals(2, input.signal)
  end)

  it("has access to connected inputs' parents", function()
    local input = {parent = {}}
    output:connect(input)
    assert.equals(input.parent, output:connection_to(input))
  end)

  it('returns table of unique parents of connected inputs on signal propagation', function()
    local parent = {}
    local input1 = {parent = parent}
    local input2 = {parent = parent}
    output:connect(input1)
    output:connect(input2)
    local parents = output:propagate(1)
    local parents_size = 0
    for p in pairs(parents) do
      parents_size = parents_size + 1
    end
    assert.equals(1, parents_size)
    assert.is_not_nil(parents[parent])
  end)
end)

describe('a Connection', function()
  -- a Connection means that both Input and Output have references to each other
  local connection = require('connection')
  local Input = connection.Input
  local Output = connection.Output
  local input, output

  before_each(function()
    input = Input:clone()
    output = Output:clone()
  end)

  it('is established on Input connection', function()
    input:connect(output)
    assert.is_truthy(output:connection_to(input))
  end)

  it('is established on Output connectin', function()
    output:connect(input)
    assert.is_truthy(input:connected())
  end)

  it('is removed on Input disconnection', function()
    output:connect(input)
    input:disconnect()
    assert.is_falsy(output:connection_to(input))
  end)
  
  it('is removed on Output disconnection', function()
    output:connect(input)
    output:disconnect(input)
    assert.is_falsy(input:connected())
  end)
end)
