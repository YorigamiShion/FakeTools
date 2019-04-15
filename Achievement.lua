local achievementList = achievementList or {}
local achievementReady
local function prepareFakeAchievement()
    if achievementReady then return end
    for id = 0, 20000 do 
        if GetAchievementLink(id) then
            local _, name = GetAchievementInfo(id)
            if name then
                achievementList[name] = id
            end
        end
    end
    achievementReady = true
end

local achievementDate = date('%m:%d:%y')
SlashCmdList.SetAchievementDate = function(arg)
    if arg:match('%d%d:%d%d:%d%d') then
        achievementDate = arg
    else
        local argList = {string.split(' ', arg)}
        if #argList == 3 then
            achievementDate = table.concat(argList, ':')
        end
    end
    print(achievementDate)
end
SLASH_SetAchievementDate1 = '/sad'

local function fakeAchievementLink(id, achDate, name)
    achDate = achDate or date('%m:%d:%y')
    name = name or select(2, GetAchievementInfo(id))
    return ('|cffffff00|Hachievement:%s:%s:1:%s:4294967295:4294967295:4294967295:4294967295|h[%s]|h|r'):format(id, UnitGUID('player'), achDate, name)
end

SlashCmdList.FindFakeAchievement = function(arg)
    if arg == '' then return end
    if not achievementReady then prepareFakeAchievement() end
    print(('Finding %s:'):format(arg))
    for name, id in pairs(achievementList) do
        if name:find(arg) then
            print(id, fakeAchievementLink(id, achievementDate, name))
        end
    end
end
SLASH_FindFakeAchievement1 = '/ffa'