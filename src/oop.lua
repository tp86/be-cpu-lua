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

local function extend(base, extension)
  local extension = extension or {}
  local extension_init = extension.init
  add_base(extension, base)
  return function(...)
    local base_init = base.init or function() end
    extension.init = nil
    base_init(extension, ...)
    if extension_init then
      local args = table.pack(...)
      extension.init = function(obj, ...)
        extend(base, obj)(table.unpack(args))
        extension_init(obj, ...)
      end
    end
    return extension
  end
end

return {
  extend = extend,
}
