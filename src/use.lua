local function use(p, o)
  local o = o or {}
  local o_meta = getmetatable(o) or {}
  if rawget(o_meta, '__index') then error(string.format("object %s already has '__index' metamethod", o)) end
  o_meta.__index = p
  setmetatable(o, o_meta)
  return o
end

local a = {x = 1}
local b = use(a)
b.y = 2
assert(type(b) == 'table', 'b should be a table')
local bks = {}
for k in pairs(b) do
  bks[k] = true
end
assert(bks.x == nil, "'x' should not be in b's keys")
assert(b.x == a.x, "a's 'x' should be accessible through b")
assert(b.y == 2)
assert(a.y == nil)
local c = use(b, {z = 3})
assert(c.x == a.x)
assert(c.y == b.y)
assert(c.z == 3)

local And = {
  new = function()
    local new = {
      C = use(Output)
    }
    new.A = use(Input, {parent = new})
    new.B = use(Input, {parent = new})
    return use(And, new)
  end,
  update = function(self)
    return self.output:propagate(self.A.signal & self.B.signal)
  end,
}

return use
