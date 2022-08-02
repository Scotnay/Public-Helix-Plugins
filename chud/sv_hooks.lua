local PLUGIN = PLUGIN

PLUGIN.SocioStatus = PLUGIN.SocioStatus or "GREEN"
PLUGIN.BOL = PLUGIN.BOL or { }
PLUGIN.Players = PLUGIN.Players or { }

local numToString = {
  [ "1" ] = "one",
  [ "2" ] = "two",
  [ "3" ] = "three",
  [ "4" ] = "four",
  [ "5" ] = "five",
  [ "6" ] = "six",
  [ "7" ] = "seven",
  [ "8" ] = "eight",
  [ "9" ] = "nine",
  [ "0" ] = "zero"
}

-- Hooks

function PLUGIN:PlayerLoadedCharacter( client, character, curCharacter )
  client:SetNetVar( "cid", character:GetData("cid", "NULL" ) )
  client:SetNetVar( "notes", character:GetData( "notes", nil ) )

  -- This will also call for any faction that is included in IsCombine
  if character:IsCombine() then
    for i, v in ipairs( player.GetAll() ) do
      if ( !v:IsCombine() ) then
        continue
      end
      v:AddCombineDisplayMessage( "Cohesive for biosignal for unit " .. character:GetName() .. " has been received...", Color( 0, 255, 255 ) )
    end
  end
end

-- This is weird and hacky, but fixes issues with PVS
-- when viewing a combine unit's view
function PLUGIN:SetupPlayerVisibility( client, viewEnt )
  if ( client.bShouldBypassPVS ) then
    for i, v in ipairs( player.GetAll() ) do
      if ( v == client ) then
        continue
      end

      if ( IsValid( v ) ) then
        AddOriginToPVS( v:GetPos() + v:OBBCenter() )
      end
    end
  end
end

function PLUGIN:LoadData()
  self:LoadTerminals()
end

function PLUGIN:SaveData()
  self:SaveTerminals()
end

-- Workaround for some rendering stuff I'm too lazy to fix
function PLUGIN:PhysgunPickup( client, entity )
  if ( entity:GetClass() == "ix_hcterminal" or entity:GetClass() == "ix_mpfterminal" ) then
    entity:SetNetVar( "bHeld", true )
  end
end

function PLUGIN:PhysgunDrop( client, entity )
  if ( entity:GetNetVar("bHeld") ) then
    entity:SetNetVar( "bHeld", nil )
  end
end

