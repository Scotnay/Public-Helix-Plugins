local PLUGIN = PLUGIN

local meta = ix.meta.character

function meta:ResetRecord()
  if self:GetData("CombineRecord") then
    self:SetData("CombineRecord", nil)
    print(self:GetName() .. "'s record was cleared")
  else
    print("This user had no record")
  end
end

function meta:AddRecord(type, reason, points)
  local Record = self:GetData("CombineRecord")
  local NewRecord = Record or {}
  if !Record then
    table.insert(NewRecord, {
      TYPE = type,
      REASON = reason,
      POINTS = points
    })
  else
    table.insert(NewRecord, {
      TYPE = type,
      REASON = reason,
      POINTS = points
    })
  end
  self:SetData("CombineRecord", NewRecord)

  if type == "Loyalty" then
    local CurrentLP = self:GetData("lp", 0)
    self:SetData("lp", (CurrentLP + points))
  elseif type == "Violation" then
    local CurrentVP = self:GetData("vp", 0)
    self:SetData("vp", (CurrentVP + points))
  end
end

function meta:RemoveRecord(type, reason, points)
  local Record = self:GetData("CombineRecord", nil)
  if Record then
    for i, v in pairs(Record) do
      if v.TYPE == type and v.REASON == reason and v.POINTS == points then
        table.remove(Record, i)
      end
    end
  end
  self:SetData("CombineRecord", Record)
  if type == "Loyalty" then
    local CurrentLP = self:GetData("lp", 0)
    self:SetData("lp", (CurrentLP - points))
  elseif type == "Violation" then
    local CurrentVP = self:GetData("vp", 0)
    self:SetData("vp", (CurrentVP - points))
  end
end


function meta:GetRecord()
  if self:GetData("CombineRecord") then
    return self:GetData("CombineRecord")
  else
    print("This player has no record data")
    return nil
  end
end
