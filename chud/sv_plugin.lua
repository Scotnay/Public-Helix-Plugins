local PLUGIN = PLUGIN

-- Record Network strings
util.AddNetworkString( "nRecordRequest" )
util.AddNetworkString( "nRecordEdit" )

-- Command Terminal Network strings
util.AddNetworkString( "nRankEdit" )

-- MPF Terminal Network strings
util.AddNetworkString( "nSetCID" )
util.AddNetworkString( "nSetBOL" )
util.AddNetworkString( "nSetNotes" )

-- Ent Use Network strings
util.AddNetworkString( "nMPFTerminal" )
util.AddNetworkString( "nCivTerminal" )
util.AddNetworkString( "nCommandTerminal" )

-- Data Update Network strings
util.AddNetworkString( "nUpdateSociostatus" )
util.AddNetworkString( "nUpdateBOL" )

-- Client -> Server Updates
util.AddNetworkString( "nClientUpdateStatus" )
util.AddNetworkString( "nClientUpdateBOL" )

function PLUGIN:SaveTerminals()
  local regTerms = { }
  for i, v in ipairs( ents.FindByClass( "ix_mpfterminal" ) ) do
    regTerms[ #regTerms + 1 ] = {
      v:GetPos(),
      v:GetAngles()
    }
  end
  ix.data.Set( "chud_terminals", regTerms )

  local hcTerms = { }
  for i, v in ipairs( ents.FindByClass( "ix_hcterminal" ) ) do
    hcTerms[ #hcTerms + 1 ] = {
      v:GetPos(),
      v:GetAngles()
    }
  end
  ix.data.Set( "chud_hcterminals", hcTerms )
end

function PLUGIN:LoadTerminals()
  local regTerms = ix.data.Get( "chud_terminals", { } )
  for i, v in ipairs( regTerms ) do
    local ent = ents.Create( "ix_mpfterminal" )
    ent:SetPos( v[ 1 ] )
    ent:SetAngles( v[ 2 ] )
    ent:Spawn()
  end

  local hcTerms = ix.data.Get( "chud_hcterminals", { } )
  for i, v in ipairs( hcTerms ) do
    local ent = ents.Create( "ix_hcterminal" )
    ent:SetPos( v[ 1 ] )
    ent:SetAngles( v[ 2 ] )
    ent:Spawn()
  end
end
