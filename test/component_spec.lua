local extend = require('oop').extend

describe('a Component', function()
  local ComponentBase = require('component').ComponentBase
  local H = require('signal').H

  it('updates itself on creation', function()
    local Not = require('gate').Not
    local not1 = Not:clone()
    local not2 = Not:clone()
    local not3 = Not:clone()
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
