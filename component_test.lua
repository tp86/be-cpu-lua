local comps = require('component')
local Input = require('metal').Input
local L = require('logic').L
local H = require('logic').H

local checker = {}
checker.input = Input.new(checker)
checker.reset = function(self) self.input.signal = nil end

local clock = comps.Clock.new()
checker:reset()
clock.CLOCK:connect(checker.input)

clock:update()
assert(checker.input.signal == L)
clock:update()
assert(checker.input.signal == H)
clock:update()
assert(checker.input.signal == L)
clock:update()
assert(checker.input.signal == H)


io.write('PASSED')
