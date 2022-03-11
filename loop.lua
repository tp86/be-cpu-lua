local function update_all(components_to_update)
  repeat
    local next_components = {}
    for component in pairs(components_to_update) do
      local components = component:update()
      for component in pairs(components) do
        next_components[component] = true
      end
    end
    components_to_update = next_components
  until not next(components_to_update)
end

return update_all
