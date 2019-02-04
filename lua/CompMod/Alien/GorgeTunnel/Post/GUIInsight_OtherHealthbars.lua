local kOtherTypes = CompMod:GetLocalVariable(GUIInsight_OtherHealthbars.Update, "kOtherTypes")
table.insert(kOtherTypes, "TunnelExit")
ReplaceLocals(GUIInsight_OtherHealthbars.Update, {kOtherTypes = kOtherTypes})
