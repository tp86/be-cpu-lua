local update_all = require('loop')
local NorGate = require('gate').NorGate

-- SR latch

local s_nor = NorGate.new()
local r_nor = NorGate.new()

s_nor.C:connect(r_nor.B)
r_nor.C:connect(s_nor.A)

local S = s_nor.B
local R = r_nor.A
local Q = r_nor.C
local Q_ = s_nor.C

local Input = require('metal').Input
local H = require('logic').H
local L = require('logic').L

local q_checker = {}
q_checker.input = Input.new(q_checker)
q_checker.reset = function(self) self.input.signal = nil end
q_checker.update = function() return {} end
local q_inv_checker = {}
q_inv_checker.input = Input.new(q_inv_checker)
q_inv_checker.reset = function(self) self.input.signal = nil end
q_inv_checker.update = function() return {} end

Q:connect(q_checker.input)
Q_:connect(q_inv_checker.input)

components = {
  [s_nor] = true,
  [r_nor] = true,
}

S.signal = L
R.signal = L
update_all(components)
assert(q_checker.input.signal == L)
assert(q_inv_checker.input.signal == H)

S.signal = H
R.signal = L
update_all(components)
assert(q_checker.input.signal == H)
assert(q_inv_checker.input.signal == L)

S.signal = L
R.signal = L
update_all(components)
assert(q_checker.input.signal == H)
assert(q_inv_checker.input.signal == L)

S.signal = L
R.signal = H
update_all(components)
assert(q_checker.input.signal == L)
assert(q_inv_checker.input.signal == H)

S.signal = L
R.signal = L
update_all(components)
assert(q_checker.input.signal == L)
assert(q_inv_checker.input.signal == H)


io.write('PASSED')
