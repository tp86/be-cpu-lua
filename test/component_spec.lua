describe('a Component', function()
  local Component = require('component').Component
  local H = require('signal').H

  it('updates itself on creation', function()
    local Not = require('gate').Not
    local not1 = Not:clone()
    local not2 = Not:clone()
    local not3 = Not:clone()
    local TestComponent = Component:clone()
    function TestComponent:configure()
      not1.B:connect(not2.A)
      not2.B:connect(not3.A)
      self.In = not1.A
      self.Out = not3.B
    end
    TestComponent.input_gates = {not1}
    local update1 = spy.on(not1, 'update')
    local update2 = spy.on(not2, 'update')
    local update3 = spy.on(not3, 'update')
    local comp = TestComponent:clone()
    assert.spy(update1).was_called()
    assert.spy(update2).was_called()
    assert.spy(update3).was_called()
    assert.equals(H, comp.Out.current_signal)
  end)
end)
