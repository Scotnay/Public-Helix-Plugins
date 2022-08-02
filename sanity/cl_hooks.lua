local PLUGIN = PLUGIN

local math_random = math.random

local client = LocalPlayer()

ix.bar.Add( function()
  local status = "Sane"
  local character = client:GetCharacter()

  if ( !character ) then
    return 0, "ERR"
  end

  local var = character:GetSanity()/100

  if ( var < 0.2 ) then
    status = "Insane"
  elseif ( var < 0.4 ) then
    status = "Disturbed"
  elseif ( var < 0.6 ) then
    status = "Worried"
  else
    status = status
  end

  return var, status
end, Color( 0, 200, 200 ), nil, "sanity" )

function PLUGIN:RenderScreenspaceEffects()
  if ( !IsValid( client ) ) then
    client = LocalPlayer()
    return
  end

  local character = LocalPlayer():GetCharacter()
  if ( !character ) then
    return
  end

  local sanity = character:GetSanity() / 100
  if ( !sanity ) then
    return
  end

  local colMod = {}
  colMod[ "$pp_colour_colour" ] = 0.8

  if ( sanity < 0.2) then
    colMod[ "$pp_colour_colour" ] = 0.45
  elseif ( sanity < 0.4 ) then
    colMod[ "$pp_colour_colour" ] = 0.6
  elseif ( sanity < 0.6 ) then
    colMod[ "$pp_colour_colour" ] = 0.7
  end

  DrawColorModify( colMod )
end

PLUGIN.randomMessages = {
  "Damn the world is so meh...",
  "The world sucks so much, why can't it just be better...?",
  "I wonder if things will get better...",
  "How much longer do I have to live like this..."
}

PLUGIN.events = {
  [ 1 ] = function( client )
    surface.PlaySound( "ambient/voices/squeal1.wav" )
    client:ChatNotify( "What was that sound...?" )
  end,
  [ 2 ] = function( client )
    local sound = CreateSound( client, "music/radio1.mp3" )
    sound:SetDSP( 5 )
    sound:Play()

    timer.Simple( 20, function()
      sound:FadeOut( 3 )
    end )

    client:ChatNotify( "Why... why can I hear music...?" )
  end,
  [ 3 ] = function( client )
    surface.PlaySound( "ambient/voices/playground_memory.wav" )
    client:ChatNotify( "What are those sounds...? Children...?" )
  end,
  [ 4 ] = function(client)
    local sound = CreateSound( client, "player/heartbeat1.wav" )
    sound:SetDSP( 5 )
    sound:Play()

    timer.Simple( 6, function()
      sound:FadeOut( 3 )
    end )
  end,
  [ 5 ] = function( client )
    local sound = CreateSound( client, "hl1/ambience/alien_cycletone.wav" )
    sound:SetDSP( 5 )
    sound:Play()

    timer.Simple( 12, function()
      sound:FadeOut( 3 )
    end )

    client:ChatNotify( "What is that noise...?" )
  end,
  [ 6 ] = function( client )
    local sound = CreateSound( client, "npc/stalker/breathing3.wav" )
    sound:SetDSP( 5 )
    sound:Play()

    timer.Simple( 5, function()
      sound:FadeOut( 3 )
    end )

    client:ChatNotify( "Who is breathing...?" )
  end,
  [ 7 ] = function( client )
    local sound = CreateSound( client, "buttons/combine_button_locked.wav" )
    sound:SetDSP( 38 )
    sound:Play()
    sound:FadeOut( 3 )

    ErrorNoHalt( "Get trolled noob :^)\n" )
    system.FlashWindow()
  end,
  [ 8 ] = function( client )
    local sound = CreateSound( client, "vo/episode_1/intro/vortchorus.wav" )
    sound:SetDSP(38)
    sound:Play()

    client:ScreenFade( SCREENFADE.OUT, Color( 255, 0, 0, 220 ), 2, 12 )

    timer.Simple( 9, function()
      sound:FadeOut( 7 )
      timer.Simple( 4, function()
        client:ScreenFade( SCREENFADE.IN, Color( 255, 0, 0, 220 ), 2, 2 )
      end )
    end )
  end
}

