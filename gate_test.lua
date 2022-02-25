local gates = require('gate')
local Input = require('metal').Input
local H = require('logic').H
local L = require('logic').L

local checker = {}
checker.input = Input.new(checker)
checker.reset = function(self) self.input.signal = nil end
local gate

local function setup(gate_name)
  gate = gates[gate_name].new()
  checker:reset()
  gate.output:connect(checker.input)
end

local function make_assertions(assertions)
  for _, assertion in ipairs(assertions) do
    local inputs, expected = table.unpack(assertion)
    for input, signal in pairs(inputs) do
      gate[input].signal = signal
    end
    gate:update()
    assert(checker.input.signal == expected)
  end
end

-- Not gate test
setup('NotGate')
make_assertions{
  {{A = H}, L},
  {{A = L}, H},
}

-- And gate test
setup('AndGate')
make_assertions{
  {{A = L, B = L}, L},
  {{A = H}, L},
  {{B = H}, H},
  {{B = L}, L},
}

-- Or gate test
setup('OrGate')
make_assertions{
  {{A = H, B = L}, H},
  {{A = L}, L},
  {{B = H}, H},
  {{A = H}, H},
}

-- Nand gate test
setup('NandGate')
make_assertions{
  {{A = L, B = L}, H},
  {{A = H}, H},
  {{B = H}, L},
  {{B = L}, H},
}

-- Nor gate test
setup('NorGate')
make_assertions{
  {{A = H, B = L}, L},
  {{A = L}, H},
  {{B = H}, L},
  {{A = H}, L},
}

-- Xor gate test
setup('XorGate')
make_assertions{
  {{A = H, B = L}, H},
  {{A = L}, L},
  {{B = H}, H},
  {{A = H}, L},
}

-- Nxor gate test
setup('NxorGate')
make_assertions{
  {{A = H, B = L}, L},
  {{A = L}, H},
  {{B = H}, L},
  {{A = H}, H},
}


io.write('PASSED')
