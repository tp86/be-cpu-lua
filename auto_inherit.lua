local prototypes = {}
local proto_mt = {
  __index = function(t, k)
    for _, proto in ipairs(prototypes[t]) do
      local v = proto[k]
      if v ~= nil then return v end
    end
  end
}
local factories = {}
local function factory(prototype, initializer)
  local function factory_fn(...)
    -- register itself as factory
    factories[factory_fn] = true
    local in_init = false
    -- check if called from initializer wrapped in another factory (another factory in call stack)
    -- if so, remember stack level
    local level = 3
    local caller = debug.getinfo(level, 'f')
    while caller do
      in_init = factories[caller.func]
      if in_init then break end
      level = level + 1
      caller = debug.getinfo(level, 'f')
    end
    local o
    if in_init then
      -- called in another initializer
      -- access first parameter (object being initialized)
      local _, obj = debug.getlocal(level - 1, 1)
      o = obj
      local obj_prototypes = prototypes[obj]
      obj_prototypes[#obj_prototypes + 1] = prototype
    else
      -- called outside of initializers - create new object to be initialized
      o = setmetatable({}, proto_mt)
      prototypes[o] = {prototype}
    end
    initializer(o, ...)
    return o
  end
  return factory_fn
end

local base = {a = 3}
local base_init = function(self, ...)
  print('base_init called with', ...)
  self.c = self.a + 4
end
base_init = factory(base, base_init)
local x = {b = 2}
local x_init = function(self, ...)
  base_init(1, self.b, 3)
end
xfn = factory(x, x_init)
local xobj = xfn()
print('accessing')
print(xobj.a)
print(xobj.b)
print(xobj.c)
local baseobj = base_init(4, 5, 6)

local A = {
  a = function(self)
    print('a', self, self.x)
  end
}
local Amaker = factory(A, function(self, x)
  self.x = x
end)
local a = Amaker(5)
assert(a.x == 5)
print(a)
a:a()
assert(A.x == nil)

local B = {b = function(self) print('b', self, self.y)end }
local function am(y)
  Amaker(11 - y)
end
local Bmaker = factory(B, function(self, y)
  am(y)
  self.y = self.x + y
end)
local b = Bmaker(4)
assert(b.y == 11)
print(b)
b:a()
b:b()
assert(A.b == nil)
assert(getmetatable(A) == nil)
assert(getmetatable(B) == nil)
