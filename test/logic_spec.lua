describe('a High-state signal', function()
  local logic = require('logic')
  local H = logic.H
  local L = logic.L

  it('shows itself in meaningful way', function()
    assert.equals('1', tostring(H))
  end)

  describe('returns correct signal when', function()

    it('negated', function()
      assert.equals(L, ~H)
    end)

    it('ORed with another', function()
      local other_signals = {H, L}
      for _, signal in ipairs(other_signals) do
        assert.equals(H, H | signal)
      end
    end)

    it('ANDed with another', function()
      local other_signals = {H, L}
      for _, signal in ipairs(other_signals) do
        assert.equals(signal, H & signal)
      end
    end)

    it('XORed with another', function()
      local other_signals = {H, L}
      for _, signal in ipairs(other_signals) do
        assert.equals(~signal, H ~ signal)
      end
    end)
  end)
end)

describe('a Low-state signal', function()
  local logic = require('logic')
  local H = logic.H
  local L = logic.L

  it('shows itself in meaningful way', function()
    assert.equals('0', tostring(L))
  end)

  describe('returns correct signal when', function()

    it('negated', function()
      assert.equals(H, ~L)
    end)

    it('ORed with another', function()
      local other_signals = {H, L}
      for _, signal in ipairs(other_signals) do
        assert.equals(signal, L | signal)
      end
    end)

    it('ANDed with another', function()
      local other_signals = {H, L}
      for _, signal in ipairs(other_signals) do
        assert.equals(L, L & signal)
      end
    end)

    it('XORed with another', function()
      local other_signals = {H, L}
      for _, signal in ipairs(other_signals) do
        assert.equals(signal, L ~ signal)
      end
    end)
  end)
end)
