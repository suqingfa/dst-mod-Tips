name = "Tips"
description = [[
Tips for the arrival of hounds and bosses
command:
● /tips what [Show refresh time of the specified creature]
● /help tips [View the value of 'what']
]]

author = "suqf"
version = "1.2.3"

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
        name = "tick_rate",
        label = "tick rate",
        hover = "The interval at which the server communicates with the guest. The smaller the value, the more accurate the display time, but the network pressure on the server is large.",
        options = {
                    {description = "1", data = 1},
                    {description = "2", data = 2},
                    {description = "3", data = 3},
                    {description = "4", data = 4},
                    {description = "5", data = 5},
                    {description = "10", data = 10},
                    {description = "20", data = 20},
                    {description = "30", data = 30},
                    {description = "60", data = 60},
                },
        default = 1,
    },
}