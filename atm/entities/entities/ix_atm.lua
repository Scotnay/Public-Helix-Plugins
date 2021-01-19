AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.PrintName = "ATM"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH



if SERVER then

  function ENT:Initialize()
    self:SetModel(ix.config.Get("ATM Model", "models/props_combine/breenconsole.mdl"))
    self:SetSolid(SOLID_VPHYSICS)
  end

  function ENT:Use(act)
    self:SetUseType(SIMPLE_USE)
    self:EmitSound("buttons/combine_button7.wav")

    netstream.Start(act, "ixATMUse", {act})
  end


end

if CLIENT then

  function ENT:Draw()
    self:DrawModel()
  end

end
