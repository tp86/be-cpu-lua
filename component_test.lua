local utils = require('test_utils')
local comps = require('component')
local L = require('logic').L
local H = require('logic').H

local checker = utils.Checker.new()
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


io.write('PASSED\n')
