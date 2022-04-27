do
    local ENTITY = FindMetaTable( "Entity" )

    if (ENTITY.SourceIgnite == nil) then
        ENTITY.SourceIgnite = ENTITY.Ignite
    end

    function ENTITY:Ignite( ... )
        if (self:WaterLevel() > 0) then
            return
        end

        return self:SourceIgnite( ... )
    end
end

hook.Add("OnEntityWaterLevelChanged", "No Fire In Water", function( ent, old, new )
    if (new > 1) and ent:IsOnFire() then
        ent:Extinguish()
    end
end)