local PLUGIN = PLUGIN


function PLUGIN:SaveATM()

  for _, v in ipairs(ents.FindByClass("ix_atm")) do
    local data = {}

    data[#data + 1] = {
      v:GetPos(),
      v:GetAngles()
    }
  end
  
  ix.data.Set("atmMachines", data)
end

function PLUGIN:LoadATM()

  for _, v in ipairs(ix.data.Get("atmMachines") or {} ) do
    local atm = ents.Create("ix_atm")

    atm:SetPos(v[1])
    atm:SetAngles(v[2])
    atm:Spawn()
  end
end
