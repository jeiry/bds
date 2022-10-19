local mqttInMsg = {}

_G.sys = require("sys")

local mqttOutMsg = require "mqttOutMsg"


--- MQTT客户端数据接收处理
-- @param mqttc
-- @return 处理成功返回true，处理出错返回false
-- @usage mqttInMsg.proc(mqttc)
function mqttInMsg.proc(mqttc,uart,UART_ID)
    local result,data
    while true do
        result, data = mqttc:receive(2000)
        if result then
            --在此处编写自己的处理消息程序
             --dup,topic,id,payload,qos,retain
            log.info("mqttc", "get message from server", data.payload or "nil", data.topic)
            uart.write(UART_ID, data.payload)
            local jsondata,result,errinfo = json.decode(data.payload)--判断是不是json
            
			if  result and type(jsondata)=="table" then -- 是json数据
                
			else
				--非JSON数据
			end
        else
            break;
        end

        
        --如果mqttOutMsg中有等待发送的数据，则立即退出本循环
        if mqttOutMsg.waitForSend() then return true end
    end
	
    return result or data=="timeout"
end

return mqttInMsg;
