-- =======================================================
-- FootballSuite - Table.lua (Universal Table Parser)
-- =======================================================

function file_exists(name)
  if not name or name == "" then return false end
  name = name:gsub("[/\\]+", "\\")
  local f = io.open(name, "r")
  if f ~= nil then io.close(f); return true else return false end
end

local function de_to_ascii(s)
  return (s or "")
    :gsub("\195\132","Ae"):gsub("\195\150","Oe"):gsub("\195\156","Ue")
    :gsub("\195\164","ae"):gsub("\195\182","oe"):gsub("\195\188","ue")
    :gsub("\195\159","ss")
    :gsub("\196","Ae"):gsub("\214","Oe"):gsub("\220","Ue")
    :gsub("\228","ae"):gsub("\246","oe"):gsub("\252","ue")
    :gsub("\223","ss")
end

local function norm_key(s)
  s = de_to_ascii(s or "")
  s = s:lower()
  s = s:gsub("[%p]+"," ")
  s = s:gsub("%s+"," ")
  s = s:gsub("^%s+",""):gsub("%s+$","")
  return s
end

local aliases = {
  ["karlsruher sc"]           = { "ksc", "karlsruhe", "karlsruher" },
  ["1 fc nuernberg"]          = { "nuernberg", "1fcn", "1fcnuernberg" },
  ["1. fc nuernberg"]         = { "nuernberg", "1fcn", "1fcnuernberg" },
  ["hannover 96"]             = { "hannover96", "hannover" },
  ["fc schalke 04"]           = { "schalke04", "schalke" },
  ["sv 07 elversberg"]        = { "elversberg", "svelversberg" },
  ["dsc arminia bielefeld"]   = { "bielefeld", "arminia", "arminiabielefeld" },
  ["arminia bielefeld"]       = { "bielefeld", "arminia", "arminiabielefeld" },
  ["sv darmstadt 98"]         = { "darmstadt98", "darmstadt" },
  ["sc preussen muenster"]    = { "preussenmuenster", "muenster", "preussen" },
  ["eintracht braunschweig"]  = { "eintrachtbraunschweig", "braunschweig" },
  ["1 fc kaiserslautern"]     = { "kaiserslautern", "lautern" },
  ["spvgg greuther fuerth"]   = { "greutherfuerth", "fuerth" },
  ["sc paderborn 07"]         = { "paderborn07", "paderborn" },
  ["fortuna duesseldorf"]     = { "fortuna", "duesseldorf" },
  ["dynamo dresden"]          = { "dynamodresden", "dresden" },
  ["holstein kiel"]           = { "holsteinkiel", "kiel" },
  ["1 fc magdeburg"]          = { "fcmagdeburg", "magdeburg" },
  ["vfl bochum"]              = { "vflbochum", "bochum" },
  ["hertha bsc"]              = { "herthabsc", "hertha" },
  ["hamburger sv"]            = { "hsv", "hamburgersv", "hamburg" },
  ["fc st pauli"]             = { "stpauli", "pauli" },
  ["fc bayern muenchen"]      = { "bayern", "fcbayern" },
  ["borussia dortmund"]       = { "bvb", "dortmund" },
  ["bayer 04 leverkusen"]     = { "leverkusen", "bayer" },
  ["rb leipzig"]              = { "leipzig", "rbleipzig" },
  ["vfb stuttgart"]           = { "stuttgart" },
  ["eintracht frankfurt"]     = { "frankfurt" },

  -- Premier League
  ["fc arsenal"]              = { "arsenal" },
  ["arsenal fc"]              = { "arsenal" },
  ["manchester city"]         = { "mancity", "city" },
  ["manchester united fc"]    = { "manunited", "manu" },
  ["fc liverpool"]            = { "liverpool" },
  ["chelsea fc"]              = { "chelsea" },
  ["tottenham hotspur fc"]    = { "tottenham", "spurs" },
  ["newcastle united fc"]     = { "newcastle" },
  ["aston villa"]             = { "astonvilla", "villa" },

  -- International & Champions League
  ["real madrid"]             = { "realmadrid", "madrid" },
  ["fc barcelona"]            = { "barcelona", "barca" },
  ["paris saint germain"]     = { "psg" },
  ["as rom"]                  = { "asrom", "roma" },
  ["fc porto"]                = { "porto" },
  ["besiktas istanbul"]       = { "besiktas" },
  ["dynamo kiew"]             = { "kiew" },

  -- Schweiz
  ["bsc young boys"]          = { "youngboys", "yb" },
  ["fc basel 1893"]           = { "basel", "fcb" },
  ["fc zuerich"]              = { "zuerich", "fcz" },
  ["fc luzern"]               = { "luzern" },
  ["fc st gallen"]            = { "stgallen", "sg" },
  ["fc sion"]                 = { "sion" },

  -- Nationen (UNL / EM / WM)
  ["deutschland"]             = { "dfb", "germany" },
  ["spanien"]                 = { "spain" },
  ["frankreich"]              = { "france" },
  ["england"]                 = { "england" },
  ["italien"]                 = { "italy" },
  ["niederlande"]             = { "netherlands", "holland" },
  ["portugal"]                = { "portugal" },
  ["kroatien"]                = { "croatia" },
  ["schweiz"]                 = { "switzerland" },
  ["argentinien"]             = { "argentina" },
  ["brasilien"]               = { "brazil" }
}

