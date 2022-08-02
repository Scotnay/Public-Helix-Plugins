local PANEL = { }
local PLUGIN = PLUGIN

local mat = Material( "vgui/cursors/arrow" )
local function CursorStop( pan )
  pan:SetCursor( "blank" )

  pan.PaintOver = function( self, w, h )
    local x, y = self:LocalCursorPos()

    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( mat )
    surface.DrawTexturedRect( x, y, 25, 25 )
  end


  for i, v in pairs( pan:GetChildren() ) do
    CursorStop( v )
  end
end

function PANEL:Init()
  ix.gui.hcTerminal = self

  self:SetSize( ScrW()/1.5, ScrH()/1.5 )
  self:Center()
  self:MakePopup()

  local w, h = self:GetSize()

  self.list = vgui.Create( "DListView", self )
  self.list:SetSize( w/2, h )
  self.list:DockMargin( 5, 5, 5, 5 )
  self.list:Dock( LEFT )
  self.list:SetDataHeight( h/24 )

  self.list:AddColumn( "Unit Identification" )
  self.list:AddColumn( "Rank" ):SetFixedWidth( 150 )

  function self.list:Paint()
    surface.SetDrawColor( 35, 35, 35, 245 )
    surface.DrawRect( 0, 0, w, h )
  end

  function self.list:OnRowSelected( ind, row )
    for i, v in ipairs( self:GetLines() ) do
      v.selected = false
    end
    row.selected = true

    local par = self:GetParent()
    local ent = self.ents[ ind ]

    if ( !ent ) then
      return
    end

    par.selected = true
    par.selectedEnt = ent
    par.dockPanel.modelPanel:SetEnt( ent )
  end

  for i, v in ipairs( self.list.Columns ) do
    function v.Header:Paint( w, h )
      surface.SetDrawColor( 120, 120, 120 )
      surface.DrawRect( 2, 2, w - 4, h - 4 )
    end
  end

  self.dockPanel = vgui.Create( "Panel", self )
  self.dockPanel:SetSize( w/2.08 )
  self.dockPanel:DockMargin( 5, 5, 5, 5 )
  self.dockPanel:Dock( FILL )
  self.dockPanel:InvalidateLayout( true )

  function self.dockPanel:Paint( w, h )
    surface.SetDrawColor( 35, 35, 35, 245 )
    surface.DrawRect( 0, 0, w, h )
  end
  local dock = self.dockPanel

  dock.modelPanel = vgui.Create( "Panel", dock )
  dock.modelPanel:SetSize( w/2.5, h/1.75 )
  dock.modelPanel:SetPos( w/24, 15 )

  function dock.modelPanel:SetEnt( ent )
    if ( ent ) then
      self.curEnt = ent
    else
      self.curEnt = nil
    end
  end

  function dock.modelPanel:Paint( w, h )
    surface.SetDrawColor( 25, 25, 25 )
    surface.DrawRect( 0, 0, w, h )
    local x, y = self:LocalToScreen( 0, 0 )

    if ( self.curEnt and IsValid( self.curEnt ) ) then
      local ent = self.curEnt
      local pos = ent:EyePos() + ent:EyeAngles():Right() * 8 + ent:EyeAngles():Forward() * -7 + ent:EyeAngles():Up() * 0.25
      -- Little hacky method to draw localplayer in another hook
      LocalPlayer().bShouldDraw = true
      render.RenderView( {
        origin = pos,
        angles = ent:EyeAngles() + Angle( -5, -5, 0 ),
        x = x, y = y,
        w = w, h = h,
        fov = 100
      } )
      LocalPlayer().bShouldDraw = false
    end

    surface.SetDrawColor( 0, 0, 0 )
    surface.DrawOutlinedRect( 0, 0, w, h, 2 )
  end

  dock.socio = vgui.Create( "DButton", dock )
  dock.socio:SetSize( w/8, h/18 )
  dock.socio:SetPos( w/32, h/1.5 )
  dock.socio:SetText( "Set Sociostatus" )

  local col = ix.config.Get( "color", Color( 0, 110, 230 ) )

  function dock.socio:Paint( w, h )
    self.alpha = self.alpha or 0
    self.mult = self.mult or 0
    self.textCol = self.textCol or 255

    if ( self:IsHovered() ) then
      self.alpha = Lerp( 0.02, self.alpha, 255 )
      self.mult = Lerp( 0.02, self.mult, 1 )
    else
      self.alpha = Lerp( 0.02, self.alpha, 0 )
      self.mult = Lerp( 0.02, self.mult, 0 )
    end

    surface.SetDrawColor( 90, 90, 90, 245 )
    surface.DrawRect( 0, 0, w, h )

    surface.SetDrawColor( col.r, col.g, col.b, self.alpha )
      -- I know they're not even, but they don't draw correctly unless I do this
    surface.DrawRect( 0, h - (h/12), w * self.mult, h/10 )

    local textCol = Color( self.textCol, self.textCol, self.textCol, self.textCol )
    draw.SimpleText( self:GetText(), "Trebuchet24", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    return true
  end

  local status = {
    "GREEN", "BLUE", "YELLOW", "RED", "BLACK"
  }

  function dock.socio:DoClick()
    local menu = DermaMenu()

    for i, v in ipairs( status ) do
      menu:AddOption( v, function()
        net.Start("nClientUpdateStatus")
          net.WriteString( v )
        net.SendToServer()
      end )
    end

    menu:Open()
  end

  dock.cid = vgui.Create( "DButton", dock )
  dock.cid:SetSize( w/8, h/18 )
  dock.cid:SetPos( w/5.5, h/1.5 )
  dock.cid:SetText( "Manage CIDs" )
  function dock.cid:Paint( w, h )
    self.alpha = self.alpha or 0
    self.mult = self.mult or 0
    self.textCol = self.textCol or 255

    if ( self:IsHovered() ) then
      self.alpha = Lerp( 0.02, self.alpha, 255 )
      self.mult = Lerp( 0.02, self.mult, 1 )
    else
      self.alpha = Lerp( 0.02, self.alpha, 0 )
      self.mult = Lerp( 0.02, self.mult, 0 )
    end

    surface.SetDrawColor( 90, 90, 90, 245 )
    surface.DrawRect( 0, 0, w, h )

    surface.SetDrawColor( col.r, col.g, col.b, self.alpha )
    surface.DrawRect( 0, h - (h/12), w * self.mult, h/10 )

    local textCol = Color( self.textCol, self.textCol, self.textCol, self.textCol )
    draw.SimpleText( self:GetText(), "Trebuchet24", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    return true
  end

  function dock.cid:DoClick()
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( ScrW()/3, ScrH()/2 )
    frame:Center()
    frame:MakePopup()
    frame:SetTitle( "CID Manager" )

    local scroll = vgui.Create( "DScrollPanel", frame )
    scroll:Dock( FILL )

    for i, v in ipairs( player.GetAll() ) do
      if ( !v:IsCitizen() ) then
        continue
      end
      local button = vgui.Create( "DButton", scroll )
      button:DockMargin( 0, 2, 0, 2 )
      button:Dock( TOP )
      button:SetSize( 0, 90 )
      button:SetText( "Name: " .. v:GetName() .. "\nCID: " .. v:GetNetVar( "cid", "NULL" ) )

      function button:Paint( w, h )
        self.alpha = self.alpha or 0
        self.mult = self.mult or 0
        self.textCol = self.textCol or 255

        if ( self:IsHovered() ) then
          self.alpha = Lerp( 0.02, self.alpha, 255 )
          self.mult = Lerp( 0.02, self.mult, 1 )
        else
          self.alpha = Lerp( 0.02, self.alpha, 0 )
          self.mult = Lerp( 0.02, self.mult, 0 )
        end

        surface.SetDrawColor( 90, 90, 90, 245 )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( col.r, col.g, col.b, self.alpha )
        surface.DrawRect( 0, h - (h/12), w * self.mult, h/10 )

        local textCol = Color( self.textCol, self.textCol, self.textCol, self.textCol )
        draw.DrawText( self:GetText(), "Trebuchet24", w/2, h/4, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        return true
      end

      function button:DoClick()
        Derma_StringRequest( "New CID", "Set this citizen's new CID", v:GetNetVar( "cid", "NULL" ), function( text )
          if ( !string.match( text, "%d%d%d%d%d" ) ) then
            LocalPlayer():Notify( "You must specify a valid CID number!" )
            return
          end

          net.Start( "nSetCID" )
            net.WriteUInt( v:EntIndex(), 8 )
            net.WriteString( text )
          net.SendToServer()

          timer.Simple( 0, function()
            self:SetText( "Name: " .. v:GetName() .. "\nCID: " .. v:GetNetVar( "cid", "NULL" ) )
          end )
        end )
      end
    end
    CursorStop( frame )
  end

  dock.rank = vgui.Create( "DButton", dock )
  dock.rank:SetSize( w/8, h/18 )
  dock.rank:SetPos( w/3, h/1.5 )
  dock.rank:SetText( "Set Rank" )
  function dock.rank:Paint( w, h )
    local par = self:GetParent():GetParent()

    self.alpha = self.alpha or 0
    self.mult = self.mult or 0
    self.textCol = self.textCol or 150

    if ( par.selected ) then
      self.textCol = Lerp( 0.02, self.textCol, 255 )
    else
      self.textCol = Lerp( 0.02, self.textCol, 150 )
    end

    if ( self:IsHovered() ) then
      self.alpha = Lerp( 0.02, self.alpha, 255 )
      self.mult = Lerp( 0.02, self.mult, 1 )
    else
      self.alpha = Lerp( 0.02, self.alpha, 0 )
      self.mult = Lerp( 0.02, self.mult, 0 )
    end

    surface.SetDrawColor( 90, 90, 90, 245 )
    surface.DrawRect( 0, 0, w, h )

    if ( par.selected ) then
      surface.SetDrawColor( col.r, col.g, col.b, self.alpha )
      -- I know they're not even, but they don't draw correctly unless I do this
      surface.DrawRect( 0, h - (h/12), w * self.mult, h/10 )
    end

    local textCol = Color( self.textCol, self.textCol, self.textCol, self.textCol )
    draw.SimpleText( self:GetText(), "Trebuchet24", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    return true
  end

  function dock.rank.DoClick()
    if ( !self.selectedEnt ) then
      return
    end
    local menu = DermaMenu()

    for i, v in SortedPairs( PLUGIN.ranks ) do
      menu:AddOption( i, function()
        net.Start("nRankEdit" )
          net.WriteUInt( self.selectedEnt:EntIndex(), 8 )
          net.WriteString( i )
        net.SendToServer()

        timer.Simple( 0.1, function()
          self:PopulateData()
        end )
      end)
    end
    menu:Open()
  end

  self.close = vgui.Create( "DButton", self )
  self.close:SetSize( h/64, h/64 )
  self.close:SetPos( (w - h/64) - 5, 5 )

  local mat = Material( "icon16/cross.png" )

  function self.close.DoClick()
    self:Remove()
  end

  function self.close:Paint( w, h )
    surface.SetMaterial( mat )
    surface.SetDrawColor( 255, 255, 255 )
    surface.DrawTexturedRect( 0, 0, w, h )

    return true
  end

  self:PopulateData()

  CursorStop(self)
end

function PANEL:PopulateData()
  self.list:Clear()
  self.list.ents = { }
  for i, v in ipairs( player.GetAll() ) do
    if ( !v:IsCombine() ) then
      continue
    end

    local character = v:GetCharacter()
    local name = character:GetName()
    local rank = character:CIGetRank()

    if ( name and rank ) then
      local newLine = self.list:AddLine( name, rank )
      self.list.ents[ #self.list.ents + 1 ] = v

      if ( v == self.selectedEnt ) then
        newLine.selected = true
      end
    end
  end

  local col = ix.config.Get( "color", Color( 0, 110, 230 ) )

  for i, v in ipairs( self.list:GetLines() ) do
    function v:Paint( w, h )
      surface.SetDrawColor( 90, 90, 90 )
      surface.DrawRect( 2, 2, w - 4, h - 2 )

      self.alpha = self.alpha or 0
      self.mult = self.mult or 0

      if ( self:IsHovered() or self.selected ) then
        self.alpha = Lerp( 0.02, self.alpha, 255 )
        self.mult = Lerp( 0.02, self.mult, 1 )
      else
        self.alpha = Lerp( 0.02, self.alpha, 0 )
        self.mult = Lerp( 0.02, self.mult, 0 )
      end

      surface.SetDrawColor( col.r, col.g, col.b, self.alpha )
      surface.DrawRect( 2, (h - h/8) + 2, (w * self.mult) - 4, h/8 )
    end

    for i2, v2 in pairs( v.Columns ) do
      v2:SetFont( "Trebuchet24" )
      v2:SetTextColor( Color( 255, 255, 255, 20 ) )

      function v2:Think()
        self.alpha = self.alpha or 20
        if ( self:GetParent():IsHovered() or self:GetParent().selected ) then
          self.alpha = Lerp( 0.02, self.alpha, 255 )
        else
          self.alpha = Lerp( 0.02, self.alpha, 20 )
        end
        self:SetTextColor( Color( 255, 255, 255, self.alpha ) )
      end
    end
  end
end

function PANEL:PaintCursor( mat )
  local x, y = self:LocalCursorPos()

  surface.SetDrawColor( 255, 255, 255, 255 )
  surface.SetMaterial( mat )
  surface.DrawTexturedRect( x, y, 25, 25 )
end

local cursMat = Material( "vgui/cursors/arrow" )
function PANEL:PaintOver( w, h )
  self:PaintCursor( cursMat )
end

function PANEL:Paint( w, h )
  surface.SetDrawColor( 40, 40, 40, 245 )
  surface.DrawRect( 0, 0, w, h )
end

function PANEL:OnRemove()
  net.Start( "nCommandTerminal" ); net.SendToServer()
end

vgui.Register( "ixHighCommand", PANEL, "Panel" )
