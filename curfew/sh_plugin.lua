local PLUGIN = PLUGIN

PLUGIN.name = "Curfew"
PLUGIN.author = "Scotnay"
PLUGIN.description = "Adds in a simple curfew system (glorified clock) with events"

-- Name of event, time start, time end
PLUGIN.schedule = {
  { "Curfew", 1380, 360 },
  { "Ration Distribution", 360, 480,
  -- These functions are called when a schedule starts or ends, but only serverside
  -- bIsStart is obviously whether or not schedule has started or ended
  function( bIsStart )
    for i, v in ipairs( ents.FindByClass( "ix_rationdispenser" ) ) do
      v:SetEnabled( bIsStart )
    end
  end
  },
  { "Free Time", 480, 780 },
  { "Work Cycle", 780, 1020 },
  { "Free Time", 1020, 1380 }
}

function PLUGIN:GetTime()
  return GetGlobalInt( "curfewTime", 0 )
end

function PLUGIN:GetTimeFormatted()
  return os.date( "%H : %M", self:GetTime() * 60 )
end

function PLUGIN:SetTime( value )
  SetGlobalInt( "curfewTime", value )
end

function PLUGIN:GetSchedule()
  for i, v in ipairs( self.schedule ) do
    local time = self:GetTime()

    if ( v[ 2 ] > v[ 3 ] ) then
      if ( time >= v[ 2 ] or time <= v[ 3 ] ) then
        return v[ 1 ]
      end
    else
      if ( time >= v[ 2 ] and time <= v[ 3 ] ) then
        return v[ 1 ]
      end
    end
  end

  return "N/A"
end

ix.util.Include( "sv_hooks.lua" )
ix.util.Include( "cl_hooks.lua" )
ix.util.Include( "sv_plugin.lua" )

ix.config.Add( "curfewTick", 5, "Sets how many seconds a minute in game is", nil, {
  -- Waiting for a server that does 60 and has pretty much irl time
  data = { min = 1, max = 60 },
  category = "Curfew",
} )
