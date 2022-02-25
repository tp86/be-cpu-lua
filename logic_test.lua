local logic = require('logic')
local H = logic.H
local L = logic.L

assert(tostring(H) == '1')
assert(tostring(L) == '0')

assert(H & H == H)
assert(H & L == L)
assert(H | H == H)
assert(H | L == H)
assert(H ~ L == H)
assert(H ~ H == L)
assert(~H == L)

assert(L & H == L)
assert(L & L == L)
assert(L | H == H)
assert(L | L == L)
assert(L ~ L == L)
assert(L ~ H == H)
assert(~L == H)

assert(L & H | H == H)
assert(~~H == H)


io.write('PASSED')
