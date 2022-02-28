--[[
local Input = require('metal').Input
local Output = require('metal').Output
local L = require('logic').L

local Gate = {}
Gate.__index = Gate

function Gate.new(n_inputs, fn)
  local new = {}
  new.update_fn = fn
  new.inputs = {}
  for i = 1, n_inputs do
    new.inputs[i] = Input.new(new)
  end
  new.output = Output.new()
  return setmetatable(new, Gate)
end

function Gate:update()
  local signals = {}
  for i, input in ipairs(self.inputs) do
    signals[i] = input.signal or L -- assume initial state is Low
  end
  local signal = self.update_fn(table.unpack(signals))
  return self.output:propagate(signal)
end

local function make_2_inputs_gate(fn)
  local new = Gate.new(2, fn)
  new.A = new.inputs[1]
  new.B = new.inputs[2]
  new.C = new.output
  return new
end

local And = {}
function And.new()
  return make_2_inputs_gate(function(a, b) return a & b end)
end

local Or = {}
function Or.new()
  return make_2_inputs_gate(function(a, b) return a | b end)
end

local Not = {}
function Not.new()
  local new = Gate.new(1, function(a) return ~a end)
  new.A = new.inputs[1]
  new.B = new.output
  return new
end

local Nand = {}
function Nand.new()
  -- could also be combination of And and Not gates, but it would take 2 update cycles instead of 1
  return make_2_inputs_gate(function(a, b) return ~(a & b) end)
end

local Nor = {}
function Nor.new()
  -- see comment for Nand
  return make_2_inputs_gate(function(a, b) return ~(a | b) end)
end

local Xor = {}
function Xor.new()
  return make_2_inputs_gate(function(a, b) return a ~ b end)
end

local Nxor = {}
function Nxor.new()
  -- see comment for Nand
  return make_2_inputs_gate(function(a, b) return ~(a ~ b) end)
end

support = {}

local Printer = {}
Printer.__index = Printer

function Printer.new(label)
  local new = {}
  new.label = label or 'Printer'
  new.input = Input.new(new)
  return setmetatable(new, Printer)
end

function Printer:update()
  local signal = self.input.signal
  io.write(string.format('%10.10s: %s\n', self.label, signal))
  return {}
end

local Broadcast = {}
Broadcast.__index = Broadcast

function Broadcast.new()
  local new = {}
  new.input = Input.new(new)
  new.output = Output.new()
  return setmetatable(new, Broadcast)
end

function Broadcast:update()
  return self.output:propagate(self.input.signal)
end

support.Printer = Printer
support.Broadcast = Broadcast

return {
  NotGate = Not,
  AndGate = And,
  OrGate = Or,
  NandGate = Nand,
  NorGate = Nor,
  XorGate = Xor,
  NxorGate = Nxor,
  support = support,
}
--]]

local Gate = {}
function Gate:new(n_inputs, has_output)
  local new = {}
  new.inputs = {}
  for i = 1, n_inputs do
    new.inputs[i] = {}
  end
  if has_output == nil or has_output then
    new.output = {}
  end
  self.__index =  self
  return setmetatable(new, self)
end

return {
  Gate = Gate,
}
