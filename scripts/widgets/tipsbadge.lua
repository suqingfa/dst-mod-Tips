local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local easing = require "easing"
local Widget = require "widgets/widget"

local config_list = {
    hound = {
        scale = 0.066,
        build = "hound_ocean",
        animation = "idle",
        loop = false
    },

    antlion = {
        animation = "idle",
        loop = true
    },

    bearger = {
        scale = 0.02,
        animation = "idle_loop",
        loop = true
    },

    deerclops = {
        animation = "idle_loop",
        loop = true
    },
}

for k,v in pairs(config_list) do
    v.scale = v.scale or 0.033
    v.x = v.x or -40
    v.y = v.y or -50
    v.bank = v.bank or k
    v.build = v.build or (v.bank .. "_build")
end

local TipsBadge = Class(Widget, function(self, prefab)
    Widget._ctor(self, "TipsBadge")
    
    --self.bg = self:AddChild(Image("images/.xml", ".tex"))

    local config = config_list[prefab]

    self.head = self:AddChild(UIAnim())
    self.head:SetScale(config.scale)
    self.head:SetPosition(config.x, config.y)
    self.head:GetAnimState():SetBank(config.bank)
    self.head:GetAnimState():SetBuild(config.build)
    self.head:GetAnimState():PlayAnimation(config.animation, config.loop)

    self.num = self:AddChild(Text(NUMBERFONT, 30))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(3.5, -40.5)
end)

return TipsBadge
