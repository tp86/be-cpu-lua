local high = {}
local low = {}

high = setmetatable(high, {
  __band = function(_, o) return o end,
  __bor = function() return high end,
  __bnot = function() return low end,
  __bxor = function(_, o) if o == low then return high else return low end end,
  __tostring = function() return '1' end,
})

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
