local PLUGIN = PLUGIN


local PANEL = {}


function PANEL:Init()
  self:SetSize( 700, 550 )
  self:Center()
  self:MakePopup()
  self:ShowCloseButton(false)
  self.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(30,30,30, 230))
  end

  self.Close = vgui.Create("DButton", self)
  self.Close:SetSize(100, 25)
  self.Close:SetPos(600, 0)
  self.Close:SetText("Finish")
  self.Close:SetTextColor(Color(255, 255, 255,255))
  self.Close.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(75,75,75,150))
  end
  self.Close.DoClick = function()
    self:Remove()
  end

  self.ModelPanel = vgui.Create("DModelPanel", self)
  self.ModelPanel:SetPos(350, 75)
  self.ModelPanel:SetSize(450, 250)

  self.CPList = vgui.Create("DListView", self)
  self.CPList:SetMultiSelect(false)
  self.CPList:SetSize(450, 550)
  self.CPList:AddColumn("Unit Name")
  self.CPList:AddColumn("Unit ID")
  self.CPList:AddColumn("Rank")
  self.CPList.Paint = function(self, w, h)
    draw.RoundedBox(2,0,0,w,h,Color(75,75,75,220))
  end

  self.SetRank = vgui.Create("DButton", self)
  self.SetRank:SetSize(100, 25)
  self.SetRank:SetPos(575, 500)
  self.SetRank:SetText("Rank")

  self.CitizenReminder = vgui.Create("DButton", self)
  self.CitizenReminder:SetSize(100, 25)
  self.CitizenReminder:SetPos(575, 450)
  self.CitizenReminder:SetText("Citizen Reminder")
  self.CitizenReminder.DoClick = function()
    local menu = DermaMenu()
    local sounds = {
      [1] = {"Inspection", "npc/overwatch/cityvoice/f_trainstation_assumepositions_spkr.wav", "Attention, please: All citizens in local residential block, assume your inspection-positions."},
      [2] = {"Innaction", "npc/overwatch/cityvoice/f_innactionisconspiracy_spkr.wav", "Citizen reminder: Inaction is conspiracy. Report counter-behavior to a Civil-Protection team immediately."},
      [3] = {"Deducted", "npc/overwatch/cityvoice/f_rationunitsdeduct_3_spkr.wav", "Attention, occupants: Your block is now charged with permissive inactive coersion. Five ration-units deducted."},
      [4] = {"Infection", "npc/overwatch/cityvoice/f_trainstation_inform_spkr.wav", "Attention, residents: This blocks contains potential civil infection. INFORM, CO-OPERATE, ASSEMBLE."},
      [5] = {"Miscount", "npc/overwatch/cityvoice/f_trainstation_cooperation_spkr.wav", "Attention, residents: Miscount detected in your block. Co-operation with your Civil Protection team permits full ration reward."}
    }
    for i, v in ipairs(sounds) do
      menu:AddOption(v[1], function()
        net.Start("DispatchEvent")
          net.WriteString(v[2])
          net.WriteString(v[3])
        net.SendToServer()
      end)
    end
    menu:Open(gui.MouseX(), gui.MouseY(), false)
  end

  self.CivRevoke = vgui.Create("DButton", self)
  self.CivRevoke:SetSize(100, 25)
  self.CivRevoke:SetPos(460, 450)
  self.CivRevoke:SetText("Citizenship Manager")
  self.CivRevoke.DoClick = function()

    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 450)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("Citizenship Manager")

    local list = vgui.Create("DListView", frame)
    list:SetSize(600, 350)
    list:SetPos(0, 25)
    list:AddColumn("Name")
    list:AddColumn("CID")
    list:AddColumn("Civil Status")
    list.Paint = function(self, w, h)
      draw.RoundedBox(2,0,0,w,h,Color(75,75,75,220))
    end

    for client, char in ix.util.GetCharacters() do
      if char:GetFaction() == FACTION_CITIZEN then
        list:AddLine(client:GetName(), client:GetNWString("cid", "ERR NO CID"), client:GetNWString("CivilStatus", "NO CIVIL STATUS"))
      end
    end

    local Revoke = vgui.Create("DButton", frame)
    Revoke:SetSize(200, 30)
    Revoke:SetPos(50, 400)
    Revoke:SetText("Revoke Citizenship")


    local Reinstate = vgui.Create("DButton", frame)
    Reinstate:SetSize(200, 30)
    Reinstate:SetPos(350, 400)
    Reinstate:SetText("Reinstate Citizenship")

    list.OnRowSelected = function(lst, index, row)
      local SelectName = row:GetValue(1)
      local ply = ix.util.FindPlayer(SelectName)

      Revoke.DoClick = function()
        net.Start("Citizenship")
          net.WriteBool(true)
          net.WriteEntity(ply)
        net.SendToServer()

        net.Start("DispatchEvent")
          net.WriteString("npc/overwatch/cityvoice/f_citizenshiprevoked_6_spkr.wav")
          net.WriteString("Individual, " .. ply:GetName() .. " #" .. ply:GetNWString("cid") .. " you are convicted of multi-anti-civil violations. Implict citizenship revoked. Status, MALIGNANT.")
        net.SendToServer()

      end

      Reinstate.DoClick = function()
        net.Start("Citizenship")
          net.WriteBool(false)
          net.WriteEntity(ply)
        net.SendToServer()
      end

    end
  end

  self.SocioStatus = vgui.Create("DButton", self)
  self.SocioStatus:SetSize(100, 25)
  self.SocioStatus:SetPos(460, 500)
  self.SocioStatus:SetText("Set SocioStatus")
  self.SocioStatus.DoClick = function()
    local menu = DermaMenu()
    for i, v in pairs({"GREEN", "BLUE", "YELLOW", "RED", "JW", "BLACK", "AJW"}) do
      menu:AddOption(v, function()
        net.Start("SocioStatus")
          net.WriteString(v)
        net.SendToServer()
      end)
    end
    menu:Open(gui.MouseX(), gui.MouseY(), false)
  end
