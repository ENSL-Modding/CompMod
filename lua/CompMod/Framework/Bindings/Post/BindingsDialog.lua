function BindingsUI_UpdateBindingData(Mod)
  local globalControlBindings = Mod:GetLocalVariable(BindingsUI_GetBindingsData, "globalControlBindings")
  local bindingChanges = Mod:GetBindingAdditions()

  for _,v in ipairs(bindingChanges) do
    local afterName = v[5]

    Mod:PrintDebug("Adding new bind \"" .. v[1].. "\" after " .. afterName)

    v[3] = Locale.ResolveString(v[3])

    local index

    for i,v in ipairs(globalControlBindings) do
      if v == afterName then
        index = i + 4
      end
    end

    assert(index, "BindingChanges: Binding \"" .. afterName .. "\" does not exist.")

    for i=0,3 do
      table.insert(globalControlBindings, index + i, v[i + 1])
    end
  end

  CompMod:ReplaceLocal(BindingsUI_GetBindingsData, "globalControlBindings", globalControlBindings)
end
