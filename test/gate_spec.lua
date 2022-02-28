describe('a Gate', function()
  local Gate = require('gate').Gate

  local function len(tbl)
    local items = 0
    for _ in pairs(tbl) do
      items = items + 1
    end
    return items
  end

  it('can have 0 inputs and output', function()
    local n_inputs = 0
    local gate = Gate:new(n_inputs)
    assert.equals(n_inputs, len(gate.inputs))
    assert.is_not_nil(gate.output)
  end)

  it('can have many inputs and no output', function()
    local n_inputs = 2
    local gate = Gate:new(n_inputs, false)
    assert.equals(n_inputs, len(gate.inputs))
    assert.is_nil(gate.output)
  end)

  pending('can have many inputs and output', function()
  end)
  
  pending('cannot have no inputs and no output', function()
  end)

  pending('propagates signal through output on update', function()
  end)

  pending("reads inputs' signals on update", function()
  end)

  pending('applies function over inputs on update', function()
  end)
end)