end

function PANEL:PopulateUnits()
  for ply, char in ix.util.GetCharacters() do
    local faction = char:GetFaction()
    local unitdigits = string.match(char:GetName(), "%d%d")
    local unitrank
    for _, v in pairs(PLUGIN.Ranks) do
      if string.match(char:GetName(), v[1]) then
        unitrank = v[1]
        break
      end
    end
    if faction == FACTION_MPF then
      self.CPList:AddLine(char:GetName(), unitdigits, unitrank)
    end
  end

  self.CPList.OnRowSelected = function(lst, index, row)

    local SelectName = row:GetValue(1)
    local ply = ix.util.FindPlayer(SelectName)

    if ply then

      self.ModelPanel:SetModel(ply:GetModel())
      local eyepos = self.ModelPanel.Entity:GetBonePosition(self.ModelPanel.Entity:LookupBone("ValveBiped.Bip01_Head1"))
      self.ModelPanel:SetFOV(125)
      self.ModelPanel:SetCamPos(Vector(18, 0, 65))
      self.ModelPanel:SetLookAt(eyepos)
      self.ModelPanel:SetAnimated(false)
      self.ModelPanel.LayoutEntity = function(pan, ent)
        pan:RunAnimation()
          if ent:GetModel() == "models/ma/hla/terranovapolice.mdl" then
            for _, v in ipairs(PLUGIN.Ranks) do
              if string.match(ply:GetName(), v[1]) then
                ent:SetBodygroup(0, v[3])
                ent:SetBodygroup(1, v[2])
              end
            end
          end
        end
      end

      self.SetRank.DoClick = function()
        local menu = DermaMenu()
        for i, v in ipairs(PLUGIN.Ranks) do
          menu:AddOption(v[1], function()
            net.Start("Promotion")
              net.WriteEntity(ply)
              net.WriteTable(v)
            net.SendToServer()
            self:ListRefresh()
          end)
        end
        menu:Open(gui.MouseX(), gui.MouseY(), false)
      end
    end
  end


function PANEL:ListRefresh()
  timer.Simple(0.15, function()
  self.CPList:Clear()
  for ply, char in ix.util.GetCharacters() do
      local faction = char:GetFaction()
      local unitdigits = string.match(char:GetName(), "%d%d")
      local unitrank
      for _, v in pairs(PLUGIN.Ranks) do
        if string.match(char:GetName(), v[1]) then
          unitrank = v[1]
          break
        end
      end
      if faction == FACTION_MPF then
        self.CPList:AddLine(char:GetName(), unitdigits, unitrank)
      end
    end
  end)
end



vgui.Register("ixHCTerminal", PANEL, "DFrame")
