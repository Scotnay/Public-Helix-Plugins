local PLUGIN = PLUGIN


local PANEL = {}


local Colours = {
  FRACTURED = Color(255, 0, 0),
  MARGINAL = Color(255, 255, 0),
  STABLE = Color(0, 255, 0)
}


function PANEL:Init()
  self:SetSize(700, 550)
  self:Center()
  self:MakePopup()
  self:ShowCloseButton(false)
  self:SetDeleteOnClose(true)
  self:SetTitle("")

  self.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(30, 30, 30, 230))
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

  self.Name = vgui.Create("DLabel", self)
  self.Name:SetPos(275, 50)
  self.Name:SetFont("DermaLarge")


  self.ModelPanel = vgui.Create("DModelPanel", self)
  self.ModelPanel:SetPos(200, 50)
  self.ModelPanel:SetSize(300, 350)


  self.CurrentStatus = vgui.Create("DLabel", self)
  self.CurrentStatus:SetPos(20, 425)
  self.CurrentStatus:SetFont("BudgetLabel")


  self.CitizenID = vgui.Create("DLabel", self)
  self.CitizenID:SetPos(20, 450)
  self.CitizenID:SetFont("BudgetLabel")


  self.Wallet = vgui.Create("DLabel", self)
  self.Wallet:SetPos(20, 475)
  self.Wallet:SetFont("BudgetLabel")


  self.Employment = vgui.Create("DLabel", self)
  self.Employment:SetPos(20, 500)
  self.Employment:SetFont("BudgetLabel")


  self.Violation = vgui.Create("DLabel", self)
  self.Violation:SetPos(300, 425)
  self.Violation:SetFont("BudgetLabel")


  self.Loyalty = vgui.Create("DLabel", self)
  self.Loyalty:SetPos(300, 450)
  self.Loyalty:SetFont("BudgetLabel")

end



function PANEL:PopulateInfo()
  local status = LocalPlayer():GetCharacter():GetData("CivilStatus", "NO STATUS")
  local statcol = Colours[status] or Color(255, 0, 0)
  local CID = LocalPlayer():GetCharacter():GetData("cid", "NO CID")


  self.Name:SetFont("DermaLarge")
  self.Name:SetText("Welcome: \n" .. LocalPlayer():GetName())
  self.Name:SizeToContents()


  self.ModelPanel:SetModel(LocalPlayer():GetModel())
  local eyepos = self.ModelPanel.Entity:GetBonePosition(self.ModelPanel.Entity:LookupBone("ValveBiped.Bip01_Head1"))
  self.ModelPanel:SetFOV(70)
  self.ModelPanel:SetCamPos(Vector(18, 0, 65))
  self.ModelPanel:SetLookAt(eyepos)
  self.ModelPanel:SetAnimated(false)


  self.CurrentStatus:SetText("Your current Civil Status: " .. status)
  self.CurrentStatus:SetTextColor(statcol)
  self.CurrentStatus:SizeToContents()


  self.CitizenID:SetText("Your current CID: " .. CID)
  self.CitizenID:SizeToContents()


  self.Wallet:SetText("Your current amount of tokens is: " .. LocalPlayer():GetCharacter():GetMoney())
  self.Wallet:SizeToContents()


  self.Employment:SetText("Your current Employment is: " .. team.GetName(LocalPlayer():Team()))
  self.Employment:SizeToContents()


  self.Violation:SetText("Your current Violation Points are: " .. LocalPlayer():GetCharacter():GetData("vp", "N/A"))
  self.Violation:SizeToContents()


  self.Loyalty:SetText("Your current Loyalty Points are: " .. LocalPlayer():GetCharacter():GetData("lp", "N/A"))
  self.Loyalty:SizeToContents()
end




vgui.Register("ixCitizenTerminal", PANEL, "DFrame")
