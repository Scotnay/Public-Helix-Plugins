local CMETA = ix.meta.character
local META = FindMetaTable( "Player" )

function CMETA:GetSanity()
  return self:GetData( "sanity", 100 )
end

function META:GetSanity()
  local character = self:GetCharacter()

  if ( character ) then
    return character:GetSanity()
  end
end

if ( SERVER ) then
  function CMETA:SetSanity( var )
    var = math.Clamp( var, 0, 100 )

    self:SetData( "sanity", var )
  end

  function META:SetSanity(var)
    local character = self:GetCharacter()

    if ( character ) then
      character:SetSanity( var )
    end
  end
end
