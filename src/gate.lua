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
local parents = {}
local Base = {}
function Base:new(...)
  local new = {}
  parents[new] = {self}
  self.__index = function(_, field)
    for _, parent in ipairs(parents[new]) do
      local value = parent[field]
      if value ~= nil then return value end
    end
  end
  setmetatable(new, self)
  new:_init(...)
  return new
end
function Base:_init()
end
function Base:super(level, sibling)
  local level = level or 1
  local sibling = sibling or 1
  local super = self
  for i = 1, level - 1 do
    super = getmetatable(super)
  end
  return parents[super][sibling]
end
function Base:add_parent(parent)
  local ps = parents[self]
  ps[#ps + 1] = parent
end

local Updatable = Base:new()
Updatable.prepare_update_args = function() end
Updatable.update_fn = function() end
Updatable.process_update_results = function() end
function Updatable:_init(update_fn)
  if update_fn then
    self.update_fn = update_fn
  end
end
function Updatable:update(...)
  local args = table.pack(self:prepare_update_args())
  local results = table.pack(self.update_fn(table.unpack(args)))
  return self:process_update_results(table.unpack(results))
end

local connection = require('connection')
local Output = connection.Output

local Source = Updatable:new()
function Source:_init(update_fn)
  Source:super()._init(self, update_fn)
  self.output = Output:new()
end
function Source:process_update_results(signal)
  return self.output:propagate(signal)
end

local Input = connection.Input

local Sink = Updatable:new()
function Sink:_init(update_fn, n_inputs)
  Sink:super()._init(self, update_fn)
  local n_inputs = n_inputs or 1
  self.inputs = {}
  for i = 1, n_inputs do 
    self.inputs[i] = Input:new(self)
  end
end
function Sink:prepare_update_args()
  local signals = {}
  for i, input in ipairs(self.inputs) do
    signals[i] = input.signal
  end
  return table.unpack(signals)
end
function Sink:process_update_results()
  return {}
end

local Gate = Source:new()
Gate:add_parent(Sink)
-- needed because of multiple inheritance method resolution
Gate.prepare_update_args = Sink.prepare_update_args
function Gate:_init(update_fn, n_inputs)
  Gate:super()._init(self) -- Source
  Gate:super(1, 2)._init(self, update_fn, n_inputs) -- Sink
end

local Not = Gate:new(function(s) return ~s end)
function Not:_init()
  self.A = self.inputs[1]
  self.B = self.output
end

return {
  Source = Source,
  Sink = Sink,
  Gate = Gate,
  Not = Not,
}
