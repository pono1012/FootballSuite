-- =======================================================
-- FootballSuite - NextMatch.lua (Native OpenLigaDB Parser)
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
  ["energie cottbus"]         = { "cottbus", "energiecottbus" },
  ["vfl wolfsburg"]           = { "wolfsburg", "vflwolfsburg" },
  ["vfl osnabrueck"]          = { "osnabrueck", "vflosnabrueck" }
}

local function parse_iso_time(dtStr)
  if not dtStr or dtStr == "" then return 0 end
  local y, m, d, hr, min = dtStr:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+)")
  if not y then return 0 end
  local t = os.time({
    year = tonumber(y),
    month = tonumber(m),
    day = tonumber(d),
    hour = tonumber(hr),
    min = tonumber(min),
    sec = 0
  })
  return t or 0
end

local function format_date(dtStr)
  if not dtStr or dtStr == "" then return "Termin offen" end
  local y, m, d, hr, min = dtStr:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+)")
  if not y then return dtStr end
  local t = os.time({year=tonumber(y), month=tonumber(m), day=tonumber(d), hour=tonumber(hr), min=tonumber(min)})
  local days = {"So.", "Mo.", "Di.", "Mi.", "Do.", "Fr.", "Sa."}
  local dayOfWeek = ""
  if t then
    local w = tonumber(os.date("%w", t))
    if w then dayOfWeek = days[w + 1] .. " " end
    local isToday = (os.date("%Y-%m-%d", t) == os.date("%Y-%m-%d", os.time()))
    if isToday then
      return string.format("Heute (%s) %02d:%02d Uhr", dayOfWeek:gsub("%s+",""), tonumber(hr), tonumber(min))
    end
  end
  return string.format("%s%02d.%02d. - %02d:%02d Uhr", dayOfWeek, tonumber(d), tonumber(m), tonumber(hr), tonumber(min))
end

local function clean_league_name(name, shortcut)
  local sc = (shortcut or ""):lower():gsub("%s+", "")
  local n = name or ""

  if sc:find("^dfb") then return "DFB-Pokal" end
  if sc == "bl1" then return "1. Bundesliga" end
  if sc == "bl2" then return "2. Bundesliga" end
  if sc == "bl3" then return "3. Liga" end
  if sc == "blsupercup" or sc == "wsc" or sc == "supercup" then return "Supercup" end
  if sc:find("^ucl") or sc == "cl" then return "Champions League" end
  if sc:find("^uel") or sc == "el" then return "Europa League" end
  if sc:find("^uecl") or sc == "ecl" or sc == "conf" then return "Conference League" end
  if sc == "pl" or sc == "pl1" then return "Premier League" end
  if sc == "la1" or sc == "laliga" then return "La Liga" end
  if sc == "lg1" or sc == "ligue1" then return "Ligue 1" end
  if sc == "ch1" then return "Super League" end
  if sc == "seriea" then return "Serie A" end
  if sc:find("^wm") then return "Weltmeisterschaft" end
  if sc:find("^em") then return "Europameisterschaft" end
  if sc:find("^unl") then return "Nations League" end

  n = de_to_ascii(n)
  n = n:gsub("%s*%d%d%d%d%s*/%s*%d%d%d%d", "")
  n = n:gsub("%s*%d%d%d%d%s*/%s*%d%d", "")
  n = n:gsub("%s*%d%d%d%d", "")
  n = n:gsub("%s*%b()", "")
  n = n:gsub("[Ff]u[ss]+ball%-?", "")
  n = n:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

  if n:lower():find("dfb") and n:lower():find("pokal") then return "DFB-Pokal" end
  if n:lower():find("champions league") then return "Champions League" end
  if n:lower():find("europa league") then return "Europa League" end
  if n:lower():find("conference league") then return "Conference League" end

  if n == "" or #n < 2 then
    return (shortcut and shortcut:upper() or "-")
  end
  return n
end

local function is_valid_competition(shortcut, name)
  local sc = (shortcut or ""):lower():gsub("%s+", "")
  local nm = (name or ""):lower()

  -- Filter out known duplicate/test entries
  if sc == "esp" or sc:find("^test") or sc:find("^tst") or sc == "dsc" or sc == "fts" or sc == "mbtl" then
    return false
  end
  if sc:match("^bl[123]h") then
    return false
  end
  if nm:find("testliga") or nm:find("freundschaft") or nm:find("esp8266") or nm:find("test") then
    return false
  end

  local known = {
    "bl1", "bl2", "bl3", "dfb", "ucl", "uel", "uecl", "cl", "el", "ecl",
    "pl", "la1", "lg1", "ch1", "seriea", "rel", "blsupercup", "supercup", "wsc",
    "wm", "em", "unl", "ca"
  }
  for _, prefix in ipairs(known) do
    if sc == prefix or sc:find("^" .. prefix .. "%d") or sc:find("^" .. prefix .. "%-") or sc:find("^" .. prefix .. "_") then
      return true
    end
  end

  local active = (SKIN:ReplaceVariables('#League#') or ""):lower():gsub("%s+", "")
  if active ~= "" and (sc == active or sc:find("^" .. active)) then
    return true
  end

  return false
