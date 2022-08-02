AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.PrintName = "High Command Terminal"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.bNoPersist = true
ENT.RenderGroup = RENDERGROUP_OPAQUE
if ( SERVER ) then

  function ENT:Initialize()
      self:SetModel( "models/props_combine/breenconsole.mdl" )
      self:SetSolid(SOLID_VPHYSICS)
      self:SetUseType(SIMPLE_USE)
  end

  function ENT:Use( act )
    if ( !act:IsCombine() ) then
      act:Notify( "You are not a CP" )
      act:EmitSound( "buttons/combine_button_locked.wav", 75, 120 )
    elseif ( !act:CIIsHC() ) then
      act:Notify( "You are not permitted to access this terminal!" )
      act:EmitSound( "buttons/combine_button_locked.wav", 75, 120 )
    else
      net.Start( "nCommandTerminal" ); net.Send( act )
      act:EmitSound( "buttons/combine_button5.wav", 75, 120 )
      act.bShouldBypassPVS = true
    end
  end
end

if ( CLIENT ) then
  local blur = Material( "pp/blurscreen" )
  -- Just copied from IX base blur stuff because fuck performance
  local function DrawBlur( x, y, w, h, col, pos, ang )
    ix.util.ResetStencilValues()
    render.SetStencilEnable( true )
      render.SetStencilWriteMask( 27 )
      render.SetStencilTestMask( 27 )
      render.SetStencilFailOperation( STENCILOPERATION_KEEP )
      render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
      render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
      render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
      render.SetStencilReferenceValue( 27 )

      cam.Start3D2D( pos, ang, 0.11 )
        surface.SetDrawColor( col )
        surface.DrawRect( x, y, w, h )
      cam.End3D2D()

      render.SetStencilReferenceValue( 34 )
      render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
      render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
      render.SetStencilReferenceValue( 27 )

      cam.Start2D()
      -- I don't care for your 'noBlur' :)
        surface.SetMaterial( blur )
        surface.SetDrawColor( 255, 255, 255, 255 )

        local scrW, scrH = ScrW(), ScrH()
        local x2, y2 = x/scrW, y/scrH
        local w2, h2 = ( x + scrW )/scrW, ( y + scrH )/scrH

        for i = -0.2, 1, 0.2 do
          blur:SetFloat( "$blur", i * 5 )
          blur:Recompute()

          render.UpdateScreenEffectTexture()
          surface.DrawTexturedRectUV( x, y, scrW, scrH, x2, y2, w2, h2 )
        end
      cam.End2D()
    render.SetStencilEnable( false )
  end

  function ENT:Draw()
	local client = LocalPlayer()

    self.lerp = self.lerp or 0
    self.alpha = self.alpha or 0
    self:DrawModel()

    -- You really don't want to know...
    if ( self:GetNetVar( "bHeld" ) or ( client:GetEyeTrace().Entity == self and input.IsKeyDown( input.GetKeyCode( input.LookupBinding( "+menu_context" ) ) ) ) ) then
      return
    end

    local dlight = DynamicLight( self:EntIndex() )

    if ( dlight ) then
      dlight.pos = self:GetPos() + self:GetAngles():Up() * 45 + self:GetAngles():Forward() * 15
  		dlight.r = 0
  		dlight.g = 100
  		dlight.b = 255
  		dlight.brightness = 1.5
  		dlight.Decay = 250
  		dlight.Size = 326
  		dlight.DieTime = CurTime() + 1
    end

    local distSquared = 128 ^ 2

    if ( client:GetPos():DistToSqr( self:GetPos() ) > distSquared ) then
      self.lerp = Lerp( 0.02, self.lerp or 0, 0 )
      self.alpha = Lerp( 0.02, self.alpha or 0, 0 )
    else
      self.lerp = Lerp( 0.02, self.lerp or 0, 1 )
      self.alpha = Lerp( 0.02, self.alpha or 0, 255 )
    end
    local ang = self:GetAngles()
    local lerp = self.lerp or 0
    local pos = self:GetPos() + ang:Up() * 49 + ang:Right() * -3.4 + ang:Forward() * -10.25
    ang:RotateAroundAxis( ang:Forward(), 43 )


    cam.Start3D2D( pos, ang, 0.11 )
      DrawBlur( 0, 0, 160, 80 * lerp, Color( 90 * lerp, 90 * lerp, 90 * lerp, self.alpha/3.5 ), pos, ang )
      draw.SimpleText( "MPF Command Terminal", "BudgetLabel", 80, 5, Color( 255, 255, 255, 255 * lerp ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
    cam.End3D2D()

    if ( client:ShouldDrawLocalPlayer() ) then
      client:DrawModel() -- Stops text overlapping in third person
    end
  end
end
