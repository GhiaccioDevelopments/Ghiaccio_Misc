RegisterCommand('status', function(source, args, rawCommand)
	if source == 0 or source == "Console" then return end
	args = table.concat(args, " ")
	if args == "" or args == " " then
		TriggerClientEvent('status:client:triggerDisplayoff', -1, source, args, "statusoff")
	else
		TriggerClientEvent('status:client:triggerDisplay', -1, source, args, "status")
	end
end, false)