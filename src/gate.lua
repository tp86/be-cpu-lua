local extend = require('oop').extend
local connection = require('connection')
local Output = connection.Output
local Input = connection.Input
local do_nil = function() end

local Updatable = {
  prepare_update_args = do_nil,
  update_fn = do_nil,
  process_update_results = do_nil,
  update = function(self)
    local args = table.pack(self:prepare_update_args())
    local results = table.pack(self.update_fn(table.unpack(args)))
    return self:process_update_results(table.unpack(results))
  end,
}

local Source = extend(Updatable, {
  init = function(obj)
    obj.output = extend(Output)()
  end,
  process_update_results = function(self, signal)
    return self.output:propagate(signal)
  end,
})()

local Sink = extend(Updatable, {
  init = function(obj, n_inputs)
    local n_inputs = n_inputs or 1
    obj.inputs = {}
    for i = 1, n_inputs do
      obj.inputs[i] = extend(Input)(obj)
    end
  end,
  prepare_update_args = function(self)
    local signals = {}
    for i, input in ipairs(self.inputs) do
      signals[i] = input.signal
    end
    return table.unpack(signals)
  end,
  process_update_results = function(self)
    return {}
  end,
})()

local Gate = {
  init = function(obj, n_inputs)
    extend(Source, obj)()
    extend(Sink, obj)(n_inputs)
  end,
  prepare_update_args = Sink.prepare_update_args,
}

local Not = extend(Gate, {
  init = function(obj)
    obj.A = obj.inputs[1]
    obj.B = obj.output
  end,
  update_fn = function(s) return ~s end,
})()

local Gate2 = extend(Gate, {
  init = function(obj)
    obj.A = obj.inputs[1]
    obj.B = obj.inputs[2]
    obj.C = obj.output
  end,
})(2)

local And = extend(Gate2, {update_fn = function(a, b) return a & b end})()

local Nand = extend(Gate2, {update_fn = function(a, b) return ~(a & b) end})()

local Or = extend(Gate2, {update_fn = function(a, b) return a | b end})()

local Nor = extend(Gate2, {update_fn = function(a, b) return ~(a | b) end})()

local Xor = extend(Gate2, {update_fn = function(a, b) return a ~ b end})()

local Nxor = extend(Gate2, {update_fn = function(a, b) return ~(a ~ b) end})()

--[[
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
--]]

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
  --[[
  support = {
    Broadcast = Broadcast,
    Probe = Probe,
    Printer = Printer,
    Flipper = Flipper,
    Constant = Constant,
  },
  --]]
}
