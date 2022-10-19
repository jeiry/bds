local mqttOutMsg = {}

_G.sys = require("sys")

local sendQueue = {} --接收数据缓存
local this_imei=nil;
-- MQTT
local msgQueue = {}  --数据发送的消息队列

--设置imei
function mqttOutMsg.set_imei(imei)
    this_imei = imei; --设置IMEI
end

--获取imei
function mqttOutMsg.get_imei()
    return this_imei; --获取IMEI
end

--插入消息
--topic:发布的主题
--payload:发布的消息
--qos:消息等级 0或1或2
--retain:消息是否让服务器保留 0(不保留)  1(保留)
--restart:发送完成是否复位模块 0(不复位) 1(复位)
function mqttOutMsg.insertMsg(topic,payload,qos,retain,restart)
    table.insert(msgQueue,{topic=topic,payload=payload,qos=qos,retain=retain,restart=restart})
end

--- 清空对象存储
function mqttOutMsg.unInit()
    while #msgQueue>0 do
        local outMsg = table.remove(msgQueue,1)
    end
end
--- MQTT客户端是否有数据等待发送
-- @return 有数据等待发送返回true，否则返回false
-- @usage mqttOutMsg.waitForSend()
function mqttOutMsg.waitForSend()
    return #msgQueue > 0
end
--- MQTT客户端数据发送处理
-- @param mqttClient，MQTT客户端对象
-- @return 处理成功返回true，处理出错返回false
-- @usage mqttOutMsg.proc(mqttClient)
function mqttOutMsg.proc(mqttClient)
    while #msgQueue>0 do--有消息
        local outMsg = table.remove(msgQueue,1)--提取一条消息
        local result = mqttClient:publish(outMsg.topic,outMsg.payload,outMsg.qos,outMsg.retain)--发送
        if not result then 
            return --发送失败返回空
        else
            if  outMsg.restart == 1  then
                rtos.reboot();
			end
        end
    end
    return true
end


return mqttOutMsg;
