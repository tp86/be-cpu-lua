local prototypes = {}
local prototypes_mt = {
  __index = function(t, k)
    for _, prototype in ipairs(prototypes[t]) do
      local v = prototype[k]
      if v ~= nil then return v end
    end
  end,
  __mode = 'k',
}
local Prototype = {}
function Prototype:prototype_of(obj)
  local ps = prototypes[obj] or {}
  ps[#ps + 1] = self
  prototypes[obj] = ps
  setmetatable(obj, prototypes_mt)
end
function Prototype:clone(...)
  local clone = {}
  self:prototype_of(clone)
  clone:configure(...)
  return clone
end

Prototype.configure = function() end

return Prototype
