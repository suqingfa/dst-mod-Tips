name = "Tips"
description = [[
提示猎狗和BOSS的到来时间
指令：
● /tips what [显示指定生物的刷新时间]
● /help tips [显示'what'的值]
]]

author = "suqf"
version = "1.5.2"

icon_atlas = "tips.xml"
icon = "tips.tex"

forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- Specify compatibility with the game!
dont_starve_compatible = true
reign_of_giants_compatible = true
dst_compatible = true
all_clients_require_mod = true


configuration_options =
{
    {
        name = "tips_method",
        label = "提示方式",
        options = {
            {description = "UI", data = 1},
            {description = "说话", data = 2},
            {description = "系统消息", data = 3},
        },
        default = 1,
    },

    {
        name = "hound",
        label = "猎狗",
        options = {
            {description = "开", data = true},
            {description = "关", data = false},
        },
        default = true,
    },

    {
        name = "deerclops",
        label = "巨鹿",
        options = {
            {description = "开", data = true},
            {description = "关", data = false},
        },
        default = true,
    },

    {
        name = "antlion",
        label = "蚁狮",
        options = {
            {description = "开", data = true},
            {description = "关", data = false},
        },
        default = true,
    },

    {
        name = "bearger",
        label = "熊獾",
        options = {
            {description = "开", data = true},
            {description = "关", data = false},
        },
        default = true,
    },

    {
        name = "klaus_sack",
        label = "克劳斯包",
        options = {
            {description = "开", data = true},
            {description = "关", data = false},
        },
        default = false,
    },

    {
        name = "malbatross",
        label = "邪天翁",
        options = {
            {description = "开", data = true},
            {description = "关", data = false},
        },
        default = false,
    },

    {
        name = "toadstool",
        label = "蟾蜍",
        options = {
            {description = "开", data = true},
            {description = "关", data = false},
        },
        default = false,
    },

    {
        name = "crabking",
        label = "帝王蟹",
        options = {
            {description = "开", data = true},
            {description = "关", data = false},
        },
        default = false,
    },

    {
        name = "dragonfly",
        label = "龙蝇",
        options = {
            {description = "开", data = true},
            {description = "关", data = false},
        },
        default = false,
    },

    {
        name = "atrium_gate",
        label = "远古大门",
        options = {
            {description = "开", data = true},
            {description = "关", data = false},
        },
        default = false,
    },

    {
        name = "beequeenhive",
        label = "巨型蜂巢",
        options = {
            {description = "开", data = true},
            {description = "关", data = false},
        },
        default = false,
    },
}