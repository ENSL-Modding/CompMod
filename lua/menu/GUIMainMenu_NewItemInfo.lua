-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenu_NewItemInfo.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

kNewItemInfoDefs =
{
    [701]={"Sticky Shoe","Take a little bit of the battle with you, regardless of if you wanted it or not.","stickyshoe"},
    [702]={"Skulk Tooth Necklace","Taken from combat, perfected in the barracks. The sign of a true warrior is in the trophies they forge from warfare. Carry into battle to inspire victory.","skulktooth"},
    [703]={"1 Ticket for the Aurora","Need shore-leave? This ticket will give passage on the next Alterra mining mission to exotic worlds. Don't forget to pack your bathing suit!","auroraticket"},
    [704]={"Callus Clog","For when you just need to rest your limbs, this hardened Clog is perfect to put the claws or feet upon.","callusclog"},
    [705]={"Urpa's Lucky Skulk Foot","When you need extra inspiration during the fight, clasp the Lucky Skulk Foot tight.","skulkfoot"},
    [706]={"Hovars without Flapping","The Battle of Sanji as told by those who made it back in pieces.","hovars"},
    [707]={"Flayra's Fiber","Start your day with the original TSF Commander's best. Great for mind and body.","flayrafiber"},
    [708]={"Hank's Mounted Head","He clawed, he chewed, he bit the bullet. The rest of him is in our gullet.","skulkhead"},
    [709]={"Phil's Mounted Head","Building up was always fun, until Phil tried to fight and run.","gorgehead"},
    [710]={"Dave's Mounted Head","Flapping all day kept the TSF at bay. Until jetpacks and shotguns cleared and made way.","lerkhead"},
    [711]={"Sally's Mounted Head","She Blinked and the marines did scatter, the mines they left caused her to splatter","fadehead"},
    [712]={"Jen's Mounted Head","Goring all day, Goring all night, Jen succumbed to the marine flashlight.","onoshead"},
    [713]={"TSF Promotional Pen","They say the pen is mightier than the sword. WARNING: DO NOT USE AS SWORD.","tsfpen"},
    [714]={"Calcified Babbler Egg","For use on TSF Priority Paper-related missions.","babblerweight"},
    [715]={"Vial of Kharaa Bacteria","For use against your worst enemy. Or simply as a fancy desk ornament.","vial"},
    [601]={"The Abyss Skulk", "Caged in the coldest corners of the facility, the Abyss Skulk stalks its prey. Be afraid, as you might be its next dessert.","abyssskulk"},
	[907]={"The Pumpkin Patch","When the wind is chilled and the moon is bright, the Pumpkin Patch will stir up a fright.","pumpkinpatch"},
	[906]={"Eat your Greens Shoulder Patch","Getting your toes wet, a shoulder decal is what you get!","green_blood"},
	[910]={"Summer Gorge Patch","Taking a break from the hot sun.","summergorge"},
    [911]={"Haunted Babbler Patch","When the wind is chilled and the moon is bright, the Haunted Babbler will stir up a fright.","hauntedbabbler"},
    [10001]={"Unearthed Structure Skins","A new form of Kharaa has revealed itself in the crystal mines of Unearthed. Mesmerize both friend and foe with these alien structure skins.","unearthedskin"},
}

class 'GUINewItemInfo' (Window)

function GUINewItemInfo:Initialize()
	Window.Initialize(self)

	self:SetWindowName("New Item Received!")
	self:SetInitialVisible(true)
	self:DisableResizeTile()
	self:DisableSlideBar()
	self:DisableTitleBar()
	self:DisableContentBox()
	self:DisableCloseButton()
	self:SetLayer(kGUILayerMainMenuDialogs)

	self.icon = CreateMenuElement(self, "Image")

	self.title = CreateMenuElement(self, "Font")
    self.title:SetText(Locale.ResolveString("ALERT"))
	self.title:SetCSSClass("title")

	self.description = CreateMenuElement(self, "Font")
	self.description:SetCSSClass("description")

	self.okButton = CreateMenuElement(self, "MenuButton")
	self.okButton:SetText(Locale.ResolveString("OK"))
	self.okButton:AddEventCallbacks({ OnClick = function()
		self:SetIsVisible(false)
	end})

    self:AddEventCallbacks(
        {OnHidePost = function()
            local gMenu = GetGUIMainMenu()
            if gMenu then gMenu:MaybeOpenPopup() end
        end})
end

function GUINewItemInfo:Setup(data)
	self.icon:SetBackgroundTexture(data.icon)

	self.title:SetText(string.format("New Item: %s", data.title))
	self.description:SetText(data.description)
end

function GUINewItemInfo:SetupWithId( id )
    MenuMenu_PlayMusic("sound/NS2.fev/marine/commander/res_received")

    local item = kNewItemInfoDefs[id] or { id, "Got a new item!", "stickyshoe" }
    
    self.icon:SetBackgroundTexture( "ui/item_"..item[3]..".dds" )
    self.title:SetText(string.format("New Item: %s", item[1]))
    
    local desc_wrap = WordWrap( self.title.text, item[2], 0, 500 )
    self.description:SetText( desc_wrap )
    
end

function GUINewItemInfo:OnEscape()
	self:SetIsVisible(false)
end


function GUINewItemInfo:GetTagName()
	return "newiteminfo"
end