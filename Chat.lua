local printContent = {}
local aliasTable = {}

local function check(value, text)
    if not value then print(text) end
end

local validClass = {
    LR = 'HUNTER', HUNTER = 'HUNTER',
    ZS = 'WARLOCK', WARLOCK = 'WARLOCK',
    MS = 'PRIEST', PRIEST = 'PRIEST',
    QS = 'PALADIN', PALADIN = 'PALADIN',
    FS = 'MAGE', MAGE = 'MAGE',
    DZ = 'ROGUE', ROGUE = 'ROGUE',
    XD = 'DRUID', DRUID = 'DRUID',
    SM = 'SHAMAN', SHAMAN = 'SHAMAN',
    ZS = 'WARRIOR', WARRIOR = 'WARRIOR',
    DK = 'DEATHKNIGHT', DEATHKNIGHT = 'DEATHKNIGHT',
    WS = 'MONK', MONK = 'MONK',
    DH = 'DEMONHUNTER', DEMONHUNTER = 'DEMONHUNTER',
}

local validChannel = {
    S = 'SAY', SAY = 'SAY',
    Y = 'YELL', YELL = 'YELL',
    P = 'PARTY', PARTY = 'PARTY',
    PL = 'PARTY_LEADER', PARTY_LEADER = 'PARTY_LEADER',
    R = 'RAID', RAID = 'RAID',
    RL = 'RAID_LEADER', RAID_LEADER = 'RAID_LEADER',
    G = 'GUILD', GUILD = 'GUILD',
    W = 'WHISPER', WHISPER = 'WHISPER',
    WI = 'WHISPER_INFORM', WHISPER_INFORM = 'WHISPER_INFORM',
}

local function fakeShow(interval)
    interval = tonumber(interval)
    if not interval then
        for _, v in ipairs(printContent) do
            print(v)
        end
    else
        for i, v in ipairs(printContent) do
            C_Timer.After(i * (interval or 0.5), function() print(v) end)
        end
    end
end

local function fakeList(what)
    what = (what or 'CONTENT'):upper()
    print('-----------------------')
    if what == 'CONTENT' or what == 'C' then
        for i, v in ipairs(printContent) do
            print(i, v)
            print('-----------------------')
        end
    elseif what == 'ALIAS' or what == 'A' then
        for i, v in pairs(aliasTable) do
            print(i, v.name, v.class, v.channel)
            print('-----------------------')
        end
    end
end

local function colorText(text, c)
    return format('|cff%02x%02x%02x%%s|r', 255*c.r, 255*c.g, 255*c.b):format(text)
end

local function fakeAdd(name, class, channel, text)
    assert(name and class and channel and text, 'Using /fakechat add name class channel text')
    class = class:upper()
    channel = channel:upper()
    assert(validClass[class], 'Unkown class: ' .. class)
    assert(validChannel[channel], 'Unkown channel: ' .. channel)
    class = validClass[class]
    channel = validChannel[channel]
    local classInfo = RAID_CLASS_COLORS[class]
    local channelInfo = ChatTypeInfo[channel]
    tinsert(printContent, colorText(_G[format('CHAT_%s_GET', channel)]:format('['..colorText(name, classInfo)..colorText(']', channelInfo)), channelInfo)..colorText(text, channelInfo))
end

local function fakeFastadd(alias, text)
    alias = tonumber(alias)
    assert(aliasTable[alias], 'Unkown alias: ' .. alias)
    fakeAdd(aliasTable[alias].name, aliasTable[alias].class, aliasTable[alias].channel, text)
end

local function fakeAlias(number, name, class, channel)
    assert(number and name and class and channel, 'Using /fakechat alias number name class channel')
    class = class:upper()
    channel = channel:upper()
    number = tonumber(number)
    assert(0 < number and number < 10, 'Expect an alias from 1 to 9, get ' .. number)
    assert(validClass[class], 'Unkown class: ' .. class)
    assert(validChannel[channel], 'Unkown channel: ' .. channel)
    if aliasTable[number] then
        print(format('Alias %d exists', alias))
        return
    end

    aliasTable[number] = {
        name = name,
        class = class,
        channel = channel,
    }
end

local function fakeDel(what, index)
    assert(what and index, 'Using /fakechat del what index')
    what = what:upper()
    index = tonumber(index)
    if what == 'CONTENT' or what == 'C' then
        tremove(printContent, index)
    elseif what == 'ALIAS' or what == 'A' then
        tremove(aliasTable, index)
    end
end

local function fakeReset(what)
    what = what:upper()
    if what == 'ALL' or what == 'A' then wipe(aliasTable) end
    wipe(printContent)
end

local function fakeHelp()
    print('>>>>>>>>>>>>')
    print('Abbreviation of channel: S(say) Y(yell) P(party) PL(party leader) R(raid) RL(raid leader) G(guild) W(whisper from) WI(whisper to)')
    print('------------')
    print('/fakechat show (interval)       print stored content, default interval is 0 second')
    print('/fakechat list        list content with number')
    print('/fakechat list alias        list alias with number')
    print('/fakechat add (name) (class) (channel) (content)        add content')
    print('/fakechat fastadd (num) (content)        use alias to add content')
    print('/fakechat alias (num) (name) (class) (channel)        num is a number of 1~9 use fastadd to quick insert')
    print('/fakechat del content (num)        delete the stored content of number')
    print('/fakechat del alias (num)        delete the alias of certain number')
    print('/fakechat reset all        clear stored content and alias')
    print('/fakechat reset        clear stored content')
    print('------------')
    print('Abbreviation of command: s(show) l(list) a(add) fa(fastadd) as(alias) d(del) r(reset)')
    print('Abbreviation of secondary command: a(alias) c(content)')
    print('<<<<<<<<<<<<')
end

local argList = {
    SHOW = fakeShow, S = fakeShow,
    LIST = fakeList, L = fakeList,
    ADD = fakeAdd, A = fakeAdd,
    FASTADD = fakeFastadd, FA = fakeFastadd,
    ALIAS = fakeAlias, AS = fakeAlias,
    DEL = fakeDel, D = fakeDel,
    RESET = fakeReset, R = fakeReset,
    HELP = fakeHelp, H = fakeHelp,
}

SLASH_FAKECHAT1 = '/fakechat'
SlashCmdList.FAKECHAT = function(msg)
    if msg == '' then
        msg = 'help'
    end
    local args = {strsplit(' ', msg)}
    firstArg = args[1]:upper()
    assert(argList[firstArg], 'Unkown argument: ' .. args[1])
    tremove(args, 1)
    argList[firstArg](unpack(args))
end
