PlayerData = {}

AddEventHandler(Config.SharedObjectName, function(cb)
    cb(ESX)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    local job = {}
    job.name = JobInfo.name
    job.grade = JobInfo.grade.level
    if JobInfo.isboss then
        job.grade_name = 'boss'
    end
    PlayerData.job = job
    TriggerEvent('esx:setJob', PlayerData.job)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    local pData = QBCore.Functions.GetPlayerData()
    local job = {}
    if pData.job then
        job.name = pData.job.name
        job.grade = pData.job.grade.level
        if JobInfo.isboss then
            job.grade_name = 'boss'
        end
        pData.job = job
    end
    PlayerData = pData
    TriggerEvent('esx:playerLoaded', PlayerData)
end)

RegisterNetEvent('esx:showNotification')
AddEventHandler('esx:showNotification', function(msg)
    ESX.ShowNotification(msg)
end)

RegisterNetEvent('esx:showAdvancedNotification')
AddEventHandler('esx:showAdvancedNotification', function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
end)

RegisterNetEvent('esx:showHelpNotification')
AddEventHandler('esx:showHelpNotification', function(msg, thisFrame, beep, duration)
    ESX.ShowHelpNotification(msg, thisFrame, beep, duration)
end)