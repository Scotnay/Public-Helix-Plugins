local PLUGIN = PLUGIN

function PLUGIN:SaveCurfewTerminals()
  local data = { }

  for i, v in ipairs( ents.FindByClass( "ix_curfewterminal" ) ) do
    data[ #data + 1 ] = {
      v:GetPos(),
      v:GetAngles()
    }
  end

  ix.data.Set( "curfew_terminals", data )
end

function PLUGIN:LoadCurfewTerminals()
  local data = ix.data.Get( "curfew_terminals", { } )

  for i, v in ipairs( data ) do
    local ent = ents.Create( "ix_curfewterminal" )
    ent:SetPos( v[ 1 ] )
    ent:SetAngles( v[ 2 ] )
    ent:Spawn()
  end
end