function PLUGIN:Think()
  if ( !IsValid( client ) ) then
    client = LocalPlayer()
  end

  local character = client:GetCharacter()
  if ( !character ) then
    return
  end

  if ( self:CheckSanity( character ) ) then
    return
  end


  local sanity = character:GetSanity()/100

  if ( sanity > 0.6 ) then
    self.nextEvent = CurTime() + 120
    return
  end

  self.nextEvent = self.nextEvent or CurTime() + math_random( 300, 600 )

  if ( self.nextEvent < CurTime() ) then
    local rand = math_random( 1, #self.events )

    if ( self.events[ rand ] ) then
      self.events[ rand ]( client )
    end

    self.nextEvent = CurTime() + math_random( 300, 1800 )
  end
end

function PLUGIN:HUDPaint()
  if ( !IsValid( client ) ) then
    client = LocalPlayer()
  end

  local character = client:GetCharacter()
  if ( !character ) then
    return
  end

  if ( self:CheckSanity(character) ) then
    return
  end

  local sanity = character:GetSanity()/100

  self.nextMessage = self.nextMessage or 0
  self.messages = self.messages or { }

  if ( self.nextMessage < CurTime() ) then
    -- Load of elseif...
    local chance = math_random( 90, 100 )
    local nextMessage = math_random( 500, 600 )
    if ( sanity < 0.2 and chance > 40 ) then
      self.messages[ #self.messages + 1 ] = { table.Random( self.randomMessages ), CurTime() + math_random( 12, 45 ) }
      nextMessage = math_random( 30, 120 )
    elseif ( sanity < 0.4 and chance > 60 ) then
      self.messages[ #self.messages + 1 ] = { table.Random( self.randomMessages ), CurTime() + math_random( 12, 45 ) }
      nextMessage = math_random( 300, 460 )
    elseif ( sanity < 0.6 and chance > 80 ) then
      self.messages[ #self.messages + 1 ] = { table.Random(self.randomMessages), CurTime() + math_random( 12, 45 ) }
    end
    self.nextMessage = CurTime() + nextMessage
  end

  for i, v in ipairs( self.messages ) do
    if ( v[ 2 ] < CurTime() ) then
      table.remove( self.messages, i )
    end

    if ( v.reverse == nil ) then
      local rand = math_random( -5, 5 )

      if ( rand > 0 ) then
        v.reverse = true
      else
        v.reverse = false
      end
    end

    v.x = v.x or math_random( 1, ScrW() )
    v.y = v.y or math_random( 1, ScrH() )

    v.projX = v.projX or math_random( 1, ScrW() )
    v.projY = v.projY or math_random( 1, ScrH() )

    v.x = Lerp( 0.005, v.x, v.projX )
    v.y = Lerp( 0.005, v.y, v.projY )

    local dist = math.Distance( v.x, v.y, v.projX, v.projY )

    if ( dist < 5) then
      v.projX = math_random( 1, ScrW() )
      v.projY = math_random( 1, ScrH() )
    end

    local m = Matrix()
    local pos = Vector( v.x, v.y )
    m:Translate( pos )
    m:Scale( Vector( 1, 1, 1 ) * TimedSin( 0.25, 3, 6, v[ 2 ] ) )
    m:Rotate( Angle( 0, v[ 2 ] + CurTime() * 50 * ( v.reverse and 1 or -1 ), 0 ) )
    m:Translate( -pos )

    cam.PushModelMatrix( m )
      draw.SimpleText( v[ 1 ], "BudgetLabel", v.x + math_random( -3, 3 ), v.y + math_random( -3, 3 ), Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    cam.PopModelMatrix()
  end
end

PLUGIN.dist = 64 ^ 2

local function GetPos( client )
  local tr = { }
  tr.start = client:GetPos()
  tr.endpos = client:GetPos() + Angle(0, EyeAngles().y, 0):Forward() * -224
  tr.filter = client

  return util.TraceLine( tr ).HitPos
end

function PLUGIN:PostDrawOpaqueRenderables()
  self.monsters = self.monsters or { }
  self.nextMonster = self.nextMonster or 0

  if ( !IsValid( client ) ) then
    client = LocalPlayer()
  end

  local character = client:GetCharacter()
  if ( !character ) then
    return
  end

  if ( self:CheckSanity( character ) ) then
    return
  end

  local sanity = character:GetSanity()/100

  if ( sanity > 0.2 ) then
    self.nextMonster = CurTime() + 120
  end

  if ( self.nextMonster < CurTime() ) then
    self.monsters[#self.monsters + 1] = { "models/Humans/Group01/Male_01.mdl", CurTime() + 24 }
    self.nextMonster = CurTime() + 300
    client:ChatNotify( "You feel as if something is watching you..." )
  end

  for i, v in ipairs( self.monsters ) do
    if ( v[ 2 ] < CurTime() ) then
      if ( IsValid( v.ent ) ) then
        v.ent:Remove()
      end
      table.remove( self.monsters, i )
    end


    v.ent = v.ent or ClientsideModel( v[ 1 ], RENDERGROUP_BOTH )

    if ( v.ent ) then
      v.pos = v.pos or GetPos( client )

      if ( !v.pos ) then
        continue
      end

      local trace = { }
      trace.start = EyePos()
      trace.endpos = EyePos() + EyeAngles():Forward() * (EyePos():Distance(v.pos))
      trace.filter = client
      trace = util.TraceLine(trace)

      if ( trace.HitPos:Distance( v.pos ) < 72 ) then
        v.startLook = v.startLook or CurTime() + 1.5

        if ( v.startLook < CurTime() ) then
          v.pos = LerpVector( 0.09, v.pos, LocalPlayer():GetPos() )
        end
      end

      if ( client:GetPos():DistToSqr( v.pos ) < self.dist ) then
        v.ent:Remove()
        table.remove( self.monsters, i )
        client:SetDSP( 39 )
        surface.PlaySound( "npc/stalker/go_alert2a.wav" )
        client:ScreenFade( SCREENFADE.MODULATE, Color( 0, 0, 0 ), 1, 0 )

        -- Could improve this but I'm lazy
        timer.Simple( 1, function()
          client:SetDSP( 38 )
          client:ScreenFade( SCREENFADE.PURGE, Color( 0, 0, 0, 240 ), 4, 0 )
          timer.Simple( 4, function()
            client:SetDSP( 39 )
            client:ScreenFade( SCREENFADE.MODULATE, Color(0, 0, 0), 1, 0 )
            timer.Simple( 1, function()
              client:SetDSP( 0 )
            end )
          end )
        end )
      end

      v.ang = Angle( 0, EyeAngles().y - 180, 0 )

      v.ent:SetPos( v.pos )
      v.ent:SetAngles( v.ang )
      v.ent:SetSequence( ACT_IDLE )
      v.ent:SetColor( Color( 0, 0, 0 ) )
    end
  end
end
