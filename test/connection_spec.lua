describe('a MultiInput', function()
  local MultiInput = require('connection').MultiInput
  local input

  before_each(function()
    input = MultiInput()
  end)

  it('has parent', function()
    local parent = {}
    input = MultiInput(parent)
    assert.equals(input.parent, parent)
  end)

  it('has default signal when not yet propagated from connected output', function()
    assert.is_not_nil(input.signal)
  end)

  it('stores the last received signal from connected outputs', function()
    local Output = require('connection').Output
    local output1 = Output()
    local output2 = Output()
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
    input = Input()
  end)

  it('can be connected to one output at a time', function()
    local Output = require('connection').Output
    local output1 = Output()
    local output2 = Output()
    output1:connect(input)
    assert.has.errors(function() output2:connect(input) end)
  end)

  it('has parent (gate)', function()
    local parent = {}
    input = Input(parent)
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
    output = Output()
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
