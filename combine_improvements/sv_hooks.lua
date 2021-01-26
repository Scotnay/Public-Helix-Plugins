local PLUGIN = PLUGIN

PLUGIN.BOL = PLUGIN.BOL or {}

PLUGIN.SocioStatus = PLUGIN.SocioStatus or "GREEN"

util.AddNetworkString("UpdateObjectives")
util.AddNetworkString("ChangedStatus")
util.AddNetworkString("ChangedCID")
util.AddNetworkString("SocioStatus")
util.AddNetworkString("BOL")
util.AddNetworkString("NewNotes")
util.AddNetworkString("PrintCID")
util.AddNetworkString("Record")
util.AddNetworkString("RecordRequest")
util.AddNetworkString("RecordRemove")
util.AddNetworkString("Promotion")
util.AddNetworkString("SoundEvent")
util.AddNetworkString("DispatchEvent")
util.AddNetworkString("Citizenship")

function PLUGIN:LoadData()
  self:LoadCivTerminal()
  self:LoadCommandTerminal()
  self:LoadMPFTerminal()
end

function PLUGIN:SaveData()
  self:SaveCivTerminal()
  self:SaveCommandTerminal()
  self:SaveMPFTerminal()
end

function Schema:PlayerDeath(ply, inf, attacker) -- Overriding schema function otherwise double sounds, if problem copy this code to your schema's sv_hooks file and remove this code
  print("Schema was overriden")
  if (ply:IsCombine()) then
    local location = ply:GetArea() or "unknown location"
    local unitnumbers = string.Split(string.match(ply:GetName(), PLUGIN.Numbers), "") -- if you have more or less numbers then add/remove the amount of %d
    local division

    for _, v in pairs(PLUGIN.Divisions) do
      if string.match(ply:GetName(), v) then
        division = v
        break
      end
    end

    local divToString = {
      ["DEFENDER"] = "defender",
      ["HERO"] = "hero",
      ["JURY"] = "jury",
      ["KING"] = "king",
      ["LINE"] = "line",
      ["PATROL"] = "patrol",
      ["QUICK"] = "quick",
      ["ROLLER"] = "roller",
      ["STICK"] = "stick",
      ["TAP"] = "tap",
      ["UNION"] = "union",
      ["VICTOR"] = "victor",
      ["XRAY"] = "xray",
      ["YELLOW"] = "yellow",
      ["VICE"] = "vice"
    }

    local numToString = {
      ["0"] = "zero",
      ["1"] = "one",
      ["2"] = "two",
      ["3"] = "three",
      ["4"] = "four",
      ["5"] = "five",
      ["6"] = "six",
      ["7"] = "seven",
      ["8"] = "eight",
      ["9"] = "nine"
    }

    Schema:AddCombineDisplayMessage("@cLostBiosignal")
    Schema:AddCombineDisplayMessage("@cLostBiosignalLocation", Color(255, 0, 0, 255), location)

    if (IsValid(ply.ixScanner) and ply.ixScanner:Health() > 0) then
      ply.ixScanner:TakeDamage(999)
    end

    local sounds = {"npc/overwatch/radiovoice/on1.wav", "npc/overwatch/radiovoice/lostbiosignalforunit.wav"}

    if division then
      sounds[#sounds + 1] = ("npc/overwatch/radiovoice/" .. divToString[division] .. ".wav")
    end

    if unitnumbers then
      for _, v in pairs(unitnumbers) do
        sounds[#sounds + 1] = ("npc/overwatch/radiovoice/" .. numToString[v] .. ".wav")
      end
    end

    local rand = math.random(1, 3)

    if rand == 1 then
      sounds[#sounds + 1] = "npc/overwatch/radiovoice/allteamsrespondcode3.wav"
    elseif rand == 2 then
      sounds[#sounds + 1] = "npc/overwatch/radiovoice/reinforcementteamscode3.wav"
    else
      sounds[#sounds + 1] = "npc/overwatch/radiovoice/remainingunitscontain.wav"
    end

    sounds[#sounds + 1] = "npc/overwatch/radiovoice/off4.wav"

    for k, v in ipairs(player.GetAll()) do
      if (v:IsCombine()) then
        ix.util.EmitQueuedSounds(v, sounds, 2, nil, v == ply and 100 or 80)
      end
    end
  end


  local CombPlayers = {}
  for _, v in pairs(player.GetAll()) do
    if v:IsCombine() then
      CombPlayers[#CombPlayers + 1] = v
    end
  end
  if attacker:IsCombine() and table.HasValue(PLUGIN.BOL, ply:GetName()) then
    local sounds = {"npc/overwatch/radiovoice/on1.wav"}
    sounds[#sounds + 1] = "npc/overwatch/radiovoice/rewardnotice.wav"
    sounds[#sounds + 1] = "npc/overwatch/radiovoice/off4.wav"
    ix.util.EmitQueuedSounds(attacker, sounds, 1.25, nil)
    table.RemoveByValue(PLUGIN.BOL, ply:GetName())
    net.Start("UpdateObjectives")
      net.WriteString(PLUGIN.SocioStatus)
      net.WriteTable(PLUGIN.BOL)
    net.Send(CombPlayers)
  end
end


--[[function PLUGIN:Think()
  for ply, char in ix.util.GetCharacters() do
    if ply:Alive() == true then
      ply:SetNWString("cid", char:GetData("cid", "NO CID"))
      ply:SetNWString("Notes", char:GetData("Notes", ""))
      ply:SetNWString("CivilStatus", char:GetData("CivilStatus", nil)) -- seting NWStrings because you can't call GetData() on client if not char owner
    end
  end
end]] -- Don't use this unless you want lag and real time updates


function PLUGIN:PlayerSpawn(ply)
  for client, char in ix.util.GetCharacters() do
    ply:SetNWString("cid", char:GetData("cid"))
    ply:SetNWString("Notes", char:GetData("Notes", ""))
    ply:SetNWString("CivilStatus", char:GetData("CivilStatus", nil))
  end
end


function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
  if character:IsCombine() then
    net.Start("UpdateObjectives")
      net.WriteString(PLUGIN.SocioStatus)
      net.WriteTable(PLUGIN.BOL)
    net.Send(client)
    if character:GetFaction() == FACTION_MPF then
      Schema:AddCombineDisplayMessage("All units be aware cohesive biosignal from " .. character:GetName() .. " has been received...", Color(220, 0, 255))
    elseif character:GetFaction() == FACTION_OTA then
      Schema:AddCombineDisplayMessage("All units be aware Overwatch Asset deployed from stasis...", Color(220, 0, 255))
    end

    for _, v in pairs(player.GetAll()) do
      if v:IsCombine() then
        v:EmitSound("npc/overwatch/radiovoice/engagingteamisnoncohesive.wav")
      end
    end

  end

  client:SetNWString("cid", character:GetData("cid", "NO CID"))
  client:SetNWString("Notes", character:GetData("Notes", ""))
  client:SetNWString("CivilStatus", character:GetData("CivilStatus", nil))

end

function PLUGIN:OnCharacterCreated(client, character)
  local faction = character:GetFaction()

  print(character)
  print(client)

  if faction == FACTION_CITIZEN then
    character:SetData("CivilStatus", "STABLE")
    client:SetNWString("CivilStatus", "STABLE")
  end

end

local function CombSound(pitch)
  pitch = pitch or 100
  for _, v in pairs(player.GetAll()) do
    if v:IsCombine() then
      v:EmitSound("npc/roller/code2.wav", 75, pitch)
    end
  end
end

net.Receive("ChangedStatus",function(_, send)
  if send:IsCombine() then
    local ply = net.ReadEntity()
    local status = net.ReadString()

    local char = ply:GetCharacter()
    local Colours = {
      STABLE = Color(0, 255, 0),
      MARGINAL = Color(255, 255, 0),
      FRACTURED = Color(255, 0, 0)
    }

    local pitches = {
      STABLE = 110,
      MARGINAL = 100,
      FRACTURED = 75
    }

    char:SetData("CivilStatus", status)
    ply:SetNWString("CivilStatus", status)
    Schema:AddCombineDisplayMessage(ply:GetName() .. " #" .. ply:GetNWString("cid", "NO CID") .. " Civil Status has been updated to " .. status .. "...", Colours[status])
    CombSound(pitches[status])
  end
end)

net.Receive("ChangedCID",function(_, send)
  if send:IsCombine() then
    local ply = net.ReadEntity()
    local cid = net.ReadInt(32)

    local char = ply:GetCharacter()

    char:SetData("cid", cid)
    ply:SetNWString("cid", cid)
    Schema:AddCombineDisplayMessage(ply:GetName() .. "'s Citizen ID has been updated to " .. cid .. "...")
    CombSound()
  end
end)


net.Receive("SocioStatus",function(_, ply)
  if ply:IsCombine() then
    local NewStatus = net.ReadString()

    local CombPlayers = {}
    for _, v in pairs(player.GetAll()) do
      if v:IsCombine() then
        CombPlayers[#CombPlayers + 1] = v
        v:EmitSound("npc/roller/code2.wav", 75, 100)
      end
    end

    PLUGIN.SocioStatus = NewStatus

    Schema:AddCombineDisplayMessage("Sociostatus has been updated to " .. NewStatus .. "...!", PLUGIN.SocioStatusCol[NewStatus])

    net.Start("UpdateObjectives")
      net.WriteString(PLUGIN.SocioStatus)
      net.WriteTable(PLUGIN.BOL)
    net.Send(CombPlayers)

    local sound

    if NewStatus == "JW" then
      sound = "npc/overwatch/cityvoice/f_protectionresponse_5_spkr.wav"
      ix.chat.Send(ply, "dispatch", "Attention, all ground-protection teams, judgment waiver now in effect. Capital prosecution is discretionary.")
    elseif NewStatus == "AJW" then
      sound = "npc/overwatch/cityvoice/f_protectionresponse_4_spkr.wav"
      ix.chat.Send(ply, "dispatch", "Attention, all ground-protection teams, autonomous judgment is now in effect. Sentencing is now discretionary. Code, AMPUTATE, ZERO, CONFIRM.")
    end

    if NewStatus == "JW" or NewStatus == "AJW" then
      net.Start("SoundEvent")
        net.WriteString(sound)
      net.Broadcast()
    end
  end

end)

net.Receive("BOL",function(_, send)
  if send:IsCombine() then
    local ply = net.ReadEntity()
    local bool = net.ReadBool()

    local CombPlayers = {}
    for _, v in pairs(player.GetAll()) do
      if v:IsCombine() then
        CombPlayers[#CombPlayers + 1] = v
        v:EmitSound("npc/roller/code2.wav", 75, 100)
      end
    end

    if bool == true then
      PLUGIN.BOL[#PLUGIN.BOL + 1] = ply:GetName()
      Schema:AddCombineDisplayMessage("Citizen " .. ply:GetName() .. " #" .. ply:GetCharacter():GetData("cid", "ERR NO CID") .. " has been added to the BOL list...!" , Color(255,0,0))
    else
      table.RemoveByValue(PLUGIN.BOL, ply:GetName())
      Schema:AddCombineDisplayMessage("Citizen " .. ply:GetName() .. " #" .. ply:GetCharacter():GetData("cid", "ERR NO CID") .. " has been removed from the BOL list...!")
    end

    net.Start("UpdateObjectives")
      net.WriteString(PLUGIN.SocioStatus)
      net.WriteTable(PLUGIN.BOL)
    net.Send(CombPlayers)

  end

end)


net.Receive("NewNotes", function(_, ply)
  if ply:IsCombine() then
    local Citizen = net.ReadEntity()
    local note = net.ReadString()

    local char = Citizen:GetCharacter()

    char:SetData("Notes", note)
    ply:SetNWString("Notes", note)
    Schema:AddCombineDisplayMessage("Citizen " .. Citizen:GetName() .. " #" .. Citizen:GetCharacter():GetData("cid", "ERR NO CID") .. " has had their notes updated...!")
    CombSound()
  end
end)


net.Receive("PrintCID",function(_, ply)
  if ply:IsCombine() then
    local Citizen = net.ReadEntity()
    local CivChar = Citizen:GetCharacter()

    local char = ply:GetCharacter()
    local inv = char:GetInventory()

    inv:Add("cid", 1, {
      owner_name = Citizen:GetName(),
      cid = CivChar:GetData("cid", "ERR NO CID"),
    })
  end
end)

net.Receive("Record",function(_, ply)
  if ply:IsCombine() then
    local Citizen = net.ReadEntity()
    local type = net.ReadString()
    local reason = net.ReadString()
    local points = net.ReadInt(32)

    local char = Citizen:GetCharacter()

    char:AddRecord(type, reason, points)

  end

end)

net.Receive("RecordRequest",function(_, play)

  local ply = net.ReadEntity()
  local char = ply:GetCharacter()

  local record = char:GetRecord() or {}
  local lp = char:GetData("lp", 0)
  local vp = char:GetData("vp", 0)

  if record then
    net.Start("RecordRequest")
      net.WriteTable(record)
      net.WriteInt(lp, 32)
      net.WriteInt(vp, 32)
    net.Send(play)
  end

end)

net.Receive("RecordRemove",function(_, send)

  if send:IsCombine() then

    local ply = net.ReadEntity()
    local type = net.ReadString()
    local record = net.ReadString()
    local points = net.ReadInt(32)

    local char = ply:GetCharacter()

    char:RemoveRecord(type, record, points)

  end

end)

net.Receive("Promotion", function(_, send)
  if send:IsCombine() then

    local ply = net.ReadEntity()
    local rankTable = net.ReadTable()

    print(ply)

    local name = ply:GetName()
    local newName
    for k, v in ipairs(PLUGIN.Ranks) do
      if string.match(name, v[1]) then
        newName = string.gsub(name, v[1], rankTable[1])
      else
        print(newName)
        print(name)
      end
    end

    ply:GetCharacter():SetName(newName)

    if ply:GetModel() == "models/ma/hla/terranovapolice.mdl" then
      local bodyGroups = ply:GetCharacter():GetData("groups", {})
      local armband = ply:FindBodygroupByName("armband")
      local mask = ply:FindBodygroupByName("masks")


      bodyGroups[mask] = rankTable[2]
      bodyGroups[armband] = rankTable[3]

      ply:GetCharacter():SetData("groups", bodyGroups)
      ply:SetBodygroup(armband, rankTable[3])
      ply:SetBodygroup(mask, rankTable[2])
    end

    Schema:AddCombineDisplayMessage(name .. "'s rank has been set to " .. rankTable[1] .. "...")
    CombSound()

  end

end)


net.Receive("DispatchEvent", function(_, ply)

  if ply:IsCombine() then

    local sound = net.ReadString()
    local message = net.ReadString()

    ix.chat.Send(ply, "dispatch", message)

    net.Start("SoundEvent")
      net.WriteString(sound)
    net.Broadcast()
  end

end)

net.Receive("Citizenship", function(_, ply)

  if ply:IsCombine() then

    local type = net.ReadBool()
    local ent = net.ReadEntity()


    local char = ent:GetCharacter()

    if type == true then
      char:SetData("CivilStatus", "Anti-Citizen")
      char:SetData("cid", nil)
      ent:SetNWString("CivilStatus", "Anti-Citizen")
      ent:SetNWString("cid", "ERR NO CID")
      Schema:AddCombineDisplayMessage(ent:GetName() .. " has had their citizenship revoked and is now targeted as an anti-citizen, evaluation: Expunge...", Color(255,0,0))
      CombSound()
    else
      local newid = math.random(11111, 99999)
      char:SetData("CivilStatus", "STABLE")
      char:SetData("cid", newid)
      ent:SetNWString("CivilStatus", "STABLE")
      ent:SetNWString("cid", newid)
      Schema:AddCombineDisplayMessage(ent:GetName() .. " has had their citzenship reinstated...")
      CombSound()
    end

  end

end)
