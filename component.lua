local L = require('logic').L

local Clock = {}
Clock.__index = Clock

function Clock.new()
  local new = {}
  new.next = L
  new.CLOCK = Output.new()
  return setmetatable(new, Clock)
end

function Clock:update()
  local signal = self.next
  self.next = ~self.next
  return self.CLOCK:propagate(signal)
end

return {
  Clock = Clock,
}
