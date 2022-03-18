local function check_called_in_init()
  local level = 4
  local valid_level = debug.getinfo(level)
  if valid_level and valid_level.what == 'Lua' then
    local name, value = debug.getlocal(level, 1)
    return name == 'initializer' and value.init
  end
  return false
end
local function initializer(obj, init_fn)
  return setmetatable({init=true}, {
    __call = function(initializer, ...)
      print('calling initializer with', ...)
      local in_init = check_called_in_init()
      local o
      if in_init then
        print('in init')
        local _, self_in_init = debug.getlocal(2, 1)
        print(self_in_init)
        o = self_in_init
        -- how to get x here
        -- how to get last metatable in chain?
        local meta = self_in_init
        repeat
          meta = getmetatable(getmetatable(meta).__index)
        until getmetatable(meta) == nil
        print('obj', obj)
        print('meta', meta)
        setmetatable(meta, {__index = setmetatable({}, {__index = function(t, k) return obj[k] or (getmetatable(t) or {})[k] end})})
      else
        print('not in init')
        o = {}
        print(o)
        print('obj', obj)
        local m = {}
        print('m', m)
        setmetatable(o, {__index = setmetatable(m, {__index = function(t, k) return obj[k] or (getmetatable(t) or {})[k] end})})
      end
      init_fn(o, ...)
      return o
    end
  })
end

local base = {a = 3}
print('base', base)
local base_init = function(self)
  print('base init called with', self)
end
base_init = initializer(base, base_init)
local x = {b = 2}
print('x', x)
local x_init = function(self, ...)
  print('self in x_init', self)
  base_init(1, 2, 3)
end
xfn = initializer(x, x_init)
print('calling x')
local xobj = xfn()
print(xobj.a)
print(xobj.b)
print('raw call')
local baseobj = base_init(4, 5, 6)
print(getmetatable(baseobj))


-- TODO chain of inheritance + methods
-- test prototypes (inheritance not added)
