local bases = setmetatable({}, {__mode = 'k'})
local bases_mt = {
  __index = function(e, f)
    for _, base in ipairs(bases[e]) do
      local f = base[f]
      if f ~= nil then return f end
    end
  end,
}
local function add_base(extension, base)
  local extension_bases = bases[extension] or {}
  extension_bases[#extension_bases + 1] = base
  bases[extension] = extension_bases
  setmetatable(extension, bases_mt)
end

local extend = function(base, extension)
  local extension = extension or {}
  add_base(extension, base)
  return function(...)
    (base.init or function() end)(extension, ...)
    return extension
  end
end

return {
  extend = extend,
}
