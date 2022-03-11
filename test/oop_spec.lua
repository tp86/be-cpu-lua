describe('a table', function()
  local extend = require('oop').extend

  it('can extend base table', function()
    local base = {
      param = {},
    }
    local extension = {}
    extend(base, extension)()
    assert.equals(base.param, extension.param)
  end)

  it('can extend multiple bases', function()
    local base1 = {
      x = {},
    }
    local base2 = {
      y = {},
    }
    local extension = {}
    extend(base1, extension)()
    extend(base2, extension)()
    assert.equals(base1.x, extension.x)
    assert.equals(base2.y, extension.y)
  end)

  it('inherits from multiple bases in depth-first mode', function()
    local parent1 = {
      x = {},
    }
    local base1 = {}
    extend(parent1, base1)()
    local base2 = {
      x = {},
    }
    local extension = {}
    extend(base1, extension)()
    extend(base2, extension)()
    assert.equals(parent1.x, extension.x)
  end)

  it("can override base's fields", function()
    local base = {
      x = {},
    }
    local extension = {
      x = {},
    }
    extend(base, extension)()
    assert.not_equals(base.x, extension.x)
    extension.x = nil
    assert.equals(base.x, extension.x)
    extension.x = {}
    assert.not_equals(base.x, extension.x)
  end)

  it('can be created as extension if not provided', function()
    local base = {}
    assert.is_not_nil(extend(base)())
  end)

  it("calls base's init on extension passing extension as first argument", function()
    local base = {}
    local init = stub(base, 'init')
    local extension = {}
    local match = require('luassert.match')
    extend(base, extension)()
    assert.spy(init).was_called_with(match.is_ref(extension))
  end)

  it("passes provided arguments to base's init on extension", function()
    local base = {}
    local init = stub(base, 'init')
    local extension = {}
    local match = require('luassert.match')
    local x, y, z = 1, 2, 3
    extend(base, extension)(x, y, z)
    assert.spy(init).was_called_with(match.is_ref(extension), x, y, z)
  end)
end)
