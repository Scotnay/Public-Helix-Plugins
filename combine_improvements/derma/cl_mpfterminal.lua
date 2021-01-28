local PLUGIN = PLUGIN

local PANEL = {}

function PANEL:Init()
  self:SetSize(700, 550)
  self:Center()
  self:MakePopup()
  self:ShowCloseButton(false)
  self:SetDeleteOnClose(true)
  self:SetTitle("")
  self.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(30, 30, 30, 150))
  end

  self.Close = vgui.Create("DButton", self)
  self.Close:SetSize(100, 25)
  self.Close:SetPos(600, 0)
  self.Close:SetText("Finish")
  self.Close:SetTextColor(Color(255, 255, 255, 255))
  self.Close.DoClick = function()
    self:Remove()
  end

  self.Notes = vgui.Create("DButton", self)
  self.Notes:SetSize(100, 25)
  self.Notes:SetPos(460, 450)
  self.Notes:SetText("Notes")

  self.Record = vgui.Create("DButton", self)
  self.Record:SetSize(100, 25)
  self.Record:SetPos(575, 500)
  self.Record:SetText("View Record")

  self.PrintCID = vgui.Create("DButton", self)
  self.PrintCID:SetSize(100, 25)
  self.PrintCID:SetPos(460, 500)
  self.PrintCID:SetText("Print CID")

  self.BOL = vgui.Create("DButton", self)
  self.BOL:SetSize(100, 25)
  self.BOL:SetPos(460, 400)
  self.BOL:SetText("BOL")

  self.SetStatus = vgui.Create("DButton", self)
  self.SetStatus:SetSize(100, 25)
  self.SetStatus:SetPos(575, 400)
  self.SetStatus:SetText("Set Citizen Status")

  self.SetCID = vgui.Create("DButton", self)
  self.SetCID:SetSize(100, 25)
  self.SetCID:SetPos(575, 450)
  self.SetCID:SetText("Set Citizen CID")

  self.ModelPanel = vgui.Create("DModelPanel", self)
  self.ModelPanel:SetPos(350, 75)
  self.ModelPanel:SetSize(450, 250)

  self.CitizenList = vgui.Create("DListView", self)
  self.CitizenList:SetMultiSelect(false)
  self.CitizenList:SetSize(450, 550)
  self.CitizenList:AddColumn("Name")
  self.CitizenList:AddColumn("CID")
  self.CitizenList:AddColumn("Status")
  self.CitizenList.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(75, 75, 75, 220))
  end
end

