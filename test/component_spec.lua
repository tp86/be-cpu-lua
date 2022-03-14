local extend = require('oop').extend
local L = require('signal').L
local H = require('signal').H
local update_all_connected_gates = require('gate').update_all_connected_gates

describe('a Component', function()
  local ComponentBase = require('component').ComponentBase

  it('updates itself on creation', function()
    local Not = require('gate').Not
    local not1 = extend(Not)()
    local not2 = extend(Not)()
    local not3 = extend(Not)()
    local TestComponent = extend(ComponentBase, {
      function(comp)
        not1.B:connect(not2.A)
        not2.B:connect(not3.A)
        comp.In = not1.A
        comp.Out = not3.B
        comp.input_gates = {not1}
      end,
    })()
    local update1 = spy.on(not1, 'update')
    local update2 = spy.on(not2, 'update')
    local update3 = spy.on(not3, 'update')
    assert.spy(update1).was_not_called()
    assert.spy(update2).was_not_called()
    assert.spy(update3).was_not_called()
    local comp = extend(TestComponent)()
    assert.spy(update1).was_called()
    assert.spy(update2).was_called()
    assert.spy(update3).was_called()
    assert.equals(H, comp.Out.current_signal)
  end)
end)

local function assert_all(comp, data)
  for _, inputs_outputs in ipairs(data) do
    local inputs, outputs = table.unpack(inputs_outputs)
    for input, signal in pairs(inputs) do
      comp[input].signal = signal
    end
    update_all_connected_gates(comp.input_gates)
    for output, expected in pairs(outputs) do
      assert.equals(expected, comp[output].current_signal)
    end
  end
end

describe('a SR latch', function()
  local SR = require('component').SR
  local sr

  before_each(function()
    sr = extend(SR)()
  end)

  it('has proper interface', function()
    assert.is_not_nil(sr.S)
    assert.is_not_nil(sr.R)
    assert.is_not_nil(sr.Q)
    assert.is_not_nil(sr._Q)
  end)

  it('is initialized in reset state', function()
    assert.equals(L, sr.Q.current_signal)
    assert.equals(H, sr._Q.current_signal)
  end)

  it('latches on set and reset states', function()
    assert_all(sr, {
      {{S = L, R = L}, {Q = L, _Q = H}},
      {{S = H, R = L}, {Q = H, _Q = L}},
      {{S = L, R = L}, {Q = H, _Q = L}},
      {{S = L, R = H}, {Q = L, _Q = H}},
      {{S = L, R = L}, {Q = L, _Q = H}},
    })
  end)
end)
