local high = {}
local low = {}

high = setmetatable(high, {
  __band = function(_, o) return o end,
  __bor = function() return high end,
  __bnot = function() return low end,
  __bxor = function(_, o) if o == low then return high else return low end end,
  __tostring = function() return '1' end,
})

function low.and_(s) return low end
function low.or_(s) return s end
function low.not_() return high end
function low.xor_(s) if s == high then return high else return low end end
low = setmetatable(low, {
  __band = function() return low end,
  __bor = function(_, o) return o end,
  __bnot = function() return high end,
  __bxor = function(_, o) if o == high then return high else return low end end,
  __tostring = function() return '0' end,
})

return {
  H = high,
  L = low,
}
