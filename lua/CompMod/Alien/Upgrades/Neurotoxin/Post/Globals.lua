-- this has to be set just after the enum is initialised
-- otherwise weird things happen

CompMod:AppendToEnum(kDeathMessageIcon, "Neurotoxin")

-- i'm not 100% sure this is even needed. oops it was
Textures.kInventoryIcons = PrecacheAsset("ui/compmod_inventory_icons.dds")
kInventoryIconsTexture = Textures.kInventoryIcons
