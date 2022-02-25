local function update_all(components_to_update)
  local start = os.clock()
  --[[
  print('components to update')
  for component in pairs(components_to_update) do print(component) end
  print('---')
  --]]
  local iteration = 1
  repeat
    --[[
    print('iteration', iteration)
    --]]
    local next_components = {}
    for component in pairs(components_to_update) do
      --[[
      print(component)
      --]]
      local components = component:update()
      for component in pairs(components) do
        next_components[component] = true
      end
    end
    components_to_update = next_components
    --[[
    print('next components to update')
    for component in pairs(components_to_update) do print(component) end
    print('---')
    --]]
    iteration = iteration + 1
  until not next(components_to_update)
  local end_t = os.clock()
  print(string.format('took %d iterations and %f seconds', iteration, end_t - start))
end

return update_all

