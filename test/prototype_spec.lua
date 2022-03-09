describe('a Prototype', function()
  local Prototype = require('prototype')

  it('can be cloned', function()
    local clone = Prototype:clone()
    assert.is_not_nil(clone)
    assert.not_equals(Prototype, clone)
  end)

  it('can become prototype of object', function()
    local obj = {}
    assert.has_no_errors(function() Prototype:prototype_of(obj) end)
  end)

  it('is configured when cloning', function()
    local configure = spy.on(Prototype, 'configure')
    local args = {1, 2, 3}
    local clone = Prototype:clone(table.unpack(args))
    local ref = require('luassert.match').is_ref(clone)
    assert.spy(configure).was_called_with(ref, table.unpack(args))
  end)
end)

describe('a Prototype clone', function()
  local Prototype = require('prototype')
  local clone

  before_each(function()
    clone = Prototype:clone()
  end)

  it('inherits from Prototype', function()
    for field in pairs(Prototype) do
      assert.equals(Prototype[field], clone[field])
    end
  end)

  it('can overwrite members', function()
    clone.configure = function() end
    assert.not_equals(Prototype.configure, clone.configure)
  end)

  it('can have multiple prototypes', function()
    local Base1 = Prototype:clone()
    Base1.x = 1
    local Base2 = Prototype:clone()
    Base2.x = 2
    Base2.y = 3
    local clone = Base1:clone()
    Base2:prototype_of(clone)
    assert.equals(1, clone.x)
    assert.equals(3, clone.y)
  end)
end)