end

function ParseMatches()
  local jsonMeasure = SKIN:GetMeasure('mMatchesJSONString')
  local json = jsonMeasure and jsonMeasure:GetStringValue() or ""
  if not json or json == "" or json == "[]" then return end

  local resourcePath = SKIN:ReplaceVariables('#@#')
  local logosDir = (resourcePath .. "logos\\"):gsub("[/\\]+", "\\")
  local defaultLogo = logosDir .. "default.png"

  local function resolve_logo(teamId, teamName)
    if teamId and teamId ~= "" then
      local p = logosDir .. teamId .. ".png"
      if file_exists(p) then return p end
    end
    local key = norm_key(teamName or "")
    local a = aliases[key]
    if a then
      for _, v in ipairs(a) do
        local p = logosDir .. v .. ".png"
        if file_exists(p) then return p end
      end
    end
    local nospace = key:gsub("%s+","")
    if file_exists(logosDir .. nospace .. ".png") then
      return logosDir .. nospace .. ".png"
    end
    return defaultLogo
  end

  local now = os.time()
  local lastMatch = nil
  local lastMatchTime = -1
  local lastMatchValid = false

  local nextMatch = nil
  local nextMatchTime = 9999999999
  local nextMatchValid = false

  -- Alle Match-Objekte iterieren
  for block in json:gmatch('(%b{})') do
    if block:find('"matchID"') then
      local isFin = block:find('"matchIsFinished"%s*:%s*true') ~= nil
      local dtIso = block:match('"matchDateTime"%s*:%s*"([^"]+)"') or ""
      local mTime = parse_iso_time(dtIso)

      if mTime > 0 then
        local lg = (block:match('"leagueShortcut"%s*:%s*"([^"]+)"') or ""):lower()
        local lgName = block:match('"leagueName"%s*:%s*"([^"]+)"') or ""
        local isValid = is_valid_competition(lg, lgName)

        -- Letztes Spiel: beendet ODER vor mehr als 150 Minuten angepfiffen
        if isFin or mTime < (now - 150 * 60) then
          local replaceLast = false
          if not lastMatch then
            replaceLast = true
          elseif isValid and not lastMatchValid then
            replaceLast = true
          elseif (isValid and lastMatchValid) or (not isValid and not lastMatchValid) then
            if mTime > lastMatchTime then
              replaceLast = true
            end
          end
          if replaceLast then
            lastMatch = block
            lastMatchTime = mTime
            lastMatchValid = isValid
          end
        end

        -- Naechstes Spiel: noch nicht beendet UND mindestens innerhalb der letzten 150 Minuten angepfiffen oder in der Zukunft
        if not isFin and mTime >= (now - 150 * 60) then
          local replaceNext = false
          if not nextMatch then
            replaceNext = true
          elseif isValid and not nextMatchValid then
            replaceNext = true
          elseif (isValid and nextMatchValid) or (not isValid and not nextMatchValid) then
            if mTime < nextMatchTime then
              replaceNext = true
            end
          end
          if replaceNext then
            nextMatch = block
            nextMatchTime = mTime
            nextMatchValid = isValid
          end
        end
      end
    end
  end

  local function parse_block(b)
    if not b then return nil end
    local t1_part = b:match('"team1"%s*:%s*(%b{})') or ""
    local t2_part = b:match('"team2"%s*:%s*(%b{})') or ""
    local t1Name = t1_part:match('"teamName"%s*:%s*"([^"]+)"') or "Team 1"
    local t1Id   = t1_part:match('"teamId"%s*:%s*(%d+)') or ""
    local t2Name = t2_part:match('"teamName"%s*:%s*"([^"]+)"') or "Team 2"
    local t2Id   = t2_part:match('"teamId"%s*:%s*(%d+)') or ""
    local dtIso  = b:match('"matchDateTime"%s*:%s*"([^"]+)"') or ""
    local lgShortcut = b:match('"leagueShortcut"%s*:%s*"([^"]+)"') or ""
    local lgName     = b:match('"leagueName"%s*:%s*"([^"]+)"') or ""
    local leagueFmt  = clean_league_name(lgName, lgShortcut)

    local score = "- : -"
    local mr = b:match('"resultName"%s*:%s*"Endergebnis"[^}]*')
    if not mr then
      mr = b:match('"resultOrderID"%s*:%s*2[^}]*')
    end
    if not mr then
      mr = b:match('"resultOrderID"%s*:%s*1[^}]*')
    end
    if mr then
      local p1 = mr:match('"pointsTeam1"%s*:%s*(%d+)')
      local p2 = mr:match('"pointsTeam2"%s*:%s*(%d+)')
      if p1 and p2 then score = p1 .. " : " .. p2 end
    end

    return {
      t1Name = t1Name,
      t1Id = t1Id,
      t2Name = t2Name,
      t2Id = t2Id,
      score = score,
      dt = dtIso,
      league = leagueFmt
    }
  end

  local lm = parse_block(lastMatch)
  local nm = parse_block(nextMatch)

  if lm then
    local logo1 = resolve_logo(lm.t1Id, lm.t1Name)
    local logo2 = resolve_logo(lm.t2Id, lm.t2Name)
    SKIN:Bang('!Log', string.format("FootballSuite NextMatch LAST: %s vs %s (%s) [%s] (%s)", lm.t1Name, lm.t2Name, lm.score, lm.dt, lm.league), 'Notice')
    SKIN:Bang('!SetVariable', 'LTeamHome', lm.t1Name)
    SKIN:Bang('!SetVariable', 'LTeamAway', lm.t2Name)
    SKIN:Bang('!SetVariable', 'LScore', lm.score)
    SKIN:Bang('!SetVariable', 'LDateFmt', format_date(lm.dt))
    SKIN:Bang('!SetVariable', 'LLeague', lm.league)
    SKIN:Bang('!SetVariable', 'LLogoHome', logo1)
    SKIN:Bang('!SetVariable', 'LLogoAway', logo2)
    SKIN:Bang('!SetOption', 'LLeague', 'Text', lm.league)
    SKIN:Bang('!SetOption', 'LLogoHome', 'ImageName', logo1)
    SKIN:Bang('!SetOption', 'LLogoAway', 'ImageName', logo2)
    SKIN:Bang('!SetOption', 'LLogoHome', 'W', '64')
    SKIN:Bang('!SetOption', 'LLogoHome', 'H', '64')
    SKIN:Bang('!SetOption', 'LLogoAway', 'W', '64')
    SKIN:Bang('!SetOption', 'LLogoAway', 'H', '64')
    SKIN:Bang('!UpdateMeter', 'LLeague')
    SKIN:Bang('!UpdateMeter', 'LLogoHome')
    SKIN:Bang('!UpdateMeter', 'LLogoAway')
  end

  if nm then
    local logo1 = resolve_logo(nm.t1Id, nm.t1Name)
    local logo2 = resolve_logo(nm.t2Id, nm.t2Name)
    SKIN:Bang('!Log', string.format("FootballSuite NextMatch NEXT: %s vs %s [%s] (%s)", nm.t1Name, nm.t2Name, nm.dt, nm.league), 'Notice')
    SKIN:Bang('!SetVariable', 'NTeamHome', nm.t1Name)
    SKIN:Bang('!SetVariable', 'NTeamAway', nm.t2Name)
    SKIN:Bang('!SetVariable', 'NDateFmt', format_date(nm.dt))
    SKIN:Bang('!SetVariable', 'NLeague', nm.league)
    SKIN:Bang('!SetVariable', 'NLogoHome', logo1)
    SKIN:Bang('!SetVariable', 'NLogoAway', logo2)
    SKIN:Bang('!SetOption', 'NLeague', 'Text', nm.league)
    SKIN:Bang('!SetOption', 'NLogoHome', 'ImageName', logo1)
    SKIN:Bang('!SetOption', 'NLogoAway', 'ImageName', logo2)
    SKIN:Bang('!SetOption', 'NLogoHome', 'W', '64')
    SKIN:Bang('!SetOption', 'NLogoHome', 'H', '64')
    SKIN:Bang('!SetOption', 'NLogoAway', 'W', '64')
    SKIN:Bang('!SetOption', 'NLogoAway', 'H', '64')
    SKIN:Bang('!UpdateMeter', 'NLeague')
    SKIN:Bang('!UpdateMeter', 'NLogoHome')
    SKIN:Bang('!UpdateMeter', 'NLogoAway')
  end

  SKIN:Bang('!UpdateMeter', '*')
  SKIN:Bang('!Redraw')
end
