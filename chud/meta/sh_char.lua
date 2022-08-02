local PLUGIN = PLUGIN

local META = ix.meta.character

local civTeams = PLUGIN.civFactions

function META:IsCitizen()
  return civTeams[ self:GetFaction() ]
end

if ( SERVER ) then
  --[[
  Method to add a record
  type | string : The type of record, can either be "Loyalty" or "Violation" (or something else if you know what you're doing)
  reason | string : The reason for the added record
  points | int : The amount of points that are to be added to each section

  first arg can also be a table with the structure of type, reason, and points
  ]]--

  function META:AddRecord( type, reason, points )
    local newRecord = { }

    if ( istable( type ) ) then
      newRecord = type
    else
      newRecord.type = type
      newRecord.reason = reason
      newRecord.points = points
    end


    local record = self:GetData( "Record", { } )

    record[ #record + 1 ] = newRecord

    self:SetData( "Record", record )

    self:SyncPoints()
  end

  --[[
  Method to remove a record
  ind | int : Index of the record table we are removing
  ]]--

  function META:RemoveRecord( ind )
    local record = self:GetData( "Record", { } )

    if ( record[ ind ] ) then
      table.remove( record, ind )
      self:SetData( "Record", record )
    end

    self:SyncPoints()
  end

  --[[
  Method used to clear a characters record
  ]]--

  function META:ClearRecord()
    self:SetData( "Record", { } )

    self:SyncPoints()
  end

  --[[
  Method used to sync a characters points
  ]]

  function META:SyncPoints()
    local record = self:GetRecord()
    local points = 0
    for i, v in ipairs( record ) do
      if ( v.type == "Loyalty" ) then
        points = points + v.points
      else
        points = points - v.points
      end
    end

    self:GetPlayer():SetNetVar( "points", points )
  end
end

--[[
Method to return a characters record
]]--

function META:GetRecord()
  return self:GetData( "Record", { } )
end

--[[
Method to get a units Number ID
]]--

-- Prefixed with CI so I don't accidentally overwrite another method
function META:CIGetID()
  local name = self:GetName()
  local offSet = ix.config.Get( "CP ID Offset", 11 )

  local id = string.match( name, "%d+", offSet )

  return id
end

--[[
Method to get a units Tagline
]]

function META:CIGetTag()
  local name = self:GetName()

  for i, v in ipairs( PLUGIN.divisions ) do
    if ( string.match( name, v ) ) then
      return v
    end
  end
end

--[[
Method to get a unit rank
]]

function META:CIGetRank()
  local name = self:GetName()

  for i, v in pairs( PLUGIN.ranks ) do
    if ( string.match( name, i ) ) then
      return i
    end
  end
end

local SC = Schema
function META:CIIsHC()
  local bCanUpdate = false

  local updateRanks = {}

  for i, v in pairs( PLUGIN.ranks ) do
    if ( v ) then
      updateRanks[ #updateRanks + 1 ] = i
    end
  end

  for i, v in ipairs(updateRanks) do
    if ( SC:IsCombineRank( self:GetName(), v ) ) then
      bCanUpdate = true
      break
    end
  end

  return bCanUpdate
end
