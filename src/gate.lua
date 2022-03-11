local extend = require('oop').extend
local Prototype = require('prototype')
local do_nil = function() end

local Updatable = Prototype:clone()
Updatable.prepare_update_args = do_nil
Updatable.update_fn = do_nil
Updatable.process_update_results = do_nil
function Updatable:configure(update_fn)
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

local Source = Updatable:clone()
function Source:configure(update_fn)
  Updatable.configure(self, update_fn)
  self.output = extend(Output)()
end
function Source:process_update_results(signal)
  return self.output:propagate(signal)
end

local Input = connection.Input

local Sink = Updatable:clone()
Sink.n_inputs = 1
function Sink:configure(update_fn, n_inputs)
  Updatable.configure(self, update_fn)
  if n_inputs then
    self.n_inputs = n_inputs
  end
  self.inputs = {}
  for i = 1, self.n_inputs do
    self.inputs[i] = extend(Input)(self)
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

local Gate = Source:clone()
Sink:prototype_of(Gate)
Gate.prepare_update_args = Sink.prepare_update_args
function Gate:configure(update_fn, n_inputs)
  Source.configure(self)
  Sink.configure(self, update_fn, n_inputs)
end

local Not = Gate:clone(function(s) return ~s end)
function Not:configure()
  Gate.configure(self, self.update_fn, self.n_inputs)
  self.A = self.inputs[1]
  self.B = self.output
end

local Gate2 = Gate:clone()
Gate2.n_inputs = 2
function Gate2:configure(update_fn)
  Gate.configure(self, update_fn)
  self.A = self.inputs[1]
  self.B = self.inputs[2]
  self.C = self.output
end

local And = Gate2:clone(function(a, b) return a & b end)

local Nand = Gate2:clone(function(a, b) return ~(a & b) end)

local Or = Gate2:clone(function(a, b) return a | b end)

local Nor = Gate2:clone(function(a, b) return ~(a | b) end)

local Xor = Gate2:clone(function(a, b) return a ~ b end)

local Nxor = Gate2:clone(function(a, b) return ~(a ~ b) end)

local Broadcast = Gate:clone(function(signal) return signal end)
Broadcast.n_inputs = 1
function Broadcast:configure()
  Gate.configure(self, self.update_fn, self.n_inputs)
  self.input = self.inputs[1]
end

local Probe = Sink:clone()
Probe.n_inputs = 1
Probe.prepare_update_args = function(self)
  local arg = Sink.prepare_update_args(self)
  self.value = arg
  return arg
end
function Probe:configure(update_fn)
  Sink.configure(self, update_fn)
  self.input = self.inputs[1]
end

local Printer = Probe:clone()
function Printer:configure(label)
  self.label = label or 'Printer'
  local callback = function(signal)
    io.write(string.format('%8.8s: %s', self.label, signal))
  end
  Probe.configure(self, callback)
end

local SignalSource = Source:clone()
function SignalSource:prepare_update_args()
  return self.signal
end
function SignalSource:configure(update_fn, init_signal)
  Source.configure(self, update_fn)
  self.signal = init_signal or 0
end
local Flipper = SignalSource:clone(function(s) return ~s end)
function Flipper:process_update_results(s)
  self.signal = s
  return Source.process_update_results(self, s)
end
local L = require('signal').L
function Flipper:configure(start_value)
  SignalSource.configure(self, self.update_fn)
  self.signal = ~(start_value or L)
end

local Constant = SignalSource:clone(function(s) return s end)
function Constant:configure(signal)
  SignalSource.configure(self, self.update_fn)
  self.signal = signal
end

return {
  Source = Source,
  Sink = Sink,
  Gate = Gate,
  Not = Not,
  And = And,
  Nand = Nand,
  Or = Or,
  Nor = Nor,
  Xor = Xor,
  Nxor = Nxor,
  support = {
    Broadcast = Broadcast,
    Probe = Probe,
    Printer = Printer,
    Flipper = Flipper,
    Constant = Constant,
  },
}
