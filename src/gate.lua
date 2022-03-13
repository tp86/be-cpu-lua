local extend = require('oop').extend
local connection = require('connection')
local Output = connection.Output
local Input = connection.Input
local L = require('signal').L
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

local Broadcast = extend(Gate, {
  init = function(obj)
    obj.input = obj.inputs[1]
  end,
  update_fn = function(signal) return signal end,
})(1)

local Probe = extend(Sink, {
  init = function(obj)
    obj.input = obj.inputs[1]
  end,
  prepare_update_args = function(self)
    local arg = Sink.prepare_update_args(self)
    self.value = arg
    return arg
  end,
})(1)

local Printer = extend(Probe, {
  init = function(obj, label)
    obj.label = label or 'Printer'
    obj.update_fn = function(signal)
      io.write(string.format('%8.8s: %s', obj.label, signal))
    end
  end,
})()

local SignalSource = extend(Source, {
  signal = 0,
  prepare_update_args = function(self)
    return self.signal
  end,
  update_fn = function(s) return s end,
})()

local Flipper = extend(SignalSource, {
  update_fn = function(s) return ~s end,
  process_update_results = function(self, s)
    self.signal = s
    return SignalSource.process_update_results(self, s)
  end,
  signal = L,
})()

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
    Constant = SignalSource,
  },
}
