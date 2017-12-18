function ProfileSelected()
	return (PROFILEMAN:GetProfile(PLAYER_1) and PROFILEMAN:GetProfile(PLAYER_1):GetDisplayName()~="")
end

function ChangeScreen(screen)
	if SCREENMAN and SCREENMAN:GetTopScreen() and SCREENMAN:GetTopScreen():GetName() ~= screen then
		SCREENMAN:GetTopScreen():SetNextScreenName(screen):StartTransitioningScreen("SM_GoToNextScreen") 
	end
end