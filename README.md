# UnitPlates
Nameplates for twow/octowow (or vanilla 1.12)

---
IMPORTANT:
seems like I have relied on some of the Ace libs hooked up by something else

will need some time to recheck relations and unhook the code from unintended external library usage

so the addon will not work if you don't have an addon that hiddenly hooks up some bs libraries
---

Continuation of https://github.com/Redbu11dev/ShaguPlates-extra (Complete rewrite based on kui nameplates, no more shaguplates dependencies, no kui dependencies either, no third party libraries, much better code, etc.)

REQUIRES SUPERWOW https://github.com/balakethelock/SuperWoW (and preferably UnitXP-SP3 https://codeberg.org/konaka/UnitXP_SP3/releases) 

(!) Rename folder to "UnitPlates" (!)

(!) I do not and do not plan to support non-english locales (!)

Configuration window - /up or /unitplates
- (NOTE: I do not wish to clutter the addon logic with many config options, I will only be keeping minimal amount of options)

TODO list:
- Did not bother with critter nameplates yet (just turn them off in UnitXP-SP3 for now, and it will be preferable mostly anyways)
- Did not test it in party/raid yet, will probably have to adjust for these cases
- Did not have time to test with pets, but should be working (if not, I will fix when I am able to)
- Add hunter pet happines indicator (only for your own pet, and only if not happy)
- Add threat display (at least minimal indication - 0/100 %)
- More range indicators - melee / throwing / shooting , maybe spells as well
- More buffs/debuffs (can only show as much as there are in local library, but the library is based on shaguplates - so at the very least no less than shaguplates can show)

Features:

- Power bars (mana, rage, energy) for nameplates
- NPC faction names (like "\<Argent Dawn\>" or "\<Trade goods\>") under their names
- NPC type icons
- Elite dragons on the sides
- Player race icons
- Player class icons
- "in combat" indicator on an NPC/player nameplate
- Totem icons
- Combo points
- Cast bar
- Buffs/Debuffs (auras)
- Shooting range indicator (works only if you have "Auto Shot" somewhere on the action bars)
- "Tapped" state indicator - when an NPC is tapped by another player (when the kill would not be yours - when you get no loot or xp for killing it)
- 
- pfquest integration (shows icons for quest mobs)
- MobHealth integration https://github.com/kc8pnd/MobHealth
- and more


![image](https://github.com/user-attachments/assets/365ef01f-8e43-4d26-8e99-15b2220c8d85)

