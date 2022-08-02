local META = FindMetaTable("Player")

local civTeams = PLUGIN.civFactions

function META:IsCitizen()
  return civTeams[ self:Team() ]
end

function META:CIGetID()
  local character = self:GetCharacter()

  if ( character ) then
    return character:CIGetID()
  end
end

function META:CIGetTag()
  local character = self:GetCharacter()

  if ( character ) then
    return character:CIGetTag()
  end
end

function META:CIGetRank()
  local character = self:GetCharacter()

  if ( character ) then
    return character:CIGetRank()
  end
end

function META:CIIsHC()
  local character = self:GetCharacter()

  if ( character ) then
    return character:CIIsHC()
  end
end