local leagueDefaultSeason = {
  ["la1"]    = 2026,
  ["bl1"]    = 2026,
  ["bl2"]    = 2026,
  ["bl3"]    = 2026,
  ["pl"]     = 2026,
  ["ucl"]    = 2025,
  ["uel"]    = 2024,
  ["ch1"]    = 2025,
  ["unl2024"]= 2024,
  ["em"]     = 2024,
  ["wm2026"] = 2026,
  ["CA2024"] = 2024,
  ["lg1"]    = 2017
}

function Update()
  local lg = SKIN:GetVariable('League') or "bl2"
  local yr = tonumber(SKIN:GetMeasure('m.Year'):GetStringValue()) or 2026
  local mo = tonumber(SKIN:GetMeasure('m.Month'):GetStringValue()) or 7
  local season = yr
  if mo < 7 then season = yr - 1 end
  if leagueDefaultSeason[lg] then
    season = leagueDefaultSeason[lg]
  end
  SKIN:Bang('!SetVariable', 'Season', tostring(season))

  -- Falls Daten noch nicht geladen sind (z.B. nach Neustart ohne sofortiges Netz):
  local t1 = SKIN:GetVariable('Team1')
  if not t1 or t1 == "" or t1 == "Lade..." then
    SKIN:Bang('!CommandMeasure', 'mJSON', 'Update')
  end

  return season
end

local function get_zone_color(league, pos, totalTeams)
  local lg = (league or ""):lower():gsub("%s+", "")
  local colPromote  = SKIN:GetVariable('ColPromote') or "52,211,153,255"
  local colPlayoff  = SKIN:GetVariable('ColPlayoff') or "56,189,248,255"
  local colRelPO    = SKIN:GetVariable('ColRelPO') or "251,191,36,255"
  local colRelegate = SKIN:GetVariable('ColRelegate') or "248,113,113,255"
  local colDim      = SKIN:GetVariable('DimText') or "100,116,139,255"

  if lg == "bl1" then
    if pos <= 4 then return colPromote end
    if pos == 5 or pos == 6 then return colPlayoff end
    if pos == 16 then return colRelPO end
    if pos >= 17 then return colRelegate end
  elseif lg == "bl2" then
    if pos <= 2 then return colPromote end
    if pos == 3 then return colPlayoff end
    if pos == 16 then return colRelPO end
    if pos >= 17 then return colRelegate end
  elseif lg == "bl3" then
    if pos <= 2 then return colPromote end
    if pos == 3 then return colPlayoff end
    if pos >= 17 then return colRelegate end
  elseif lg == "pl" then
    if pos <= 4 then return colPromote end
    if pos == 5 then return colPlayoff end
    if pos >= 18 then return colRelegate end
  elseif lg == "la1" then
    if pos <= 4 then return colPromote end
    if pos == 5 or pos == 6 then return colPlayoff end
    if pos >= 18 then return colRelegate end
  elseif lg == "lg1" then
    if pos <= 3 then return colPromote end
    if pos == 4 then return colPlayoff end
    if pos == 16 then return colRelPO end
    if pos >= 17 then return colRelegate end
  elseif lg == "ch1" then
    if pos == 1 then return colPromote end
    if pos == 2 or pos == 3 then return colPlayoff end
    if pos == 11 then return colRelPO end
    if pos == 12 then return colRelegate end
  elseif lg:find("^ucl") or lg:find("^uel") or lg == "cl" or lg == "el" then
    if pos <= 8 then return colPromote end
    if pos >= 9 and pos <= 24 then return colPlayoff end
    if pos >= 25 then return colDim end
  else
    if pos <= 2 then return colPromote end
    if pos == 3 then return colPlayoff end
    if totalTeams >= 16 and pos >= (totalTeams - 2) then return colRelegate end
  end

  return colDim
end

