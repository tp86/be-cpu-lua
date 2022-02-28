describe('an Input', function()
  local Input = require('connection').Input
  local input

  before_each(function()
    input = Input:new()
  end)

  it('can be connected', function()
    local output = {}
    input:connect(output)
    assert.equals(output, input:connected_to())
  end)

  it('can be disconnected', function()
    input:disconnect()
    assert.is_falsy(input:connected_to())
  end)

  it('can be connected to one output at a time', function()
    local output1 = {}
    local output2 = {}
    input:connect(output1)
    assert.equals(output1, input:connected_to())
    input:connect(output2)
    assert.equals(output2, input:connected_to())
  end)
end)

describe('an Output', function()
  local Output = require('connection').Output
  local output

  before_each(function()
    output = Output:new()
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
    local match = require('luassert.match')
    local s = spy.new(function() end)
    local input = setmetatable({}, {
      __newindex = function(t, k, v)
        s(t, k, v)
        rawset(t, k, v)
      end})
    output:propagate(1)
    -- connect after signal propagation
    output:connect(input)
    output:propagate(1)
    -- signal not propagated
    assert.spy(s).was_not_called()
    output:propagate(2)
    assert.spy(s).was_called(1)
  end)
end)

describe('a Connection', function()
  -- a Connection means that both Input and Output have references to each other
  local connection = require('connection')
  local Input = connection.Input
  local Output = connection.Output
  local input, output

  before_each(function()
    input = Input:new()
    output = Output:new()
  end)

  it('is established on Input connection', function()
    input:connect(output)
    assert.is_truthy(output:connection_to(input))
  end)

  it('is established on Output connectin', function()
    output:connect(input)
    assert.is_truthy(input:connected_to())
  end)

  it('is removed on Input disconnection', function()
    output:connect(input)
    input:disconnect()
    assert.is_falsy(output:connection_to(input))
  end)
  
  it('is removed on Output disconnection', function()
    output:connect(input)
    output:disconnect(input)
    assert.is_falsy(input:connected_to())
  end)
end)
