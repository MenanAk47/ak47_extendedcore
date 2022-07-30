AddEventHandler('esx_addonaccount:getSharedAccount', function(name, cb)
    cb(addonaccount(name))
end)

function addonaccount(name, owner, money)
    local self = {}

    self.name  = name:gsub('society_', '')
    self.money = exports['qb-management']:GetAccount(self.name)

    self.addMoney = function(m)
        exports['qb-management']:AddMoney(self.name, m)
    end

    self.removeMoney = function(m)
        exports['qb-management']:RemoveMoney(self.name, m)
    end

    self.setMoney = function(m)
        self.removeMoney(self.money)
        self.addMoney(m)
    end

    return self
end