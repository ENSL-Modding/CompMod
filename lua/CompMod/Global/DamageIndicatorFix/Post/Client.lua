function Client.AddWorldMessage(messageType, message, position, entityId)

    -- Only add damage messages if we have it enabled and if the entity is valid
    if messageType ~= kWorldTextMessageType.Damage or Client.GetOptionBoolean( "drawDamage", false ) then

        -- If we already have a message for this entity id, update existing message instead of adding new one
        local time = Client.GetTime()

        local updatedExisting = false

        if messageType == kWorldTextMessageType.Damage then

            for _, currentWorldMessage in ipairs(Client.worldMessages) do

                if currentWorldMessage.messageType == messageType and currentWorldMessage.entityId == entityId and entityId ~= nil and entityId ~= Entity.invalidId then

                    currentWorldMessage.creationTime = time
                    currentWorldMessage.position = position
                    currentWorldMessage.previousNumber = tonumber(currentWorldMessage.message)
                    currentWorldMessage.message = currentWorldMessage.message + message
                    currentWorldMessage.minimumAnimationFraction = kWorldDamageRepeatAnimationScalar

                    updatedExisting = true
                    break

                end

            end

        end

        if not updatedExisting and (messageType ~= kWorldTextMessageType.Damage or (messageType == kWorldTextMessageType.Damage and entityId ~= nil and entityId ~= Entity.invalidId)) then
            -- vanilla doesnt check if the entity is valid here for dmg numbers.
            -- i dont see a reason why they dont
            local worldMessage = {}

            worldMessage.messageType = messageType
            worldMessage.message = message
            worldMessage.position = position
            worldMessage.creationTime = time
            worldMessage.entityId = entityId
            worldMessage.animationFraction = 0
            worldMessage.lifeTime = ConditionalValue(kWorldTextMessageType.CommanderError == messageType, kCommanderErrorMessageLifeTime, kWorldMessageLifeTime)

            if messageType == kWorldTextMessageType.CommanderError then

                local commander = Client.GetLocalPlayer()
                if commander then
                    commander:TriggerInvalidSound()
                end

            end

            table.insert(Client.worldMessages, worldMessage)

        end

    end

end
