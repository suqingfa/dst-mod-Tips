name = "Tips"
description = [[
提示猎狗和BOSS的到来时间
指令：
● /tips what [显示指定生物的刷新时间]
● /help tips [显示'what'的值]
]]

author = "suqf"
version = "1.1.5"

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
        name = "tick_rate",
        label = "通信时间间隔",
        hover = "服务器与客机通信的间隔。值越小时，显示的时间越准确，但对服务器的网络压力大",
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