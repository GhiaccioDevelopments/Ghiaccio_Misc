local fpsEnabled = false

RegisterCommand(Config.fpsCommand, function()
    if not fpsEnabled then
        fpsEnabled = true
        SetTimecycleModifier("yell_tunnel_nodirect")
    else
        fpsEnabled = false
        ClearTimecycleModifier()
    end
end)