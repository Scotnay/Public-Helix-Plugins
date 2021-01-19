local PLUGIN = PLUGIN

function PLUGIN:LoadData()
  self:LoadATM()
end

function PLUGIN:SaveData()
  self:SaveATM()
end

util.AddNetworkString("ixATMMoney")

net.Receive("ixATMMoney", function(_, ply)
  local amount = net.ReadInt(32)
  ply:GetCharacter():EditStoredMoney(amount)
end)
