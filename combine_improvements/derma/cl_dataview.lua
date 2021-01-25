local PLUGIN = PLUGIN

local PANEL = {}


function PANEL:Init()
  self:SetSize(750, 550)
  self:Center()
  self:MakePopup()
  self:SetTitle("Citizen Data")
  self.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(30,30,30, 230))
  end

  self.list = vgui.Create("DListView", self)
  self.list:SetSize(450, 500)
  self.list:SetPos(0, 0)
  self.list:AddColumn("Type")
  self.list:AddColumn("Reason")
  self.list:AddColumn("Points")
  self.list.Paint = function(self, w, h)
    draw.RoundedBox(2,0,0,w,h,Color(75,75,75,220))
  end
end


function PANEL:PopulateInfo(civ, civRecord, civPoints)

  self.ModelPanel = vgui.Create("DModelPanel", self)
  self.ModelPanel:SetPos(475, 100)
  self.ModelPanel:SetSize(250, 275)
  self.ModelPanel:SetModel(civ:GetModel())
  local eyepos = self.ModelPanel.Entity:GetBonePosition(self.ModelPanel.Entity:LookupBone("ValveBiped.Bip01_Head1"))
  self.ModelPanel:SetFOV(70)
  self.ModelPanel:SetCamPos(Vector(18, 0, 65))
  self.ModelPanel:SetLookAt(eyepos)
  self.ModelPanel:SetAnimated(false)

  self.viewInfo = vgui.Create("DButton", self)
  self.viewInfo:SetSize(250, 40)
  self.viewInfo:SetPos(475, 480)
  self.viewInfo:SetText("View Record Info")

  self.viewNotes = vgui.Create("DButton", self)
  self.viewNotes:SetSize(250, 40)
  self.viewNotes:SetPos(475, 420)
  self.viewNotes:SetText("View Citizen's Notes")
  self.viewNotes.DoClick = function()
    local TextFrame = vgui.Create("DFrame")
    TextFrame:SetSize(400, 600)
    TextFrame:Center()
    TextFrame:MakePopup()
    TextFrame:SetTitle(civ:GetName() .. "'s Notes")
    TextFrame:SetDraggable(false)

    TextFrame.Paint = function(self, w, h)
      draw.RoundedBox(2, 0, 0, w, h, Color(130, 130, 130, 220))
    end

    local TextEntry = vgui.Create("DTextEntry", TextFrame)
    TextEntry:SetPos(10, 50)
    TextEntry:SetSize(380, 500)
    TextEntry:SetMultiline(true)

    if civ:GetNWString("Notes") == nil then
      TextEntry:SetPlaceholderText("Insert Notes")
    else
      TextEntry:SetText(civ:GetNWString("Notes"))
      TextFrame.OnClose = function()
        if TextEntry:GetText() != civ:GetNWString("Notes") then
          net.Start("NewNotes")
          net.WriteEntity(civ)
          net.WriteString(TextEntry:GetText())
          net.SendToServer()
        end
      end
    end
  end

  self.TotalPoints = vgui.Create("RichText", self)
  self.TotalPoints:SetPos(10, 515)
  self.TotalPoints:SetSize(580, 22)
  self.TotalPoints:SetVerticalScrollbarEnabled(false)

  self.TotalPoints:InsertColorChange(150, 150, 150, 255)
  self.TotalPoints:AppendText("This Citizen has: ")

  local lp = civPoints.lp
  local vp = civPoints.vp

  totalPoints = vp - lp

  if totalPoints >= 0 then
    self.TotalPoints:InsertColorChange(0, 255, 0, 255)
    self.TotalPoints:AppendText(totalPoints .. " Loyalty Points")
  else
    self.TotalPoints:InsertColorChange(255, 0, 0, 255)
    self.TotalPoints:AppendText(totalPoints .. " Loyalty Points")
  end

  for i, v in pairs(civRecord) do
    list:AddLine(v.TYPE, v.REASON, v.POINTS)
  end

  self.list.OnRowSelected = function(lst, index, record)
    self.viewInfo.DoClick = function()
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

vgui.Register("ixDataView", PANEL, "DFrame")
