local PLUGIN = PLUGIN

AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.PrintName = "Command Terminal"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.bNoPersist = true
ENT.RenderGroup = RENDERGROUP_BOTH


if SERVER then

  function ENT:Initialize()
      self:SetModel("models/props_combine/combine_interface001.mdl") -- models/props_combine/breenconsole.mdl
      self:SetSolid(SOLID_VPHYSICS)
  end


  function ENT:SetupDataTables()
      self:NetworkVar("String", 0, "UserName")
  end



  function ENT:Use(act)
    self:SetUseType(SIMPLE_USE)
    local char = act:GetCharacter()
    local hc
    for _, v in ipairs(PLUGIN.Ranks) do
      if v[4] == true and string.match(act:GetName(), v[1]) then
        hc = true
        break
      else
        hc = false
      end
    end
    if (!char:IsCombine()) then
      act:Notify("You are not a CP")
      act:EmitSound("buttons/combine_button_locked.wav", 75, 120)
    elseif char:IsCombine() and !hc then
      act:Notify("You are not a high enough rank")
      act:EmitSound("buttons/combine_button_locked.wav", 75, 120)
      --act:EmitSound("buttons/combine_button5.wav", 75, 120)
    elseif char:IsCombine() and hc then
      netstream.Start(act, "HCTerminalUse")
      act:EmitSound("buttons/combine_button5.wav", 75, 120)
    end
  end

end

if CLIENT then
  function ENT:Draw() -- Credits to ZeMysticalTaco for code
    self:DrawModel()

    local ang = self:GetAngles()
    local pos = self:GetPos() + ang:Up() * 48 + ang:Right() * 10 + ang:Forward() * -2.3

    ang:RotateAroundAxis(ang:Right(), -42)
    ang:RotateAroundAxis(ang:Up(), 90)
    cam.Start3D2D(pos, ang, 0.11)
    local width, height = 145, 77
    surface.SetDrawColor(Color(16, 16, 16))
    surface.DrawRect(0, 0, width, height)
    surface.SetDrawColor(Color(255, 255, 255, 16))

    surface.DrawRect(0, height / 2 + math.sin(CurTime() * 4) * height / 2, width, 1)
    local alpha = 191 + 64 * math.sin(CurTime() * 4)
    draw.SimpleText("Command Terminal", "BudgetLabel", width / 2, 25, Color(90, 210, 255, alpha), TEXT_ALIGN_CENTER)
    draw.SimpleText("Waiting for Unit", "BudgetLabel", width / 2, height - 16, Color(205, 255, 180, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()

  end

end
