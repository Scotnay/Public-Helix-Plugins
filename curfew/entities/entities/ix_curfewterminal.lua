AddCSLuaFile()

local PLUGIN = PLUGIN

ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.PrintName = "Curfew Terminal"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.bNoPersist = true
ENT.RenderGroup = RENDERGROUP_BOTH

if ( SERVER ) then
  function ENT:Initialize()
      self:SetModel( "models/props_combine/combine_intmonitor003.mdl" )
      self:SetSolid( SOLID_VPHYSICS )
      self:SetUseType( SIMPLE_USE )
  end
else
  local blur = Material( "pp/blurscreen" )
  -- Just modified from IX base blur stuff because fuck performance
  -- I just want my epic gamer blurs
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
    self:DrawModel()
    -- I'm so sorry for the pain I've caused with this if statement
    -- But it's just a workaround because I'm too lazy to fix stuff
    if ( self:GetNetVar( "bHeld", false ) or ( LocalPlayer():GetEyeTrace().Entity == self and input.IsKeyDown( input.GetKeyCode( input.LookupBinding( "+menu_context" ) ) ) ) ) then
      return
    end

    self.curSched = PLUGIN:GetSchedule()

    local ang = self:GetAngles()
    local pos = self:GetPos()
    +
    ( ang:Right() * 16 )
    +
    ( ang:Forward() * 24 )
    +
    ( ang:Up() * 48 )

    if ( !LocalPlayer():IsLineOfSightClear( self ) ) then
      return
    end

    ang:RotateAroundAxis( ang:Right(), -90 )
    ang:RotateAroundAxis( ang:Up(), 90 )

    local w, h = 310, 425

    local texCol = Color( 255, 255, 255 )

    cam.Start3D2D( pos, ang, 0.1 )
      DrawBlur( 0, 0, w, h, Color( 5, 5, 40, 50 ), pos, ang )
      draw.SimpleText( "Daily Schedule", "Trebuchet24", w/2, 20, texCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      draw.SimpleText( "Current Scheduled Event: " .. self.curSched, "Trebuchet18", w/2, 45, texCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      draw.SimpleText( "Current Time: " .. PLUGIN:GetTimeFormatted(), "Trebuchet18", w/2, 60, texCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      draw.SimpleText( "Today's Schedule:", "Trebuchet18", 5, 90, texCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

      local y = 105

      for i, v in ipairs( PLUGIN.schedule ) do
        local timeStartForm = os.date( "%H : %M", v[ 2 ] * 60 )
        local timeEndForm = os.date( "%H : %M", v[ 3 ] * 60 )
        draw.SimpleText( v[ 1 ] .. ": " .. timeStartForm .. " - " .. timeEndForm, "Trebuchet18", 5, y, texCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        y = y + 20
      end
    cam.End3D2D()
  end
end