-- Overriding Schema otherwise the sound will be doubled
function Schema:PlayerDeath( client, inf, attacker )
  if ( !client:IsCombine() ) then
    return
  end

  if ( !IsValid( attacker ) ) then
	return
  end

  if ( !attacker:IsWorld() ) then
    return
  end

  -- NOTE: This might be a better way of doing suicides.
  -- if ( client == attacker ) then
  --   return
  -- end

  local name = client:GetName()

  local digits = string.match( name, "%d+", ix.config.Get( "CP ID Offset", 11 ) )

  digits = string.Split( digits, "" )

  local sound = { "npc/overwatch/radiovoice/on1.wav", "npc/overwatch/radiovoice/lostbiosignalforunit.wav" }

  for i, v in ipairs( digits ) do
    if ( numToString[ v ] ) then
      sound[ #sound + 1 ] = "npc/overwatch/radiovoice/" .. numToString[ v ] .. ".wav"
    end
  end

  local rand = math.random( 1, 2 )

  if ( rand == 1 ) then
    sound[ #sound + 1 ] = "npc/overwatch/radiovoice/remainingunitscontain.wav"
  elseif ( rand == 2 ) then
    sound[ #sound + 1 ] = "npc/overwatch/radiovoice/reinforcementteamscode3.wav"
  end

  sound[ #sound + 1 ] = "npc/overwatch/radiovoice/off4.wav"

  for i, v in ipairs( player.GetAll() ) do
    if ( !v:IsCombine() ) then
      continue
    end
    ix.util.EmitQueuedSounds( v, sound, 2, nil, 75, 100 )
  end
end


-- Net Receives

local function nClientUpdateStatus( len, client )
  if ( !IsValid( client ) ) then
    return
  end

  local bCanUpdate = client:CIIsHC()

  if ( !bCanUpdate ) then
    return
  end

  local newStatus = net.ReadString()

  if ( !PLUGIN.SocioColors[ newStatus ] ) then
    return
  end

  PLUGIN.SocioStatus = newStatus

  net.Start( "nUpdateSociostatus" )
    net.WriteString( PLUGIN.SocioStatus )
  net.Broadcast()
end
net.Receive( "nClientUpdateStatus", nClientUpdateStatus )

local function nClientUpdateBOL(len, client)
  if ( !IsValid( client ) ) then
    return
  end

  local bCanUpdate = client:CIIsHC()

  if ( !bCanUpdate ) then
    return
  end

  local ent = Entity( net.ReadUInt( 8 ) )
  local bRemove = net.ReadBool()

  if ( bRemove ) then
    for i, v in ipairs( PLUGIN.BOL ) do
      if ( v == ent ) then
        table.remove( PLUGIN.BOL, i )
        ent:SetNetVar( "bol", false )
      end
    end
  else
    ent:SetNetVar( "bol", true )
    PLUGIN.BOL[ #PLUGIN.BOL + 1 ] = ent
  end

  net.Start( "nUpdateBOL" )
    net.WriteTable( PLUGIN.BOL )
  net.Broadcast()
end
net.Receive( "nClientUpdateBOL", nClientUpdateBOL )

local function nRecordRequest( len, client )
  if ( !IsValid( client ) ) then
    return
  end

  if ( !client:IsCombine() ) then
    return
  end

  local ent = Entity( net.ReadUInt( 8 ) )

  if ( !IsValid( ent ) ) then
    return
  end

  local character = ent:GetCharacter()

  net.Start( "nRecordRequest" )
    net.WriteTable( character:GetRecord() )
    net.WriteUInt( ent:EntIndex(), 8 )
  net.Send( client )
end
net.Receive( "nRecordRequest", nRecordRequest )

local function nRecordEdit( len, client )
  if ( !IsValid( client ) ) then
    return
  end

  if ( !client:IsCombine() ) then
    return
  end

  local ent = Entity( net.ReadUInt( 8 ) )
  local character = ent:GetCharacter()

  if ( !IsValid( ent ) ) then
    return
  end

  local bIsRemove = net.ReadBool()

  if ( bIsRemove ) then
    local record = net.ReadUInt( 8 )

    character:RemoveRecord( record )
  else
    local newRecord = { }

    newRecord.type = net.ReadString()
    newRecord.reason = net.ReadString()
    newRecord.points  = net.ReadUInt( 8 )

    character:AddRecord( newRecord )
  end
end
net.Receive( "nRecordEdit", nRecordEdit )

local function nSetNotes( len, client )
  if ( !IsValid( client ) ) then
    return
  end

  if ( !client:IsCombine() ) then
    return
  end

  local ent = Entity( net.ReadUInt( 8 ) )
  local notes = net.ReadString()

  if ( !IsValid( ent ) ) then
    return
  end

  ent:SetNetVar( "notes", notes )
  ent:GetCharacter():SetData( "notes", notes )
end
net.Receive("nSetNotes", nSetNotes)

local function nRankEdit( len, client )
  if ( !IsValid( client ) ) then
    return
  end

  if ( !client:IsCombine() ) then
    return
  end

  local bCanUpdate = client:CIIsHC()

  if ( !bCanUpdate ) then
    return
  end

  local ent = Entity( net.ReadUInt( 8 ) )
  local newRank = net.ReadString()

  if ( ent == client ) then
    client:Notify( "Stop it you little cunt" )
    return
  end

  if ( !ent:IsCombine() ) then
    return
  end

  local bIsRank = false

  for i, v in pairs( PLUGIN.ranks ) do
    if ( newRank == i ) then
      bIsRank = true
    end
  end

  if ( !bIsRank ) then
    return
  end

  local oldName = ent:GetName()
  local oldRank = ent:CIGetRank()

  local newName = string.Replace( oldName, oldRank, newRank )
  ent:GetCharacter():SetName( newName )
end
net.Receive( "nRankEdit", nRankEdit )

local function nCommandTerminal( len, client )
  client.bShouldBypassPVS = false
end
net.Receive( "nCommandTerminal", nCommandTerminal )

local function nSetCID( len, client )
  if ( !IsValid( client ) ) then
    return
  end

  if ( !client:IsCombine() ) then
    return
  end

  local bCanUpdate = client:CIIsHC()

  if ( !bCanUpdate ) then
    return
  end

  local ent = Entity( net.ReadUInt( 8 ) )
  if ( !IsValid( ent ) ) then
    return
  end

  local character = ent:GetCharacter()
  if ( !character ) then
    return
  end
  local cid = net.ReadString()

  character:SetData( "cid", cid )
  ent:SetNetVar( "cid", cid )
end
net.Receive( "nSetCID", nSetCID )
