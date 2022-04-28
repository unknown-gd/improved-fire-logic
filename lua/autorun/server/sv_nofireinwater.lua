hook.Add("OnEntityWaterLevelChanged", "No Fire In Water", function( ent, old, new )
    if (new > 1) and ent:IsOnFire() then
        ent:Extinguish()
    end
end)

local combustible_materials = {
    [MAT_PLASTIC] = true,
    [MAT_WOOD] = true,
    [MAT_FOLIAGE] = true,
    [MAT_GRASS] = true,
    [MAT_FLESH] = true,
    [MAT_BLOODYFLESH] = true,
    [MAT_ALIENFLESH] = true,
    [MAT_ANTLION] = true,
    [MAT_DIRT] = true
}

do

    local ENTITY = FindMetaTable( "Entity" )

    if (ENTITY.SourceIgnite == nil) then
        ENTITY.SourceIgnite = ENTITY.Ignite
    end

    function ENTITY:Ignite( ... )
        if (combustible_materials[ self:GetMaterialType() ] == nil) then return end
        if (self:WaterLevel() > 0) then return end
        if self:IsOnFire() then return end

        return self:SourceIgnite( ... )
    end

    if (ENTITY.SourceExtinguish == nil) then
        ENTITY.SourceExtinguish = ENTITY.Extinguish
    end

    do
        local sound_path = "player/flame_out.ogg"
        local math_random = math.random
        local CHAN_ITEM = CHAN_ITEM

        function ENTITY:Extinguish()
            self:EmitSound( sound_path, math_random( 55, 65 ), math_random( 60, 180 ), 1, CHAN_ITEM )
            return self:SourceExtinguish()
        end
    end

end

do

    local DMG_BURN = DMG_BURN
    local bit_band = bit.band

    hook.Add("EntityTakeDamage", "No Fire In Water", function( ent, dmg )
        if (bit_band( dmg:GetDamageType(), DMG_BURN ) == DMG_BURN) then
            if (combustible_materials[ ent:GetMaterialType() ] == nil) or (ent:WaterLevel() > 1) then
                if ent:IsOnFire() then
                    ent:Extinguish()
                end

                return true
            end
        end
    end)

end