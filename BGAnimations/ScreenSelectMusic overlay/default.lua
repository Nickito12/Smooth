local t = Def.ActorFrame{}

GAMESTATE:UpdateDiscordMenu(GetPlayerOrMachineProfile(PLAYER_1):GetDisplayName() .. ": " .. string.format("%5.2f", GetPlayerOrMachineProfile(PLAYER_1):GetPlayerRating()))

t[#t+1] = LoadActor("../_mainmenu")
return t
