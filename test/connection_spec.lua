local extend = require('oop').extend

describe('a MultiInput', function()
  local MultiInput = require('connection').MultiInput
  local input

  before_each(function()
    input = extend(MultiInput)()
  end)

  it('can be connected', function()
    local output = {}
    input:connect(output)
    assert.truthy(input:connected(output))
  end)

  it('can be disconnected', function()
    local output = {}
    input:disconnect(output)
    assert.falsy(input:connected(output))
  end)

  it('has parent', function()
    local parent = {}
    input = extend(MultiInput)(parent)
    assert.equals(input.parent, parent)
  end)

  it('can be connected to many outputs at a time', function()
    local output1 = {}
    local output2 = {}
    input:connect(output1)
    input:connect(output2)
    assert.truthy(input:connected(output1))
    assert.truthy(input:connected(output2))
  end)

  it('has default signal when not yet propagated from connected output', function()
    assert.is_not_nil(input.signal)
  end)

  it('stores the last received signal from connected outputs', function()
    local Output = require('connection').Output
    local output1 = extend(Output)()
    local output2 = extend(Output)()
    output1:connect(input)
    output2:connect(input)
    output1:propagate(2)
    assert.equals(2, input.signal)
    output2:propagate(3)
    assert.equals(3, input.signal)
    output2:propagate(4)
    output1:propagate(5)
    assert.equals(5, input.signal)
  end)
end)

describe('an Input', function()
  local Input = require('connection').Input
  local input

  before_each(function()
    input = extend(Input)()
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
    local Output = require('connection').Output
    local output1 = extend(Output)()
    local output2 = extend(Output)()
    input:connect(output1)
    assert.equals(output1, input:connected())
    assert.truthy(output1:connection_to(input))
    assert.falsy(output2:connection_to(input))
    input:connect(output2)
    assert.equals(output2, input:connected())
    assert.falsy(output1:connection_to(input))
    assert.truthy(output2:connection_to(input))
  end)

  it('has parent (gate)', function()
    local parent = {}
    input = extend(Input)(parent)
    assert.equals(input.parent, parent)
  end)

  it('has default signal when not yet propagated from connected output', function()
    assert.is_nil(input:connected())
    assert.is_not_nil(input.signal)
  end)
end)

describe('an Output', function()
  local Output = require('connection').Output
  local output

  before_each(function()
    output = extend(Output)()
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

  it('returns array of parents of connected inputs on signal propagation', function()
    local parent = {}
    local input1 = {parent = parent}
    local input2 = {parent = parent}
    output:connect(input1)
    output:connect(input2)
    local parents = output:propagate(1)
    assert.equals(2, #parents)
    assert.equals(parent, parents[1])
    assert.equals(parent, parents[2])
  end)
end)

describe('a Connection', function()
  -- a Connection means that both Input and Output have references to each other
  local connection = require('connection')
  local Input = connection.Input
  local Output = connection.Output
  local input, output

  before_each(function()
    input = extend(Input)()
    output = extend(Output)()
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
