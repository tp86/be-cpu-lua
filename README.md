# be-cpu
Attempt to create [Ben Eater's CPU](https://eater.net/8bit/)

## Dependencies
- Lua 5.4
- Luarocks (3.8.0+)
- busted (2.0.0) [dev]

## WoW
- Automation scripts are written in Lua and stored in `scripts` directory
- `;src/?.lua;src/?/init.lua` is appended to `package.path`

## Glossary
- `Gate` - has (0, 1 or many) Inputs and (0 or 1) Output and implements some 
  function over inputs' values which return value is propagated through output.
  Example: And logical gate.
- `Component` - is a set of connected Gates that implement some more complex
  behavior. Example: SR latch.