function ParseJSON()
  local json = SKIN:GetMeasure('mJSONString'):GetStringValue()
  if not json or json == "" then
    -- Noch keine Daten erhalten: In 60s erneut probieren
    SKIN:Bang('!SetOption', 'mJSON', 'UpdateRate', '60')
    SKIN:Bang('!UpdateMeasure', 'mJSON')
    return
  end
  
  -- Falls die Saison noch leer ist, Vorjahr anfragen
  if json:match("^%s*%[%s*%]%s*$") then
    local current = tonumber(SKIN:GetVariable("Season")) or 2026
    if current > 2017 then
      SKIN:Bang('!SetVariable', 'Season', tostring(current - 1))
      SKIN:Bang('!UpdateMeasure', 'mJSON')
      SKIN:Bang('!CommandMeasure', 'mJSON', 'Update')
    else
      SKIN:Bang('!SetOption', 'mJSON', 'UpdateRate', '60')
      SKIN:Bang('!UpdateMeasure', 'mJSON')
    end
    return
  end

  local resourcePath = SKIN:ReplaceVariables('#@#')
  local logosDir = (resourcePath .. "logos\\"):gsub("[/\\]+", "\\")
  local favTeamId = tostring(SKIN:GetVariable('TeamId') or "")
  local favTeamName = norm_key(SKIN:GetVariable('TeamName') or "")
  local activeLeague = (SKIN:GetVariable('League') or "bl1"):lower():gsub("%s+", "")
  local MAX_ROWS = 36
  local i = 1

  for row in json:gmatch("{(.-)}") do
    if i > MAX_ROWS then break end
    
    local teamName  = row:match('"teamName"%s*:%s*"([^"]+)"') or ("Team " .. i)
    local teamId    = row:match('"teamInfoId"%s*:%s*(%d+)') or ""
    local points    = row:match('"points"%s*:%s*(%d+)') or "0"
    local goals     = row:match('"goals"%s*:%s*(%d+)') or "0"
    local oppGoals  = row:match('"opponentGoals"%s*:%s*(%d+)') or "0"
    local diff      = row:match('"goalDiff"%s*:%s*([%-%d]+)') or "0"
    local iconUrl   = row:match('"teamIconUrl"%s*:%s*"([^"]+)"') or ""

    local logoPath = logosDir .. "default.png"
    
    -- 1. Suche nach Team-ID
    if teamId ~= "" and file_exists(logosDir .. teamId .. ".png") then
      logoPath = logosDir .. teamId .. ".png"
    else
      -- 2. Suche nach Alias/Name
      local key = norm_key(teamName)
      local a = aliases[key]
      local found = false
      if a then
        for _, stem in ipairs(a) do
          local p = logosDir .. de_to_ascii(stem) .. ".png"
          if file_exists(p) then logoPath = p; found = true; break end
        end
      end
      if not found then
        local nospace = key:gsub("%s+","")
        local p = logosDir .. nospace .. ".png"
        if file_exists(p) then logoPath = p; found = true end
      end
    end

    local colFG = SKIN:GetVariable('FG') or "240,240,245,255"
    local colAccent = SKIN:GetVariable('Accent') or "56,189,248,255"
    local isFav = 0
    local teamColor = colFG
    if (teamId ~= "" and teamId == favTeamId) or (norm_key(teamName) == favTeamName) then
      isFav = 1
      teamColor = colAccent
    end

    local diffNum = tonumber(diff) or 0
    local diffFmt = tostring(diffNum)
    if diffNum > 0 then diffFmt = "+" .. diffNum end
    local goalsFmt = goals .. ":" .. oppGoals

    SKIN:Bang('!SetVariable', 'Team' .. i, teamName)
    SKIN:Bang('!SetVariable', 'Pts' .. i, points)
    SKIN:Bang('!SetVariable', 'GF' .. i, goals)
    SKIN:Bang('!SetVariable', 'GA' .. i, oppGoals)
    SKIN:Bang('!SetVariable', 'GD' .. i, diffFmt)
    SKIN:Bang('!SetVariable', 'Goals' .. i, goalsFmt)
    SKIN:Bang('!SetVariable', 'Logo' .. i, logoPath)
    SKIN:Bang('!SetOption', 'RowLogo' .. i, 'ImageName', logoPath)
    SKIN:Bang('!SetOption', 'RowLogo' .. i, 'W', '18')
    SKIN:Bang('!SetOption', 'RowLogo' .. i, 'H', '18')
    SKIN:Bang('!UpdateMeter', 'RowLogo' .. i)
    SKIN:Bang('!SetVariable', 'IsFav' .. i, tostring(isFav))
    SKIN:Bang('!SetVariable', 'TeamColor' .. i, teamColor)
    
    i = i + 1
  end

  local totalRows = i - 1

  -- Sichtbare Zeilen einblenden & Zonenfarben dynamisch setzen
  local curTheme = (SKIN:GetVariable('Theme') or ""):lower()
  local isTrans = (curTheme:find("^trans_") ~= nil)

  for k = 1, totalRows do
    local zColor = get_zone_color(activeLeague, k, totalRows)
    SKIN:Bang('!SetOption', 'RowBar' .. k, 'Fill Color', zColor)
    SKIN:Bang('!SetOption', 'RowPos' .. k, 'FontColor', zColor)
    local isFav = tonumber(SKIN:GetVariable('IsFav' .. k)) or 0
    if isFav == 1 and not isTrans then
      SKIN:Bang('!ShowMeter', 'RowFavBG' .. k)
    else
      SKIN:Bang('!HideMeter', 'RowFavBG' .. k)
    end
    SKIN:Bang('!ShowMeter', 'RowBar' .. k)
    SKIN:Bang('!ShowMeter', 'RowPos' .. k)
    SKIN:Bang('!ShowMeter', 'RowLogo' .. k)
    SKIN:Bang('!ShowMeter', 'RowTeam' .. k)
    SKIN:Bang('!ShowMeter', 'RowGoals' .. k)
    SKIN:Bang('!ShowMeter', 'RowGD' .. k)
    SKIN:Bang('!ShowMeter', 'RowPts' .. k)
  end

  -- Nicht benutzte Zeilen ausblenden
  for j = i, MAX_ROWS do
    SKIN:Bang('!SetVariable', 'Team' .. j, "")
    SKIN:Bang('!SetVariable', 'Pts' .. j, "")
    SKIN:Bang('!SetVariable', 'GF' .. j, "")
    SKIN:Bang('!SetVariable', 'GA' .. j, "")
    SKIN:Bang('!SetVariable', 'GD' .. j, "")
    SKIN:Bang('!SetVariable', 'Goals' .. j, "")
    SKIN:Bang('!SetOption', 'RowLogo' .. j, 'ImageName', logosDir .. "default.png")
    SKIN:Bang('!SetVariable', 'IsFav' .. j, "0")
    SKIN:Bang('!SetVariable', 'TeamColor' .. j, "0,0,0,0")
    SKIN:Bang('!HideMeter', 'RowFavBG' .. j)
    SKIN:Bang('!HideMeter', 'RowBar' .. j)
    SKIN:Bang('!HideMeter', 'RowPos' .. j)
    SKIN:Bang('!HideMeter', 'RowLogo' .. j)
    SKIN:Bang('!HideMeter', 'RowTeam' .. j)
    SKIN:Bang('!HideMeter', 'RowGoals' .. j)
    SKIN:Bang('!HideMeter', 'RowGD' .. j)
    SKIN:Bang('!HideMeter', 'RowPts' .. j)
  end

  -- Kartenhöhe dynamisch an die echte Teamanzahl anpassen
  local newCardH = 70 + (totalRows * 22) + 12
  if totalRows < 1 then newCardH = 472 end
  SKIN:Bang('!SetVariable', 'CardH', tostring(newCardH))
  if isTrans then
    SKIN:Bang('!SetOption', 'CardBG', 'Shape', string.format('Rectangle 0,0,#CardW#,%d,10 | Fill Color 0,0,0,0 | StrokeWidth 0 | Stroke Color 0,0,0,0', newCardH))
    SKIN:Bang('!HideMeter', 'HeaderDivider')
  else
    SKIN:Bang('!SetOption', 'CardBG', 'Shape', string.format('Rectangle 0,0,#CardW#,%d,10 | Fill Color #CardBg# | StrokeWidth #CardBorderW# | Stroke Color #CardBorder#', newCardH))
    SKIN:Bang('!ShowMeter', 'HeaderDivider')
  end
  SKIN:Bang('!UpdateMeter', 'CardBG')
  SKIN:Bang('!UpdateMeter', 'HeaderDivider')

  -- -------------------------------------------------------
  -- Intelligente adaptive UpdateRate für mJSON berechnen
  -- -------------------------------------------------------
  local now = os.date("*t")
  local wday = now.wday
  local hour = now.hour
  local isMatchWindow = false

  if wday == 6 and hour >= 18 and hour <= 23 then
    isMatchWindow = true
  elseif wday == 7 and hour >= 12 and hour <= 23 then
    isMatchWindow = true
  elseif wday == 1 and hour >= 12 and hour <= 22 then
    isMatchWindow = true
  elseif (wday == 3 or wday == 4) and hour >= 18 and hour <= 23 then
    isMatchWindow = true
  end

  local smartRate = 21600 -- Außerhalb: 6 Stunden sparsamer Heartbeat
  if isMatchWindow then
    smartRate = 900 -- Während Spieltags-Fenster: alle 15 Minuten
  end

  SKIN:Bang('!SetOption', 'mJSON', 'UpdateRate', tostring(smartRate))
  -- KEIN !UpdateMeasure mJSON hier - wuerde Reload-Loop ausloesen!

  SKIN:Bang('!UpdateMeter', '*')
  SKIN:Bang('!Redraw')
end
