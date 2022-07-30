AddEventHandler('esx_society:openBossMenu', function(society, close, options)
	TriggerEvent('qb-bossmenu:client:OpenMenu', society:gsub('society_', ''))
	if close then
		local menu = {}
		menu.close = function()
		end
		close(_, menu)
	end
end)