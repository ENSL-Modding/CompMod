--[[
    The scoreboard is currently noticeably slow to open when you press the key.
    This is because we are waiting for the next update time (which can be anywhere from 0-0.2 seconds from the time of
    press).

    Since the GUI runs at full speed when it's visible just force an update by setting the next update time to now.
]]

local oldSendKeyEvent = GUIScoreboard.SendKeyEvent

function GUIScoreboard:SendKeyEvent(key, down)
    oldSendKeyEvent(self, key, down)

    if GetIsBinding(key, "Scoreboard") then
        if self.visible then
            -- force an update when the key is pressed
            self.nextUpdateTime = Shared.GetTime()
            self.updateInterval = 0
        end
    end
end