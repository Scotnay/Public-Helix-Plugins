local PLUGIN = PLUGIN

PLUGIN.SocioStatus = PLUGIN.SocioStatus or "GREEN"
PLUGIN.BOL = PLUGIN.BOL or { }
PLUGIN.FactionCalls = PLUGIN.FactionCalls or { }

surface.CreateFont(
  "CHudLabel",
  {
    font = "BudgetLabel",
    extended = true,
    size = ScreenScale( 7.5 ),
    weight = 200,
    antialias = true,
    shadow = true,
    outline = true,
    scanlines = 2
  }
)

-- Clientside network receives
local function nUpdateSociostatus()
  local newStatus = net.ReadString()

  if ( !PLUGIN.SocioColors[ newStatus ] ) then
    return
  end

  PLUGIN.SocioStatus = newStatus
end
net.Receive( "nUpdateSociostatus", nUpdateSociostatus )

local function nUpdateBOL()
  local bolTable = net.ReadTable()

  PLUGIN.BOL = bolTable

  local oldTab = PLUGIN.BOLPos

  PLUGIN.BOLPos = { }

  -- Small loop so we can remove old positions
  for i, v in ipairs( PLUGIN.BOL ) do
    if ( oldTab[ v ] ) then
      PLUGIN.BOLPos[ v ] = oldTab[ v ]
    end
  end
end
net.Receive( "nUpdateBOL", nUpdateBOL )

local function nMPFTerminal()
  vgui.Create( "ixMPFTerminal" )
end
net.Receive( "nMPFTerminal", nMPFTerminal )

local function nCommandTerminal()
  vgui.Create( "ixHighCommand" )
end
net.Receive( "nCommandTerminal", nCommandTerminal )

-- Clientside hooks
local client = LocalPlayer()

function PLUGIN:ShouldDrawLocalPlayer()
  return client.bShouldDraw
end

local col_white = Color( 255, 255, 255 )
local col_green = Color( 0, 255, 0 )
local col_yellow = Color( 255, 255, 0 )
local col_red = Color( 255, 0, 0 )

function PLUGIN:HUDPaint()
  if ( !IsValid( client ) ) then
    client = LocalPlayer()
  end

  if ( !client:IsCombine() ) then
    return
  end

  local socioColor = self.SocioColors[ self.SocioStatus ]

  local blackTSin = TimedSin( 0.5, 120, 200, 0 )

  if ( self.SocioStatus == "BLACK" ) then
    socioColor = Color( blackTSin, blackTSin, blackTSin )
  end

  local projectedThreat = 0
  local area = LocalPlayer():GetArea() or "NULL"
  draw.SimpleText( "Sociostatus: " .. self.SocioStatus, "CHudLabel", ScrW() - 10, 5, socioColor, TEXT_ALIGN_RIGHT )
  draw.SimpleText( "Current Location: " .. area, "CHudLabel", ScrW() - 10, 85, col_white, TEXT_ALIGN_RIGHT )
  draw.DrawText( "BOL:", "CHudLabel", ScrW() - 10, 125, col_white, TEXT_ALIGN_RIGHT )

  self.BOLPos = self.BOLPos or { }

  local y = 165

  for i, v in ipairs( self.BOL ) do
    if ( !IsValid( v ) ) then
      table.remove( self.BOL, i )
      continue
    end

    self.BOLPos[ v ] = Lerp( 0.02, self.BOLPos[v] or 140, y )
    draw.SimpleText( v:GetName(), "CHudLabel", ScrW() - 10, self.BOLPos[ v ], col_white, TEXT_ALIGN_RIGHT )

    y = y + 40
  end

  for i, v in ipairs( player.GetAll() ) do
    if ( v == client ) then
      continue
    end

    if ( !v:Alive() ) then
      continue
    end

    local character = v:GetCharacter()

    if ( !character ) then
      continue
    end

    local faction = character:GetFaction()

    if ( !faction ) then
      continue
    end

    if ( !self.FactionCalls[ faction ] ) then
      continue
    end

    local suc, res, mult = pcall( self.FactionCalls[ faction ], v )

    if ( suc and res ) then
      projectedThreat = projectedThreat + mult
    end


    if ( !suc ) then
      ErrorNoHalt( "Warning callback has failed for " .. v:GetName() .. "'s faction!\n" .. res .. "\n" )
    end
  end
  self.threat = self.threat or projectedThreat
  self.nextTick = self.nextTick or 0

  if ( self.nextTick < CurTime() ) then
    self.threat = math.Approach( self.threat, projectedThreat, math.random( 1, 8 ) )
    self.nextTick = CurTime() + 0.25
  end

  local color = col_green

  local tsin = TimedSin( 1.25, 120, 200, 0 )

  if ( self.threat >= 40 and self.threat < 75 ) then
    color = col_yellow
  elseif ( self.threat >= 75 and self.threat <= 100 ) then
    color = col_red
  elseif ( self.threat > 100 ) then
    color = Color(tsin, tsin, tsin)
  end
  draw.DrawText( "Threat Assessment: " .. self.threat .. "%", "CHudLabel", ScrW() - 10, 45, color, TEXT_ALIGN_RIGHT )
end
