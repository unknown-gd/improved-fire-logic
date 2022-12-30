--[[

    Title:Finally a normal fire behavior!
    Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=2805142659
    GitHub: https://github.com/PrikolMen/gmod_fire_extinguishing
    Author: https://steamcommunity.com/id/PrikolMen/

--]]

local addon_name = 'Finally a normal fire behavior!'

do

    local ENTITY = FindMetaTable( 'Entity' )

    do

        local combustible_materials = {
            [MAT_PLASTIC] = true,
            [MAT_WOOD] = true,
            [MAT_FOLIAGE] = true,
            [MAT_GRASS] = true,
            [MAT_FLESH] = true,
            [MAT_BLOODYFLESH] = true,
            [MAT_ALIENFLESH] = true,
            [MAT_ANTLION] = true,
            -- Strange fact, but all sofas are made of earth :|
            [MAT_DIRT] = true
        }

        function ENTITY:IsFlammable()
           -- Is Alive?
           if self:IsNPC() then return true end
           if self:IsPlayer() and self:Alive() then return true end

           -- Is Flammable?
           return combustible_materials[ self:GetMaterialType() ] or false
        end

    end

    function ENTITY:CanIgnite()
        if self:IsOnFire() then return false end
        if (self:WaterLevel() > 0) then return false end
        return self:IsFlammable()
    end

    -- Ugh, I think this is a protection from overwriting...
    timer.Simple(0, function()

        -- New Ignite
        if (ENTITY.SourceIgnite == nil) then
            ENTITY.SourceIgnite = ENTITY.Ignite
        end

        function ENTITY:Ignite( ... )
            if self:CanIgnite() then
                return self:SourceIgnite( ... )
            end
        end

        -- New Extinguish
        if (ENTITY.SourceExtinguish == nil) then
            ENTITY.SourceExtinguish = ENTITY.Extinguish
        end

        do

            local extinguish_snd = CreateConVar( 'extinguish_sound', '1', FCVAR_ARCHIVE + FCVAR_LUA_SERVER, ' - Enable entites extinguishing sound', 0, 1 ):GetBool()
            cvars.AddChangeCallback('extinguish_sound', function( name, old, new )
                extinguish_snd = new == '1'
            end, addon_name)

            local sound_path = 'player/flame_out.ogg'
            local math_random = math.random
            local CHAN_ITEM = CHAN_ITEM

            function ENTITY:Extinguish()
                if self:IsOnFire() and extinguish_snd then
                    self:EmitSound( sound_path, math_random( 55, 65 ), math_random( 60, 180 ), 1, CHAN_ITEM )
                end

                return self:SourceExtinguish()
            end
        end

    end)

end

do

    local bit_band = bit.band
    local hook_Run = hook.Run
    local DMG_BURN = DMG_BURN

    hook.Add('EntityTakeDamage', addon_name, function( ent, dmg )
        if (bit_band( dmg:GetDamageType(), DMG_BURN ) == DMG_BURN) and ent:IsFlammable() and ent:IsOnFire() then
            return hook_Run( 'EntityBurns', ent, dmg )
        end
    end)

end

hook.Add('EntityBurns', 'Extinguish in Water', function( ent )
    if (ent:WaterLevel() > 0) then
        ent:Extinguish()
        return true
    end
end)

MsgN( '[' .. addon_name .. '] I\'m ready!' )
timer.Simple(0, function()
    if (vFireMessage ~= nil) then
        MsgN( '[' .. addon_name .. '] Oh, hello vFire!' )
        vFireMessage( 'Hello, ' .. addon_name )
    end
end)