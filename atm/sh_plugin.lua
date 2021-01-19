local PLUGIN = PLUGIN

PLUGIN.name = "ATM"
PLUGIN.author = "Scotnay"
PLUGIN.description = "A simple ATM system for use in any schema"

ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")




ix.config.Add("ATM Model", "models/props_combine/breenconsole.mdl", "The model of the ATM", nil, {
  category = "ATM"
})

local charmet = ix.meta.character

function charmet:GetStoredMoney()
  return self:GetData("storedMoney", 0)
end

function charmet:SetStoredMoney(amount)
  self:SetData("storedMoney", amount)
end

function charmet:EditStoredMoney(amount)
  local curMoney = self:GetData("storedMoney", 0)
  local curPhysicalMoney = self:GetMoney()

  self:SetData("storedMoney", curMoney + amount)

  self:SetMoney(curPhysicalMoney - amount)
end

if CLIENT then

  netstream.Hook("ixATMUse", function(data)
    local ply = data[1]

    Derma_Query("Choose tpye", "ATM", "Withdraw", function()
      LocalPlayer():EmitSound("buttons/blip1.wav")
      Derma_StringRequest("ATM", "Please input how much you wish to withdraw\n" .. "You currently have: " .. ply:GetCharacter():GetStoredMoney() .. " " .. ix.currency.plural, "", function(text)
        local textToNum = tonumber(text, 10)
        LocalPlayer():EmitSound("buttons/button14.wav")
        if isnumber(textToNum) then
          if ply:GetCharacter():GetStoredMoney() >= textToNum and textToNum >= 0 then
            net.Start("ixATMMoney")
              net.WriteInt(-textToNum, 32)
            net.SendToServer()
            ply:Notify("You have withdrawn " .. textToNum .. " " .. ix.currency.plural)
          else
            ply:Notify("You do not have enough saved to withdraw")
          end
        else
          ply:Notify("You have not inputed a number")
        end
      end)
    end,
    "Deposit", function()
      LocalPlayer():EmitSound("buttons/blip1.wav")
      Derma_StringRequest("ATM", "Please input how much you wish to deposit\n" .. "You currently have: " .. ply:GetCharacter():GetStoredMoney() .. " " .. ix.currency.plural, "", function(text)
        local textToNum = tonumber(text, 10)
        LocalPlayer():EmitSound("buttons/button14.wav")
        if isnumber(textToNum) then
          if ply:GetCharacter():GetMoney() >= textToNum and textToNum >= 0 then
            net.Start("ixATMMoney")
              net.WriteInt(textToNum, 32)
            net.SendToServer()
            ply:Notify("You have deposited " .. textToNum .. " " .. ix.currency.plural)
          else
            ply:Notify("You do not have enough on you to deposit")
          end
        else
          ply:Notify("You have not inputed a number")
        end
      end)
    end)
  end)


  function PLUGIN:PopulateEntityInfo(ent, tooltip)
    if ent:GetClass() == "ix_atm" then
      local pop = tooltip:AddRow("name")
      pop:SetText("ATM Machine")
      pop:SetBackgroundColor(Color(0, 110, 230))
      pop:SetImportant()
      pop:SizeToContents()

      local desc = tooltip:AddRowAfter("name", "desc")
      desc:SetText("An ATM machine to store your hard earned money in")
      desc:SetBackgroundColor(Color(0, 110, 230))
      desc:SizeToContents()
    end
  end
end