function PANEL:PopulateCitizens()
  for ply, char in ix.util.GetCharacters() do
    local faction = char:GetFaction()

    if faction == FACTION_CITIZEN then
      self.CitizenList:AddLine(char:GetName(), ply:GetNWString("cid", "NO CID"), ply:GetNWString("CivilStatus", "NO CITIZEN STATUS"))
    end
  end

  self.CitizenList.OnRowSelected = function(lst, index, row)
    local SelectName = row:GetValue(1)
    local ply = ix.util.FindPlayer(SelectName)

    if ply then
      self.ModelPanel:SetModel(ply:GetModel())
      local eyepos = self.ModelPanel.Entity:GetBonePosition(self.ModelPanel.Entity:LookupBone("ValveBiped.Bip01_Head1"))
      self.ModelPanel:SetFOV(120)
      self.ModelPanel:SetCamPos(Vector(18, 0, 65))
      self.ModelPanel:SetLookAt(eyepos)
      self.ModelPanel:SetAnimated(false)

      self.ModelPanel.LayoutEntity = function(pan, ent)
        pan:RunAnimation()
      end
    end

    self.Record.DoClick = function()
      net.Start("RecordRequest")
      net.WriteEntity(ply)
      net.SendToServer()
      local TextFrame = vgui.Create("DFrame")
      TextFrame:SetSize(600, 500)
      TextFrame:Center()
      TextFrame:MakePopup()
      TextFrame:SetTitle("Record History")
      local RecordList = vgui.Create("DListView", TextFrame)
      RecordList:SetSize(580, 380)
      RecordList:SetPos(10, 30)
      RecordList:AddColumn("Type"):SetFixedWidth(100)
      RecordList:AddColumn("Reason"):SetFixedWidth(400)
      RecordList:AddColumn("Points"):SetFixedWidth(80)
      local TotalPoints = vgui.Create("RichText", TextFrame)
      TotalPoints:SetPos(10, 430)
      TotalPoints:SetSize(580, 22)
      TotalPoints:SetVerticalScrollbarEnabled(false)

      net.Receive("RecordRequest", function()
        local record = net.ReadTable()
        local lp = net.ReadInt(32)
        local vp = net.ReadInt(32)
        local totalPoints = (lp - vp)

        if record != nil then
          for i, v in pairs(record) do
            if v.TYPE != nil then
              RecordList:AddLine(v.TYPE, v.REASON, v.POINTS)
            end
          end
        end

        TotalPoints:AppendText("This Citizen has: ")

        if totalPoints >= 0 then
          TotalPoints:InsertColorChange(0, 255, 0, 255)
          TotalPoints:AppendText(totalPoints .. " Loyalty Points")
        else
          TotalPoints:InsertColorChange(255, 0, 0, 255)
          TotalPoints:AppendText(totalPoints .. " Loyalty Points")
        end
      end)

      local RemoveRecord = vgui.Create("DButton", TextFrame)
      RemoveRecord:SetSize(200, 30)
      RemoveRecord:SetPos(20, 460)
      RemoveRecord:SetText("Remove Record")
      local ViewRecord = vgui.Create("DButton", TextFrame)
      ViewRecord:SetSize(110, 30)
      ViewRecord:SetPos(245, 460)
      ViewRecord:SetText("View Details")
      local AddRecord = vgui.Create("DButton", TextFrame)
      AddRecord:SetSize(200, 30)
      AddRecord:SetPos(380, 460)
      AddRecord:SetText("Add Record")

      AddRecord.DoClick = function()
        local RecordInput = vgui.Create("DFrame")
        RecordInput:SetSize(500, 100)
        RecordInput:Center()
        RecordInput:MakePopup()
        RecordInput:SetTitle("")
        local Type = vgui.Create("DComboBox", RecordInput)
        Type:SetSize(120, 30)
        Type:SetPos(10, 30)
        Type:SetValue("Record Type")
        Type:AddChoice("Loyalty")
        Type:AddChoice("Violation")
        local TextInput = vgui.Create("DTextEntry", RecordInput)
        TextInput:SetSize(325, 50)
        TextInput:SetPos(125, 35)
        TextInput:SetMultiline(true)
        local Points = vgui.Create("DNumberWang", RecordInput)
        Points:SetSize(40, 20)
        Points:SetPos(70, 65)
        local TextButton = vgui.Create("DButton", RecordInput)
        TextButton:SetPos(460, 50)
        TextButton:SetSize(22, 22)
        TextButton:SetText("")
        TextButton:SetIcon("icon16/tick.png")

        TextButton.DoClick = function()
          local RecordType = Type:GetSelected()
          local Reason = TextInput:GetText()
          local Amount = Points:GetValue()
          if RecordType == nil or Reason == "" then
            LocalPlayer():EmitSound("buttons/combine_button_locked.wav")
          else
            RecordList:AddLine(RecordType, Reason, Amount)
            RecordInput:Close()
            net.Start("Record")
            net.WriteEntity(ply)
            net.WriteString(RecordType)
            net.WriteString(Reason)
            net.WriteInt(Amount, 32)
            net.SendToServer()
            LocalPlayer():EmitSound("npc/roller/code2.wav")
          end
        end
      end

      RecordList.OnRowSelected = function(list, ind, record)
        RemoveRecord.DoClick = function()
          RecordList:RemoveLine(ind)
          net.Start("RecordRemove")
          net.WriteEntity(ply)
          net.WriteString(record:GetColumnText(1))
          net.WriteString(record:GetColumnText(2))
          net.WriteInt(record:GetColumnText(3), 32)
          net.SendToServer()
        end

        ViewRecord.DoClick = function()
          local RecordView = vgui.Create("DFrame")
          RecordView:SetSize(450, 150)
          RecordView:Center()
          RecordView:MakePopup()
          RecordView:SetTitle("Record")
          local RecordContents = vgui.Create("RichText", RecordView)
          RecordContents:SetPos(10, 30)
          RecordContents:Dock(FILL)
          local type = record:GetColumnText(1)
          local reason = record:GetColumnText(2)
          local points = record:GetColumnText(3)

          if type == "Violation" then
            RecordContents:InsertColorChange(155, 5, 5, 255)
            RecordContents:AppendText("Record Type: " .. type .. "\n \n")
          elseif type == "Loyalty" then
            RecordContents:InsertColorChange(30, 165, 15, 255)
            RecordContents:AppendText("Record Type: " .. type .. "\n \n")
          end

          RecordContents:InsertColorChange(255, 220, 0, 255)
          RecordContents:AppendText("Reason for Record: " .. reason .. "\n \n")
          RecordContents:InsertColorChange(0, 210, 230, 255)
          RecordContents:AppendText("Points: " .. points)

          function RecordContents:PerformLayout()
            self:SetFontInternal("DermaDefaultBold")
          end
        end
      end
    end

    self.PrintCID.DoClick = function()
      LocalPlayer():EmitSound("buttons/combine_button7.wav", 75, 100)
      LocalPlayer():Notify("You have printed a new CID for " .. SelectName)

      if ply:GetNWString("cid") != nil then
        net.Start("PrintCID")
        net.WriteEntity(ply)
        net.SendToServer()
      end
    end

    self.BOL.DoClick = function()
      local menu = DermaMenu()

      menu:AddOption("Add", function()
        if table.HasValue(PLUGIN.BOL, ply:GetName()) == false then
          net.Start("BOL")
          net.WriteEntity(ply)
          net.WriteBool(true)
          net.SendToServer()
        else
          LocalPlayer():EmitSound("buttons/combine_button_locked.wav", 75, 120)
        end
      end)

      menu:AddOption("Remove", function()
        if table.HasValue(PLUGIN.BOL, ply:GetName()) == false then
          LocalPlayer():EmitSound("buttons/combine_button_locked.wav", 75, 120)
        else
          net.Start("BOL")
          net.WriteEntity(ply)
          net.WriteBool(false)
          net.SendToServer()
        end
      end)

      menu:Open(gui.MouseX(), gui.MouseY(), false)
    end

    self.SetStatus.DoClick = function()
      local menu = DermaMenu()
      for i, v in ipairs({
        [1] = "STABLE",
        [2] = "MARGINAL",
        [3] = "FRACTURED"
      }) do
        menu:AddOption(v, function()
          net.Start("ChangedStatus")
          net.WriteEntity(ply)
          net.WriteString(v)
          net.SendToServer()
          self:RefreshList()
        end)
      end

      menu:Open(gui.MouseX(), gui.MouseY(), false)
    end

    self.Notes.DoClick = function()
      local TextFrame = vgui.Create("DFrame")
      TextFrame:SetSize(400, 600)
      TextFrame:Center()
      TextFrame:MakePopup()
      TextFrame:SetTitle(SelectName .. "'s Notes")
      TextFrame:SetDraggable(false)

      TextFrame.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(130, 130, 130, 220))
      end

      local TextEntry = vgui.Create("DTextEntry", TextFrame)
      TextEntry:SetPos(10, 50)
      TextEntry:SetSize(380, 500)
      TextEntry:SetMultiline(true)

      if ply:GetNWString("Notes") == nil then
        TextEntry:SetPlaceholderText("Insert Notes")
      else
        TextEntry:SetText(ply:GetNWString("Notes"))

        TextFrame.OnClose = function()
          if TextEntry:GetText() != ply:GetNWString("Notes") then
            net.Start("NewNotes")
            net.WriteEntity(ply)
            net.WriteString(TextEntry:GetText())
            net.SendToServer()
          end
        end
      end
    end
    self.SetCID.DoClick = function()
      local TextFrame = vgui.Create("DFrame")
      TextFrame:SetSize(600, 80)
      TextFrame:Center()
      TextFrame:MakePopup()
      TextFrame:SetTitle("")
      TextFrame:SetDraggable(false)
      TextFrame.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(75,75,75,220))
      end
      local TextEntry = vgui.Create("DTextEntry", TextFrame)
      TextEntry:SetPos(150, 40)
      TextEntry:SetSize(300, 30)
      TextEntry:SetNumeric(true)
      TextEntry:SetPlaceholderText("99999")

      local Label = vgui.Create("DLabel", TextFrame)
      Label:SetPos(240, 10)
      Label:SetSize(130, 20)
      Label:SetText("Insert New CID (5 digits)")

      local TextButton = vgui.Create("DButton", TextFrame)
      TextButton:SetPos(455, 43)
      TextButton:SetSize(22, 24)
      TextButton:SetText("")
      TextButton:SetIcon("icon16/tick.png")
      TextButton.DoClick = function()
        local NewCID = TextEntry:GetInt()
        if NewCID != nil then
          if NewCID <= 99999 and NewCID >= 11111 then
            net.Start("ChangedCID")
              net.WriteEntity(ply)
              net.WriteInt(NewCID, 32)
            net.SendToServer()
            self:RefreshList()
          else
            LocalPlayer():EmitSound("buttons/combine_button_locked.wav")
          end
        end
      end
    end
  end
end

function PANEL:RefreshList()
  timer.Simple(0.15, function()
    self.CitizenList:Clear()

    for ply, char in ix.util.GetCharacters() do
      local faction = char:GetFaction()
      if faction == FACTION_CITIZEN then
        self.CitizenList:AddLine(char:GetName(), ply:GetNWString("cid", "NO CID"), ply:GetNWString("CivilStatus", "NO CITIZEN STATUS"))
      end
    end
  end)
end

vgui.Register("ixMPFTerminal", PANEL, "DFrame")
