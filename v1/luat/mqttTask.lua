local mqttTask = {}

_G.sys = require("sys")
local mqtt = require "mqtt"
local mqttOutMsg = require "mqttOutMsg"
local mqttInMsg = require "mqttInMsg"
local ready = false

local led = gpio.setup(7,0)
local ledStatus = false

local adcCheckTime = 0

--- MQTT连接状态
function mqttTask.isRReady()
    return ready
end

local UART_ID=2

-- 把串口配置好
uart.setup(UART_ID, 9600)


local interval = 0

sys.taskInit(function()
    uart.write(UART_ID, "mqtt init\r\n")
    -- 服务器配置信息
    local host, port, clientId = "mqtt地址", 1883, nbiot.imei()
    mqttOutMsg.set_imei(clientId);
    -- 等待联网成功
    while true do
        while not socket.isReady() do 
            if ledStatus == false then
                led(1)
                ledStatus = true
            else
                led(0)
                ledStatus = false
            end
            log.info("net", "wait for network ready\r\n")
            uart.write(UART_ID, "wait for network ready\r\n")
            sys.waitUntil("NET_READY", 1000)
        end
        
        local mqttc = mqtt.client(clientId, nil, "mqtt用户名", "mqtt密码",false)
        while not mqttc:connect(host, port) do sys.wait(2000) end
        ready = true
        led(1)
        local subscribe_topic = "nbiot/r/"..clientId   --设备订阅的主题
        log.info("net", subscribe_topic)
        uart.write(UART_ID, subscribe_topic)
        mqttOutMsg.insertMsg("nbiot/p/"..mqttOutMsg.get_imei(),"login",0,1,0);


        if mqttc:subscribe(subscribe_topic) then
            while true do
                if not mqttInMsg.proc(mqttc,uart,UART_ID) then log.error("mqttTask.mqttInMsg.proc error") break end
                if not mqttOutMsg.proc(mqttc) then log.error("mqttTask.mqttOutMsg proc error") break end
                if adcCheckTime >= 20 then
                    adc.open(2)
                    if adc.read(2) ~= nil then 
                        log.info("net", "send adc - "..adc.read(2).."\r\n")
                        mqttOutMsg.insertMsg("nbiot/p/"..mqttOutMsg.get_imei(),"adc:"..adc.read(2),0,1,0);
                        uart.write(UART_ID, "adc:"..adc.read(2))
                    else
                        log.info("net", "send adc 0 \r\n")
                        mqttOutMsg.insertMsg("nbiot/p/"..mqttOutMsg.get_imei(),"adc:0",0,1,0);
                        uart.write(UART_ID, "adc:0")
                    end
                    adc.close(2)
                    adcCheckTime = 0
                else
                    adcCheckTime = adcCheckTime+1
                end

                local data = uart.read(UART_ID, 1024)
                if data:len() > 0 then
                    temp_start = string.find(data,'$GNGGA',1)
                    temp_end = string.find(data,'\r',1)
                    temp_gga = string.sub(data,temp_start,temp_end-1)
                    if string.len(temp_gga) > 10 then
                        log.info("uart", "receive", temp_gga.."\r\n")
                        mqttOutMsg.insertMsg("nbiot/p/"..mqttOutMsg.get_imei(),"g:"..temp_gga,0,1,0);
                        uart.write(UART_ID, temp_gga..'\r\n')
                    end
                end

            end
        end
        ready = false
        led(0)
        mqttOutMsg.unInit();
        mqttc:disconnect()
        log.info("mqttTask", "mqtt loop")
        sys.wait(5000) -- 等待一小会, 免得疯狂重连
    end

end)

return mqttTask;
