ITEM.name = "ID Card"
ITEM.model = Model("models/dorado/tarjeta2.mdl")
ITEM.description = "A standard Universal Union identification card."
ITEM.category = "misc"

function ITEM:IsWorker()
  return self:GetData("cwu", false)
end

function ITEM:GetModel()
  if self:IsWorker() then
    return "models/dorado/tarjeta3.mdl"
  else
    return self.model
  end
end

function ITEM:GetDescription()
  if self:IsWorker() then
    return "A standard Universal Union Worker's identification card."
  else
    return self.description
  end
end

function ITEM:GetName()
  if self:IsWorker() then
    return "Worker ID Card"
  else
    return self.name
  end
end

function ITEM:PopulateTooltip(tooltip)
  if !self:IsWorker() then
    local data = tooltip:AddRow("data")
    data:SetBackgroundColor(Color(0, 120, 230))
    data:SetText("Name: " .. self:GetData("owner_name", "UNISSUED") .. "\n" .. "CID Number: #" .. self:GetData("cid", "NO CID ISSUED"))
    data:SizeToContents()
  else
    local data = tooltip:AddRow("data")
    data:SetBackgroundColor(Color(0, 120, 230))
    data:SetText("Name: " .. self:GetData("owner_name", "UNISSUED") .. "\n" .. "Worker ID: #" .. self:GetData("cid", "NO CID ISSUED"))
    data:SizeToContents()
  end

  local data2 = tooltip:AddRow("data")
  data2:SetBackgroundColor(Color(255, 0, 0))
  data2:SetFont("BudgetLabel")
  data2:SetText("WARNING! This CID contains a UU issued RFID chip, failure to carry this ID card will result in prosecution by CCA units")
  data2:SizeToContents()
end

ITEM.functions.Assign = {
  name = "Assign CID",
  OnRun = function(item)
    local client = item.player

    local ent = client:GetEyeTrace().Entity
    if ent:IsPlayer() then
      item:SetData("owner_name", ent:GetName())
      item:SetData("cid", ent:GetNWString("cid", "ERR NO CID"))
    else
      client:Notify("You are not looking at a valid citizen")
    end
    return false
  end,


  OnCanRun = function(item)
    if item:GetData("owner_name") == nil and item:GetData("cid") == nil and item.player:IsCombine() then
      return true
    else
      return false
    end
  end
}

ITEM.functions.Assign = {
  name = "Set Worker",
  OnRun = function(item)
    item:SetData("cwu", true)
    item.player:Notify("You have made this card into a worker's card")
    return false
  end,


  OnCanRun = function(item)
    if item:GetData("cwu", false) != true and item.player:IsCombine() then
      return true
    else
      return false
    end
  end
}
