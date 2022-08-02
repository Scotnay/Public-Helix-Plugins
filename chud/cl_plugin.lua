local PLUGIN = PLUGIN

-- Use this function to add extra or more faction calls, examples below
function PLUGIN:AddFactionCall( enum, call )
  self.FactionCalls[ enum ] = call
end

local col_white = Color( 255, 255, 255 )
local col_red = Color( 255, 0, 0 )

local function fCitizen( client )
  if ( !IsValid( client ) ) then
    return
  end
  local bone = client:LookupBone( "ValveBiped.Bip01_Head1" )
  local pos
  -- In case a model doesn't have a headbone
  if ( !bone ) then
    pos = client:GetPos() + Vector(0, 0, 72)
  else
    pos = client:GetBonePosition( bone ) + Vector( 0, 0, 14 )
  end

  -- This is for determining if the threat amount should be added on
  local inRange = false
  -- The amount of threat to add on can be editied further down the line
  local mult = 5

  if ( client:IsWepRaised() ) then
    mult = mult + 15
  end

  if ( !LocalPlayer():IsLineOfSightClear( client ) ) then
    return
  end

  local distSquared = 224^2

  local toScreen = pos:ToScreen()

  if ( ( LocalPlayer():GetPos() + LocalPlayer():OBBCenter() ):DistToSqr( client:GetPos() ) > distSquared ) then
    client.mult = Lerp( 0.02, client.mult or 0, 0 )
  else
    client.mult = Lerp( 0.02, client.mult or 0, 1 )
    inRange = true
  end

  -- Give some wiggle room so it doesn't just dissapear
  toScreen.x = math.Clamp( toScreen.x, -200, ScrW() + 200 )
  toScreen.y = math.Clamp( toScreen.y, -50, ScrH() + 50 )

  -- Using lerp correctly really doesn't matter too much here since the toScreen changes every frame
  client.toScreenX = Lerp( 0.06, client.toScreenX or toScreen.x, toScreen.x )
  client.toScreenY = Lerp( 0.06, client.toScreenY or toScreen.y, toScreen.y )

  -- I don't understand Matrixes so...
  local m = Matrix()
  local mPos = Vector( client.toScreenX, client.toScreenY )
  m:Translate( mPos )
  local scale = client.mult * ( Vector( 1, 1, 1 ) * ( 90/LocalPlayer():GetPos():Distance( client:GetPos() ) ) )
  m:Scale( scale )
  m:Translate( -mPos )

  local bol = client:GetNetVar( "bol", false )

  local cid = client:GetNetVar( "cid", "NULL" )
  local col = !bol and col_white or col_red
  local status = !bol and "MONITOR" or "WANTED"

  mult = mult + ( bol and 30 or 0 )

  cam.PushModelMatrix( m )
    draw.SimpleText( "<:: CID: #" .. cid .. " ::>", "CHudLabel", client.toScreenX, client.toScreenY, col_white, TEXT_ALIGN_CENTER )
    draw.SimpleText( "<:: Status: " .. status .. " ::>", "CHudLabel", client.toScreenX, client.toScreenY + 30, col, TEXT_ALIGN_CENTER )
  cam.PopModelMatrix()

  -- If it gets to the end make sure you almost always return the inRange or mult value
  return inRange, mult
end
PLUGIN:AddFactionCall( FACTION_CITIZEN, fCitizen )

local function fMetropolice( client )
  if ( !IsValid( client ) ) then
    return
  end
  local bone = client:LookupBone( "ValveBiped.Bip01_Head1" )
  local pos
  if ( !bone ) then
    pos = client:GetPos() + Vector( 0, 0, 72 )
  else
    pos = client:GetBonePosition( bone ) + Vector( 0, 0, 14 )
  end

  local inRange = false
  local mult = -15

  if ( !LocalPlayer():IsLineOfSightClear( client ) ) then
    return
  end

  local distSquared = 224^2

  local toScreen = pos:ToScreen()

  if ( LocalPlayer():GetPos():DistToSqr( client:GetPos() ) > distSquared ) then
    client.mult = Lerp( 0.02, client.mult or 0, 0 )
  else
    client.mult = Lerp( 0.02, client.mult or 0, 1 )
    inRange = true
  end

  toScreen.x = math.Clamp( toScreen.x, -200, ScrW() + 200 )
  toScreen.y = math.Clamp( toScreen.y, -50, ScrH() + 50 )


  client.toScreenX = Lerp( 0.06, client.toScreenX or toScreen.x, toScreen.x )
  client.toScreenY = Lerp( 0.06, client.toScreenY or toScreen.y, toScreen.y )

  local m = Matrix()
  local mPos = Vector( client.toScreenX, client.toScreenY )
  m:Translate( mPos )
  local scale = client.mult * ( Vector(1, 1, 1) * ( 90/LocalPlayer():GetPos():Distance( client:GetPos() ) ) )
  m:Scale( scale )
  m:Translate( -mPos )

  local rank = client:CIGetRank() or "NULL"

  local id = client:CIGetID() or "NULL"

  local tag = client:CIGetTag() or "NULL"


  local useTag = ix.config.Get( "Use Taglines", false )
  cam.PushModelMatrix( m )
    draw.SimpleText( "<:: Unit Rank: " .. rank .. " ::>", "CHudLabel", client.toScreenX, client.toScreenY + 30, col_white, TEXT_ALIGN_CENTER )
    if ( useTag ) then
      draw.SimpleText( "<:: Unit ID: " .. tag .. "-" .. id .. " ::>", "CHudLabel", client.toScreenX, client.toScreenY, col_white, TEXT_ALIGN_CENTER )
    else
      draw.SimpleText( "<:: Unit ID: " .. id .. " ::>", "CHudLabel", client.toScreenX, client.toScreenY, col_white, TEXT_ALIGN_CENTER )
    end
  cam.PopModelMatrix()
  return inRange, mult
end
PLUGIN:AddFactionCall( FACTION_MPF, fMetropolice )
