# Improved Fire Logic & API
More correct behavior of fire, recognition of burning materials and other things. For developers, the addon has a pretty good API.
Basically fixes the ability to burn something that can not burn, also adds a sound of extinguishing entities, allows you to extinguish entities in the water.
Supports working with [vFire](https://steamcommunity.com/sharedfiles/filedetails/?id=1525218777) and other fire mods.
Works with any entites.

- Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=2805142659

## Developer API
### Hook called if entity takes a fire damage.
- [GM](https://wiki.facepunch.com/gmod/GM_Hooks):EntityBurns( [`Entity`](https://wiki.facepunch.com/gmod/Entity) ent, [`DamageInfo`](https://wiki.facepunch.com/gmod/Global.DamageInfo) dmg )

### Entity method for check flammable.
- [ENTITY](https://wiki.facepunch.com/gmod/Entity):IsFlammable()

### Entity method for check can ignite that entity.
- [ENTITY](https://wiki.facepunch.com/gmod/Entity):CanIgnite()

### Original Extinguish (Ignores all checks, can extinguish anything)
- [ENTITY](https://wiki.facepunch.com/gmod/Entity):SourceExtinguish()

### Extinguishes the essence if physically possible. 
- [ENTITY](https://wiki.facepunch.com/gmod/Entity):Extinguish()

### Original Ignite (Ignores all checks, can ignite anything)
- [ENTITY](https://wiki.facepunch.com/gmod/Entity):SourceIgnite()

### A smart ignite, can not set fire to something that can not burn.
- [ENTITY](https://wiki.facepunch.com/gmod/Entity):Ignite()
