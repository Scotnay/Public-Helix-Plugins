local PANEL = { }

local function CursorStop( pan )
  pan:SetCursor( "blank" )

  for i, v in pairs(pan:GetChildren()) do
    CursorStop( v )
  end
end

function PANEL:Init()
  ix.gui.mpfTerminal = self

  self:SetSize( ScrW()/1.3, ScrH()/1.3 )
  self:Center()
  self:MakePopup()
  local w, h = self:GetSize()

  self.list = vgui.Create( "DListView", self )
  self.list:SetSize( w/2, h )
  self.list:DockMargin( 5, 5, 5, 5 )
  self.list:Dock( LEFT )
  self.list:SetDataHeight( h/24 )

  self.list:AddColumn( "Name" )
  self.list:AddColumn( "CID" ):SetFixedWidth( 150 )

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

    local notes = ent:GetNetVar( "notes", nil )

    -- Used to set whether or not buttons should be active
    par.selected = true
    par.selectedEnt = ent

    par.dockPanel:SetModel( ent )
    par.dockPanel.text:SetInfo( ent, notes )
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

  function self.dockPanel:Paint( w, h )
    surface.SetDrawColor( 35, 35, 35, 245 )
    surface.DrawRect( 0, 0, w, h )
  end
  local dock = self.dockPanel

  dock.modelPanel = vgui.Create( "DModelPanel", dock )
  dock.modelPanel:SetSize( w/3, h/3 )
  dock.modelPanel:SetPos( w/12, 15 )

  local cam = dock.modelPanel:GetCamPos()
  cam:Rotate( Angle( 0, -35, 0 ) )

  function dock:SetModel( ent )
    self.modelPanel:SetModel( ent:GetModel() )
    self.modelPanel:SetLookAt( dock.modelPanel.Entity:GetBonePosition( dock.modelPanel.Entity:LookupBone( "ValveBiped.Bip01_Head1" ) ) )
    self.modelPanel:SetFOV( 30 )
  end

  function dock.modelPanel:LayoutEntity()
    return
  end

  local oldDraw = dock.modelPanel.Paint

  local mat = Material( "effects/com_shield002a" )

  function dock.modelPanel:Paint( w, h )
    surface.SetDrawColor( 25, 25, 25 )
    surface.DrawRect( 0, 0, w, h )

    if ( self.Entity ) then
      oldDraw( self, w, h )
      surface.SetDrawColor( 255, 255, 255 )
      surface.SetMaterial( mat )
      surface.DrawTexturedRect( 0, 0, w, h )
    end

    surface.SetDrawColor( 0, 0, 0 )
    surface.DrawOutlinedRect( 0, 0, w, h, 2 )
  end

  dock.textDock = vgui.Create( "Panel", dock )
  dock.textDock:SetSize( w/2 - 40, h/2 - 40 )
  dock.textDock:SetPos( 10, h/2 )

  function dock.textDock:Paint( w, h )
    surface.SetDrawColor( 50, 50, 50 )
    surface.DrawRect( 0, 0, w, h )

    surface.SetDrawColor( 0, 0, 0 )
    surface.DrawOutlinedRect( 0, 0, w, h )
  end

  dock.text = vgui.Create( "RichText", dock.textDock )
  dock.text:Dock( FILL )

  function dock.text:PerformLayout()
    self:SetFontInternal( "Trebuchet24" )
  end

  function dock.text:SetInfo( ent, notes )
    self:SetText( "" )
    self:InsertColorChange( 255, 255, 255, 255 )

    -- This is used later incase we need to refresh stored stuff
    self.curNotes = notes

    local name = ent:GetName()
    self:AppendText( "Subject Name:\n" .. name .. "\n\n" )

    local character = ent:GetCharacter()

    local desc = character:GetDescription()
    self:AppendText( "Physical Description:\n" .. desc .. "\n\n" )

    local points = ent:GetNetVar( "points", 0 )

    if ( points < 0 ) then
      self:InsertColorChange( 255, 0, 0, 255 )
    else
      self:InsertColorChange( 0, 255, 0, 255 )
    end
    self:AppendText( "Civil Credits: " .. points .. "\n\n" )

    local bol = ent:GetNetVar( "bol", false )
    if ( bol ) then
      self:InsertColorChange( 255, 0, 0, 255 )
      bol = "WANTED"
    else
      self:InsertColorChange( 255, 255, 255, 255 )
      bol = "MONITOR"
    end
    self:AppendText( "Response Status: " .. bol .. "\n\n\n" )

    self:InsertColorChange( 255, 255, 255, 255 )
    self:AppendText( "Notes:\n" )
    if ( notes ) then
      self:AppendText( notes )
    else
      self:AppendText( ent:GetNetVar( "notes", "N/A" ) )
    end
  end

  dock.record = vgui.Create( "DButton", dock )
  dock.record:SetSize( w/8, h/18 )
  dock.record:SetPos( w/32, h/2.5 )
  dock.record:SetText( "View Record" )

  local col = ix.config.Get( "color", Color( 0, 110, 230 ) )

  function dock.record:Paint( w, h )
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

  function dock.record:DoClick()
    local par = self:GetParent():GetParent()
    local ent = par.selectedEnt
    if ( !par.selected ) then
      return
    end
    net.Start( "nRecordRequest" )
      net.WriteUInt( ent:EntIndex(), 8 )
    net.SendToServer()
  end

  local function nRecordRequest()
    local record = net.ReadTable()
    local ent = Entity( net.ReadUInt( 8 ) )

    local panel = vgui.Create( "DFrame" )
    panel:SetSize( ScrW()/2, ScrH()/2 )
    panel:Center()
    panel:MakePopup()
    panel:SetTitle( ent:GetName() .. "'s Record" )

    local pW, pH = panel:GetSize()

    local list = vgui.Create( "DListView", panel )
    list:Dock( FILL )
    list:SetDataHeight( pH/18 )
    list:AddColumn( "Type" ):SetFixedWidth( pW/8 )
    list:AddColumn( "Points" ):SetFixedWidth( pW/16 )
    list:AddColumn( "Reason" )

    function list:Paint( w, h )
      surface.SetDrawColor(35, 35, 35, 245)
      surface.DrawRect( 0, 0, w, h )
    end

    for i, v in ipairs( list.Columns ) do
      function v.Header:Paint( w, h )
        surface.SetDrawColor( 120, 120, 120 )
        surface.DrawRect( 2, 2, w - 4, h - 4 )
      end
    end

    list.records = { }

    for i, v in ipairs( record ) do
      list:AddLine( v.type, v.points, v.reason )

      list.records[ i ] = v
    end

    function list:OnRowSelected( ind, row )
      panel.selected = ind

      for i, v in ipairs( self:GetLines() ) do
        v.selected = false
      end

      row.selected = true
    end

    local function PaintRecord()
      for i, v in ipairs( list:GetLines() ) do
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
          surface.DrawRect( 2, (h - h/8) + 2, (w * self.mult) - 4, h/6 )
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
    PaintRecord()

    local addRecord = vgui.Create( "DButton", panel )
    addRecord:SetSize( 0, pH/18 )
    addRecord:SetText( "Add Record" )
    addRecord:DockMargin( 0, 0, 0, 15 )
    addRecord:Dock( BOTTOM )

    function addRecord:DoClick()
      self.record = { }

      local frame = vgui.Create( "DFrame" )
      frame:SetSize( ScrW()/3, ScrH()/1.75 )
      frame:MakePopup()
      frame:Center()
      frame:SetTitle( "Add Record" )

      local info = vgui.Create( "Panel", frame )
      info:DockMargin( 0, 0, 0, 5 )
      info:SetSize( 0, 30 )
      info:Dock( TOP )
      function info:Paint( w, h )
        surface.SetDrawColor( 55, 55, 55 )
        surface.DrawRect( 0, 0, w, h )
        draw.SimpleText( "Input Record Detials", "Trebuchet24", 5, h/2, Color( 255, 255, 255 ), nil, TEXT_ALIGN_CENTER )
      end

      local input = vgui.Create( "DTextEntry", frame )
      input:Dock( FILL )
      input:SetPaintBackground( false )
      input:SetMultiline( true )
      input:SetTextColor( Color( 255, 255, 255 ) )
      input:SetFont( "Trebuchet24" )

      local oldPaint = input.Paint

      function input:Paint( w, h )
        self.col = self.col or 55

        if ( self:HasFocus() ) then
          self.col = Lerp( 0.02, self.col, 120 )
        else
          self.col = Lerp( 0.02, self.col, 55 )
        end

        surface.SetDrawColor( self.col, self.col, self.col, 245 )
        surface.DrawRect( 0, 0, w, h )

        oldPaint( self, w, h )
      end

      local finish = vgui.Create( "DButton", frame )
      finish:SetText( "Add Record" )
      finish:Dock( BOTTOM )

      function finish:Paint( w, h )
        surface.SetDrawColor( 20, 20, 20 )
        surface.DrawRect( 0, 0, w, h )
      end

      local type = vgui.Create( "DComboBox", frame )
      type:DockMargin( 0, 10, 0, 10 )
      type:Dock( BOTTOM )
      type:AddChoice( "Loyalty" )
      type:AddChoice( "Violation" )
      type:SetValue( "Select Record Type" )
      type:SetTextColor( Color( 0, 0, 0 ) )

      function type:Paint( w, h )
        surface.SetDrawColor( 255, 255, 255 )
        surface.DrawRect( 0, 0, w, h )
      end

      local points = vgui.Create( "DNumberWang", frame )
      points:DockMargin( 0, 10, 0, 10 )
      points:SetSize( 0, h/48 )
      points:Dock( BOTTOM )

      function finish.DoClick()
        local sType = type:GetSelected()
        local sReason = input:GetText()
        local sPoints = points:GetValue()

        sReason = string.Trim( sReason, " " )

        if ( !sType ) then
          return
        end

        if ( sPoints < 0 ) then
          LocalPlayer():Notify( "You cannot use negative amount of points, set type instead.")
          return
        end

        net.Start( "nRecordEdit" )
          net.WriteUInt( ent:EntIndex(), 8 )
          net.WriteBool( false )
          net.WriteString( sType )
          net.WriteString (sReason )
          net.WriteUInt( sPoints, 8 )
        net.SendToServer()

        frame:Remove()

        list:AddLine( sType, sPoints, sReason )

        -- The paint methods assigned to records are only called on panel creation
        -- This just re-assigns it to all the new ones
        PaintRecord()

        local info = dock.text
        local oldNotes = info.curNotes or "N/A"
        -- Short timer to make sure data is updated
        timer.Simple( 0.25, function()
          if ( IsValid( info ) ) then
            info:SetInfo( ent, oldNotes )
          end
        end )
      end
    end

    local removeRecord = vgui.Create( "DButton", panel )
    removeRecord:SetSize( 0, pH/18 )
    removeRecord:SetText( "Remove Record" )
    removeRecord:DockMargin( 0, 0, 0, 15 )
    removeRecord:Dock( BOTTOM )

    function removeRecord.DoClick()
      local selectedInd
      for i, v in ipairs( list:GetLines() ) do
        if ( v.selected ) then
          selectedInd = i
        end
      end

      if ( !selectedInd ) then
        return
      end

      net.Start( "nRecordEdit" )
        net.WriteUInt( ent:EntIndex(), 8 )
        net.WriteBool( true )
        net.WriteUInt( selectedInd, 8 )
      net.SendToServer()

      list:RemoveLine( selectedInd )

      local info = dock.text
      local oldNotes = info.curNotes or "N/A"
      -- Short timer to make sure data is updated
      timer.Simple( 0.25, function()
        if ( IsValid( info ) ) then
          info:SetInfo( ent, oldNotes )
        end
      end )
    end

    local viewRecord = vgui.Create( "DButton", panel )
    viewRecord:SetSize( 0, pH/18 )
    viewRecord:SetText( "View Details" )
    viewRecord:DockMargin( 0, 15, 0, 15 )
    viewRecord:Dock( BOTTOM )

    function viewRecord:DoClick()
      if ( !panel.selected ) then
        return
      end
      local view = vgui.Create( "DFrame" )
      view:SetSize( ScrW()/6, ScrH()/3 )
      view:MakePopup()
      view:Center()
      view:SetTitle( "Record Details" )

      local data = vgui.Create( "RichText", view )
      data:Dock( FILL )
      function data:PerformLayout()
        self:SetFontInternal( "Trebuchet24" )
      end


      local details = list.records[ panel.selected ]

      if ( details.type == "Loyalty" ) then
        data:InsertColorChange( 0, 220, 0, 255 )
      else
        data:InsertColorChange( 220, 0, 0, 255 )
      end
      data:AppendText( "Record Type: " .. details.type .. "\n\n" )

      data:InsertColorChange( 255, 255, 255, 255 )
      data:AppendText( "Points: " .. details.points .. "\n\n" .. "Reason:\n" .. details.reason )
    end
  end
  net.Receive( "nRecordRequest", nRecordRequest )

  dock.notes = vgui.Create( "DButton", dock )
  dock.notes:SetSize( w/8, h/18 )
  dock.notes:SetPos( w/5.5, h/2.5 )
  dock.notes:SetText( "Edit Notes" )
  function dock.notes:Paint( w, h )
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
      surface.DrawRect( 0, h - (h/12), w * self.mult, h/10 )
    end

    local textCol = Color( self.textCol, self.textCol, self.textCol, self.textCol )
    draw.SimpleText( self:GetText(), "Trebuchet24", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    return true
  end

  function dock.notes:DoClick()
    local par = self:GetParent():GetParent()

    local ent = par.selectedEnt

    if ( !IsValid( ent ) ) then
      return
    end

    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "Edit Notes" )
    frame:SetSize( ScrW()/4, ScrH()/2 )
    frame:Center()
    frame:MakePopup()

    local input = vgui.Create( "DTextEntry", frame )
    input:Dock( FILL )
    input:SetMultiline( true )
    input:SetPaintBackground( false )
    input:SetTextColor( Color( 255, 255, 255 ) )
    input:SetFont( "Trebuchet24" )

    local info = par.dockPanel.text
    input:SetText( info.curNotes or "" )

    local oldPaint = input.Paint

    function input:Paint( w, h )
      self.col = self.col or 55

      if ( self:HasFocus() ) then
        self.col = Lerp( 0.02, self.col, 120 )
      else
        self.col = Lerp( 0.02, self.col, 55 )
      end

      surface.SetDrawColor( self.col, self.col, self.col, 245 )
      surface.DrawRect( 0, 0, w, h )

      oldPaint( self, w, h )
    end

    local button = vgui.Create( "DButton", frame )
    button:SetText( "Append Notes" )
    button:DockMargin( 5, 5, 5, 5 )
    button:Dock( BOTTOM )

    function button:DoClick()
      local newNotes = input:GetText()

      net.Start( "nSetNotes" )
        net.WriteUInt( ent:EntIndex(), 8 )
        net.WriteString( newNotes )
      net.SendToServer()
      frame:Remove()

      timer.Simple( 0.25, function()
        if ( IsValid( info ) ) then
          info:SetInfo( ent, newNotes )
        end
      end )
    end
  end

  dock.setBOL = vgui.Create( "DButton", dock )
  dock.setBOL:SetSize( w/8, h/18 )
  dock.setBOL:SetPos( w/3, h/2.5 )
  dock.setBOL:SetText( "Set Response Status" )
  function dock.setBOL:Paint( w, h )
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
      surface.DrawRect( 0, h - (h/12), w * self.mult, h/10 )
    end

    local textCol = Color( self.textCol, self.textCol, self.textCol, self.textCol )
    draw.SimpleText( self:GetText(), "Trebuchet24", w/2, h/2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    return true
  end

  function dock.setBOL:DoClick()
    local par = self:GetParent():GetParent()

    local ent  = par.selectedEnt


    if ( !IsValid( ent ) ) then
      return
    end

    local info = par.dockPanel.text
    timer.Simple( 0.25, function()
      if ( IsValid( info ) ) then
        info:SetInfo( ent )
      end
    end )

    net.Start( "nClientUpdateBOL" )
      net.WriteUInt( ent:EntIndex(), 8 )
      net.WriteBool( ent:GetNetVar( "bol", false ) )
    net.SendToServer()
  end


  self.close = vgui.Create( "DButton", self )
  self.close:SetSize(h/64, h/64)
  self.close:SetPos( (w - h/64) - 5, 5 )

  local mat = Material( "icon16/cross.png" )

  function self.close:Paint( w, h )
    surface.SetMaterial( mat )
    surface.SetDrawColor( 255, 255, 255 )
    surface.DrawTexturedRect( 0, 0, w, h )

    return true
  end

  -- Using a dot instead of colon so self isn't overriden
  function self.close.DoClick()
    self:Remove()
  end

  self:PopulateCitizens()

  CursorStop( self )
end

function PANEL:PopulateCitizens()
  self.list.ents = { }
  for i, v in ipairs( player.GetAll() ) do
    if ( !v:IsCitizen() ) then
      continue
    end
    self.list:AddLine( v:GetName(), v:GetNetVar( "cid", "NULL" ) )

    self.list.ents[ #self.list.ents + 1 ] = v
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
function PANEL:Paint( w, h )
  surface.SetDrawColor( 40, 40, 40, 245 )
  surface.DrawRect( 0, 0, w, h )
end

function PANEL:PaintOver( w, h )
  self:PaintCursor( cursMat )
end

vgui.Register( "ixMPFTerminal", PANEL, "Panel" )
