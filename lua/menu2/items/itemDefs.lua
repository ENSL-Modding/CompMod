-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/items/itemDefs.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Definitions of all items available to be awarded to the player.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

kItemDefs =
{
    [701] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_701_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_701_DESC"),
        icon = PrecacheAsset("ui/item_stickyshoe.dds"),
    },
    
    [702] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_702_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_702_DESC"),
        icon = PrecacheAsset("ui/item_skulktooth.dds"),
    },
    
    [703] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_703_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_703_DESC"),
        icon = PrecacheAsset("ui/item_auroraticket.dds"),
    },
    
    [704] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_704_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_704_DESC"),
        icon = PrecacheAsset("ui/item_callusclog.dds"),
    },
    
    [705] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_705_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_705_DESC"),
        icon = PrecacheAsset("ui/item_skulkfoot.dds"),
    },
    
    [706] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_706_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_706_DESC"),
        icon = PrecacheAsset("ui/item_hovars.dds"),
    },
    
    [707] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_707_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_707_DESC"),
        icon = PrecacheAsset("ui/item_flayrafiber.dds"),
    },
    
    [708] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_708_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_708_DESC"),
        icon = PrecacheAsset("ui/item_skulkhead.dds"),
    },
    
    [709] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_709_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_709_DESC"),
        icon = PrecacheAsset("ui/item_gorgehead.dds"),
    },
    
    [710] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_710_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_710_DESC"),
        icon = PrecacheAsset("ui/item_lerkhead.dds"),
    },
    
    [711] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_711_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_711_DESC"),
        icon = PrecacheAsset("ui/item_fadehead.dds"),
    },
    
    [712] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_712_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_712_DESC"),
        icon = PrecacheAsset("ui/item_onoshead.dds"),
    },
    
    [713] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_713_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_713_DESC"),
        icon = PrecacheAsset("ui/item_tsfpen.dds"),
    },
    
    [714] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_714_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_714_DESC"),
        icon = PrecacheAsset("ui/item_babblerweight.dds"),
    },
    
    [715] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("STICKY_SHOE_715_TITLE")),
        message = Locale.ResolveString("STICKY_SHOE_715_DESC"),
        icon = PrecacheAsset("ui/item_vial.dds"),
    },
    
    [907] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("ITEM_PUMPKIN_PATCH_TITLE")),
        message = Locale.ResolveString("ITEM_PUMPKIN_PATCH_DESC"),
        icon = PrecacheAsset("ui/item_pumpkinpatch.dds"),
    },
    
    [906] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("ITEM_EAT_YOUR_GREENS_TITLE")),
        message = Locale.ResolveString("ITEM_EAT_YOUR_GREENS_DESC"),
        icon = PrecacheAsset("ui/item_green_blood.dds"),
    },
    
    [910] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("ITEM_SUMMER_GORGE_TITLE")),
        message = Locale.ResolveString("ITEM_SUMMER_GORGE_DESC"),
        icon = PrecacheAsset("ui/item_summergorge.dds"),
    },
    
    [911] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("ITEM_HAUNTED_BABBLER_TITLE")),
        message = Locale.ResolveString("ITEM_HAUNTED_BABBLER_DESC"),
        icon = PrecacheAsset("ui/item_hauntedbabbler.dds"),
    },
    
    [10001] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("ITEM_UNEARTHED_STRUCTURE_SKINS_TITLE")),
        message = Locale.ResolveString("ITEM_UNEARTHED_STRUCTURE_SKINS_DESC"),
        icon = PrecacheAsset("ui/item_unearthedskin.dds"),
    },

    [kAbyssSkulkItemId] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("ITEM_ABYSS_SKULK_TITLE")),
        message = Locale.ResolveString("ITEM_ABYSS_SKULK_DESC"),
        icon = PrecacheAsset("ui/item_abyssskulk.dds"),
    },

    [kAbyssGorgeItemId] =
    {
        title = string.format(Locale.ResolveString("NEW_ITEM"), Locale.ResolveString("ITEM_ABYSS_GORGE_TITLE")),
        message = Locale.ResolveString("ITEM_ABYSS_GORGE_DESC"),
        icon = PrecacheAsset("ui/item_abyssgorge.dds"),
    },
    
}
