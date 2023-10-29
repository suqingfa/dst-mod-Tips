name = "Tips"
description = [[
Tips for the arrival of hounds and bosses
command:
● /tips what [Show refresh time of the specified creature]
● /help tips [View the value of 'what']
]]

author = "suqf"
version = "0.0.0"

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
        label = "tips method",
        options = {
            {description = "UI", data = 1},
            {description = "talk", data = 2},
            {description = "system message", data = 3},
        },
        default = 1,
    },

    {
        name = "hound",
        label = "hound",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = true,
    },

    {
        name = "prime_mate",
        label = "prime_mate",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = true,
    },

    {
        name = "deerclops",
        label = "deerclops",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = true,
    },

    {
        name = "antlion",
        label = "antlion",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = true,
    },

    {
        name = "bearger",
        label = "bearger",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = true,
    },

    {
        name = "klaus_sack",
        label = "klaus_sack",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = false,
    },

    {
        name = "malbatross",
        label = "malbatross",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = false,
    },

    {
        name = "toadstool",
        label = "toadstool",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = false,
    },

    {
        name = "crabking",
        label = "crabking",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = false,
    },


    {
        name = "dragonfly",
        label = "dragonfly",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = false,
    },

    {
        name = "atrium_gate",
        label = "atrium_gate",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = false,
    },

    {
        name = "beequeenhive",
        label = "beequeenhive",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = false,
    },

    {
        name = "lunarrift_portal",
        label = "lunarrift_portal",
        options = {
            {description = "ON", data = true},
            {description = "OFF", data = false},
        },
        default = true,
    },
}