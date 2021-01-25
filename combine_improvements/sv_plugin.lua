local PLUGIN = PLUGIN


function PLUGIN:SaveCivTerminal()
  local data = {}

  for _, v in ipairs(ents.FindByClass("ix_citizenterminal")) do
    data[#data + 1] = {
      v:GetPos(),
      v:GetAngles()
    }
  end

  ix.data.Set("citizenTerminals", data)

end

function PLUGIN:SaveMPFTerminal()
  local data = {}

  for _, v in ipairs(ents.FindByClass("ix_cpterminal")) do
    data[#data + 1] = {
      v:GetPos(),
      v:GetAngles()
    }
  end

  ix.data.Set("CPTerminals", data)

end

function PLUGIN:SaveCommandTerminal()
  local data = {}

  for _, v in ipairs(ents.FindByClass("ix_commandterminal")) do
    data[#data + 1] = {
      v:GetPos(),
      v:GetAngles()
    }
  end

  ix.data.Set("commandTerminals", data)

end

function PLUGIN:LoadCivTerminal()

  for _, v in ipairs(ix.data.Get("citizenTerminals") or {} ) do
    local terminal = ents.Create("ix_citizenterminal")

    terminal:SetPos(v[1])
    terminal:SetAngles(v[2])
    terminal:Spawn()
  end

end

function PLUGIN:LoadMPFTerminal()

  for _, v in ipairs(ix.data.Get("CPTerminals") or {} ) do
    local terminal = ents.Create("ix_cpterminal")

    terminal:SetPos(v[1])
    terminal:SetAngles(v[2])
    terminal:Spawn()
  end

end

function PLUGIN:LoadCommandTerminal()

  for _, v in ipairs(ix.data.Get("commandTerminals") or {} ) do
    local terminal = ents.Create("ix_commandterminal")

    terminal:SetPos(v[1])
    terminal:SetAngles(v[2])
    terminal:Spawn()
  end

end
