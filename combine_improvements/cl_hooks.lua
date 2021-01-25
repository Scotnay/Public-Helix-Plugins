local PLUGIN = PLUGIN

PLUGIN.SocioStatus = PLUGIN.SocioStatus or "GREEN"

PLUGIN.BOL = PLUGIN.BOL or {}

local StatCol = {
  FRACTURED = Color(255, 0, 0),
  MARGINAL = Color(255, 255, 0),
  STABLE = Color(0, 255, 0)
}


net.Receive("UpdateObjectives",function()

  local NewStatus = net.ReadString()
  local BOLTable = net.ReadTable()

  PLUGIN.SocioStatus = NewStatus

  PLUGIN.BOL = BOLTable

end)


net.Receive("BOL", function()
  local ply = net.ReadEntity()
  local Add = net.ReadBool()

  if Add == true then
    PLUGIN.BOL[#PLUGIN.BOL + 1] = ply:GetName()
  else
    table.RemoveByValue(PLUGIN.BOL, ply:GetName())
  end
end)

net.Receive("SoundEvent", function()

  local sound = net.ReadString()

  LocalPlayer():EmitSound(sound)

end)


function PLUGIN:PopulateEntityInfo(ent, tooltip)
  if ent:GetClass() == "ix_citizenterminal" then
    local name = tooltip:AddRow("name")
    name:SetText("Citizen Terminal")
    name:SetBackgroundColor(Color(0, 110, 230))
    name:SetImportant()
    name:SizeToContents()

    local desc = tooltip:AddRowAfter("name", "desc")
    desc:SetText("A terminal asking for you to input your CID")
    desc:SetBackgroundColor(Color(0, 110, 230))
    desc:SizeToContents()
  end

  if LocalPlayer():IsCombine() and (ent:GetClass() == "ix_cpterminal" or ent:GetClass() == "ix_commandterminal") then
    local name = tooltip:AddRow("name")
    name:SetText("CCA Terminal")
    name:SetBackgroundColor(Color(0, 110, 230))
    name:SetImportant()
    name:SizeToContents()

    local desc = tooltip:AddRowAfter("name", "desc")
    desc:SetText("A terminal asking for your CCA Operating number to access")
    desc:SetBackgroundColor(Color(0, 110, 230))
    desc:SizeToContents()
  end
end

function PLUGIN:HUDPaint()
  if LocalPlayer():IsCombine() then

    local tsin = TimedSin(.75, 120, 255, 0)
    local NewStatus = self.SocioStatus
    local StatusCol = self.SocioStatusCol[NewStatus]
    local area = LocalPlayer():GetArea() -- What was the purpose of this?
    if NewStatus == "JW" then
      StatusCol = Color(tsin, 0, 0)
    elseif NewStatus == "AJW" then
      StatusCol = Color(tsin, tsin, tsin)
    end

    local AllCitizens = {}
    local AllUnits = {}

    for client, char in ix.util.GetCharacters() do
      if char:GetFaction() == FACTION_CITIZEN then
        AllCitizens[#AllCitizens + 1] = char:GetName() .. ": #" .. client:GetNWString("cid", "<ERR>")
      elseif char:IsCombine() then
        AllUnits[#AllUnits + 1] = char:GetName()
      end
    end

    local CitizenManifest = table.concat(AllCitizens, "\n")
    local UnitManifest = table.concat(AllUnits, "\n")
    draw.DrawText("Citizen Manifest: \n" .. CitizenManifest .. "\n\n\n" .. "Unit Manifest: \n" .. UnitManifest, "BudgetLabel", ScrW() - 200, ScrH() / 8, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
    local List = table.concat(self.BOL, "\n")
    draw.SimpleText("Sociostatus: " .. NewStatus, "BudgetLabel", ScrW() - 200, 6, StatusCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
    draw.DrawText("BOL: \n" .. List, "BudgetLabel", ScrW() - 200, 30, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
    for client, char in ix.util.GetCharacters() do
      local bone = client:LookupBone("ValveBiped.Bip01_Head1")
      local bonepos = client:GetBonePosition(bone) + Vector(0, 0, 14)
      local ToScreen = bonepos:ToScreen()
      local distance = LocalPlayer():GetPos():Distance(bonepos)
      local CanSee = LocalPlayer():IsLineOfSightClear(client)
      if char:GetFaction() == FACTION_CITIZEN and client:Alive() and (client:GetMoveType() != MOVETYPE_NOCLIP) then
        local cid = client:GetNWString("cid", "ERR NO CID")
        local cstatus = client:GetNWString("CivilStatus", "NO CIVIL STATUS")
        local statcol = StatCol[cstatus] or Color(255, 0, 0)

        if distance < 275 and CanSee then

          draw.SimpleText(":: CID: #" .. cid .. " ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          draw.SimpleText(":: Citizen Status: " .. cstatus .. " ::", "BudgetLabel", ToScreen.x, ToScreen.y + 15, statcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          if client:GetActiveWeapon() != NULL and client:IsWepRaised() then
            draw.SimpleText(":: Evaluation: EXPUNGE ::", "BudgetLabel", ToScreen.x, ToScreen.y + 30, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          elseif table.HasValue(self.BOL, client:GetName()) or client:GetNWString("CivilStatus", "NO CIVIL STATUS") == "Anti-Citizen" then
            draw.SimpleText(":: Evaluation: PACIFY ::", "BudgetLabel", ToScreen.x, ToScreen.y + 30, Color(255, 100, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          else
            draw.SimpleText(":: Evaluation: MONITOR ::", "BudgetLabel", ToScreen.x, ToScreen.y + 30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          end

        elseif distance > 275 and distance < 450 and CanSee then
          if client:GetActiveWeapon() != NULL and client:IsWepRaised() then
            draw.SimpleText(":: Evaluation: EXPUNGE ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          elseif table.HasValue(self.BOL, client:GetName()) or client:GetNWString("CivilStatus", "NO CIVIL STATUS") == "Anti-Citizen" then
            draw.SimpleText(":: Evaluation: PACIFY ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(255, 100, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          else
            draw.SimpleText(":: Evaluation: MONITOR ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          end
        end
      elseif char:GetFaction() == FACTION_MPF and client:Alive() and (client:GetMoveType() != MOVETYPE_NOCLIP) and client != LocalPlayer() then
        local unitdigits = string.match(client:GetName(), self.Numbers) -- If you use city digits this won't work eg. i17:i5.UNION-241, unless you edit this line
        local unitrank
        local division

        for _, v in ipairs(self.Ranks) do
          if string.match(client:GetName(), v[1]) then
            unitrank = v[1]
            break
          end
        end

        for _, v in ipairs(self.Divisions) do
          if string.match(client:GetName(), v) then
            division = v
            break
          end
        end

        if !unitdigits or !division or !unitrank then
          draw.SimpleText(":: WARNING MALFORMED UNIT SIGNAL ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          return
        end

        if distance < 275 and CanSee then
          draw.SimpleText(":: UNIT TAG: " .. division .. "-" .. unitdigits .. " ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          draw.SimpleText(":: UNIT Rank: " .. unitrank .. " ::", "BudgetLabel", ToScreen.x, ToScreen.y + 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          if unitrank == "CmD" then
            draw.SimpleText(":: Evaluation: SACRIFICE ::", "BudgetLabel", ToScreen.x, ToScreen.y + 30, Color(tsin, tsin, tsin), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          else
            draw.SimpleText(":: Evaluation: PROTECT ::", "BudgetLabel", ToScreen.x, ToScreen.y + 30, Color(0, 110, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          end
        elseif distance > 275 and distance < 450 and CanSee then
          if unitrank == "CmD" then
            draw.SimpleText(":: Evaluation: SACRIFICE ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(tsin, tsin, tsin), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          else
            draw.SimpleText(":: Evaluation: PROTECT ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(0, 110, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          end
        elseif ix.config.Get("UnobstructedBioSig") == false then
          if CanSee then
            draw.SimpleText("::" .. division .. "-" .. unitdigits .. "::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(0, 110, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          end
        else
          draw.SimpleText("::" .. division .. "-" .. unitdigits .. "::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(0, 110, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end


      elseif char:GetFaction() == FACTION_OTA and client:Alive() and client != LocalPlayer() and client:GetMoveType() != MOVETYPE_NOCLIP then
        local unitdigits = string.match(client:GetName(), "%d%d%d%d%d")
        local unitrank = string.match(client:GetName(), "OWS") or string.match(client:GetName(), "EOW")

        if !unitdigits or !division or !unitrank then
          draw.SimpleText(":: WARNING MALFORMED UNIT SIGNAL ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          return
        end

        if LocalPlayer():GetCharacter():GetFaction() != FACTION_OTA and distance < 275 and CanSee then
          draw.SimpleText(":: UNIT ID: #" .. math.random(11111, 99999) .. " ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          draw.SimpleText(":: UNIT ID: #" .. math.random(111, 999) .. " ::", "BudgetLabel", ToScreen.x, ToScreen.y + 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          draw.SimpleText(":: Evaluation: SACRIFICE ::", "BudgetLabel", ToScreen.x, ToScreen.y + 30, Color(tsin, tsin, tsin), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif LocalPlayer():GetCharacter():GetFaction() == FACTION_OTA and distance < 275 and CanSee then
          draw.SimpleText(":: UNIT ID: #" .. unitdigits .. " ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          draw.SimpleText(":: UNIT ID: #" .. unitrank .. " ::", "BudgetLabel", ToScreen.x, ToScreen.y + 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          draw.SimpleText(":: Evaluation: SACRIFICE ::", "BudgetLabel", ToScreen.x, ToScreen.y + 30, Color(tsin, tsin, tsin), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif distance > 275 and distance < 450 and CanSee then
          draw.SimpleText(":: Evaluation: SACRIFICE ::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(tsin, tsin, tsin), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif LocalPlayer():GetCharacter():GetFaction() == FACTION_OTA then
          draw.SimpleText("::#" .. unitdigits .. "::", "BudgetLabel", ToScreen.x, ToScreen.y, Color(150, 50, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
      end
    end
  end
end

netstream.Hook("MPFTerminalUse", function()
  vgui.Create("ixMPFTerminal"):PopulateCitizens()
end)

surface.CreateFont("BigLabel", {
  font = "BudgetLabel",
  size = 22,
  outline = true,
  weight = 20,
  extended = true,
  shadow = true
})



netstream.Hook("CitizenTerminalUse", function()
  vgui.Create("ixCitizenTerminal")
end)



netstream.Hook("HCTerminalUse", function()
  vgui.Create("ixHCTerminal"):PopulateUnits()
end)


-- Credits to val for the idea

netstream.Hook("PDAUse", function(data) -- called PDA use since it is based on a custom request
  local civ = data[1]
  local civRecord = data[2]
  local civPoints = data[3]
  vgui.Create("ixDataView"):PopulateInfo(civ, civRecord, civPoints)
end)
