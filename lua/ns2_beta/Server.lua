do
    if ModuleLoader then
        ModuleLoader:LoadAllModules("Server")

        Server.AddRestrictedFileHashes("lua/TBCD/modules/*.lua")
    end
end