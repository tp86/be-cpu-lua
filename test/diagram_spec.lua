local extend = require('oop').extend

describe('a SignalRenderer', function()
  package.loaded.diagram = {}
  local SignalRenderer = require('diagram').SignalRenderer
  local renderer

  before_each(function()
    renderer = extend(SignalRenderer)()
  end)

  pending('produces string containing two lines given list of signals', function()
    local output = renderer:render({})
    local _, newline_chars = string.gsub(output, '\n', '%1')
    assert.equals(1, newline_chars)
  end)
end)
