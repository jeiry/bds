-- LuaTools需要PROJECT和VERSION这两个信息


PROJECT = "mqttairm2m"
VERSION = "1.0.0"

-- sys库是标配
_G.sys = require("sys")

local mqttTask = require "mqttTask"

-- 用户代码已结束---------------------------------------------
-- 结尾总是这一句
sys.run()
-- sys.run()之后后面不要加任何语句!!!!!
