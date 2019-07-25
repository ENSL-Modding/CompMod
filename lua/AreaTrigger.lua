
class 'AreaTrigger' (Trigger)

AreaTrigger.kMapName = 'area_trigger'

gAreaTriggers = gAreaTriggers or {}

local networkVars = 
{
    name = "string (256)"
}

function AreaTrigger:OnCreate()
    
    Trigger.OnCreate(self)
    
    self.enabled = false
    self.filter_func = nil
    self.callback_func = nil
    self.repeatable = nil
    
    self.exit_enabled = false
    self.exit_filter_func = nil
    self.exit_callback_func = nil
    self.exit_repeatable = nil
end

function AreaTrigger:OnInitialized()
    
    Trigger.OnInitialized(self)
    self:SetTriggerCollisionEnabled(true)
    self:SetUpdates(false)
    
    if Server then
        if gAreaTriggers[self.name] ~= nil then
            Log("Warning!  Found area_trigger with duplicate name!  Skipping...")
            return
        end
        
        gAreaTriggers[self.name] = self
    end
    
end

if Server then
    
    local function isEligible(self, enterEnt)
        if self.enabled ~= true then
            return false
        end
        
        if self.callback_func == nil then
            return false --no point if there's nothing for the trigger to trigger!
        end
        
        if self.filter_func == nil or self.filter_func(enterEnt) == true then
            return true
        end
        
        return false
    end
    
    local function isEligibleExit(self, exitEnt)
        if self.exit_enabled ~= true then
            return false
        end
        
        if self.exit_callback_func == nil then
            return false --no point if there's nothing for the trigger to trigger!
        end
        
        if self.exit_filter_func == nil or self.exit_filter_func(exitEnt) == true then
            return true
        end
        
        return false
    end
    
    function AreaTrigger:OnTriggerEntered(enterEnt, triggerEnt)
        if isEligible(self, enterEnt) then
            local temp_callback = self.callback_func
            
            if not self.repeatable then
                self.enabled = false
                self.filter_func = nil
                self.callback_func = nil
                self.repeatable = nil
            end
            
            temp_callback(enterEnt)
        end
    end
    
    function AreaTrigger:OnTriggerExited(exitEnt, triggerEnt)
        if isEligibleExit(self, exitEnt) then
            local temp_callback = self.exit_callback_func
            
            if not self.exit_repeatable then
                self.exit_enabled = false
                self.exit_filter_func = nil
                self.exit_callback_func = nil
                self.exit_repeatable = nil
            end
            
            temp_callback(exitEnt)
        end
    end
    
    function DeactivateAreaTrigger(areaTriggerName)
        
        local trigger = gAreaTriggers[areaTriggerName]
        if trigger == nil then
            Log("No area trigger named '%s' was found!  Cannot deactivate.", areaTriggerName)
            return
        end
        
        trigger.enabled = false
        trigger.filter_func = nil
        trigger.callback_func = nil
        
    end
    
    function DeactivateAreaTriggerExit(areaTriggerName)
        
        local trigger = gAreaTriggers[areaTriggerName]
        if trigger == nil then
            Log("No area trigger named '%s' was found!  Cannot deactivate.", areaTriggerName)
            return
        end
        
        trigger.exit_enabled = false
        trigger.exit_filter_func = nil
        trigger.exit_callback_func = nil
    end
    
    function ActivateAreaTrigger(areaTriggerName, callback_function, filter_function, repeatable)
        
        local trigger = gAreaTriggers[areaTriggerName]
        if trigger == nil then
            Log("No area trigger named '%s' was found!  Cannot activate.", areaTriggerName)
            return
        end
        
        trigger.enabled = true
        trigger.filter_func = filter_function
        trigger.callback_func = callback_function
        trigger.repeatable = repeatable
        
        if trigger.callback_func == nil then
            Log("Trigger activated without a callback function!  Deactivating.")
            trigger.enabled = false
            trigger.filter_func = nil
            trigger.callback_func = nil
            trigger.repeatable = nil
        end
    end
    
    function ActivateAreaTriggerExit(areaTriggerName, callback_function, filter_function, repeatable)
        
        local trigger = gAreaTriggers[areaTriggerName]
        if trigger == nil then
            Log("No area trigger names '%s' was found!  Cannot activate.", areaTriggerName)
            return
        end
        
        trigger.exit_enabled = true
        trigger.exit_filter_func = filter_function
        trigger.exit_callback_func = callback_function
        trigger.exit_repeatable = repeatable
        
        if trigger.exit_callback_func == nil then
            Log("Trigger activated without a callback function!  Deactivating.")
            trigger.exit_enabled = false
            trigger.exit_filter_func = nil
            trigger.exit_callback_func = nil
            trigger.exit_repeatable = nil
        end
    end
    
end

Shared.LinkClassToMap("AreaTrigger", AreaTrigger.kMapName, networkVars)