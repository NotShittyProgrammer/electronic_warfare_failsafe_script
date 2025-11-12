local TICK_MS = 50
local PWM_CUT = 900
local CH      = 8       

local last_fs = false
local warned  = false

local function rc_in_fs()
  if rc and rc.in_failsafe then
    local ok, v = pcall(function() return rc:in_failsafe() end)
    if ok and v == true then return true end
  end
  return false
end

local function any_failsafe()
  if rc_in_fs() then return true end                 
  if not rc:has_valid_input() then return true end    -- втрата кадрів
  if battery and battery.has_failsafed and battery:has_failsafed() then return true end
  if vehicle and vehicle.has_ekf_failsafed and vehicle:has_ekf_failsafed() then return true end
  if arming and arming.is_failsafe then
    local ok, v = pcall(function() return arming:is_failsafe() end)
    if ok and v == true then return true end
  end
  if vehicle and vehicle.get_failsafe_mask then
    local ok, m = pcall(function() return vehicle:get_failsafe_mask() end)
    if ok and m and m ~= 0 then return true end
  end
  return false
end

function update()
  if not warned then
    local p = SRV_Channels:get_output_pwm(CH) or -1
    if p < 0 then
      gcs:send_text(4, "LUA: SERVO9 inactive. Set SERVO9_FUNCTION!=0 and enable AUX PWM.")
      warned = true
    end
  end

  local fs = any_failsafe()

  if fs then
    if not last_fs then gcs:send_text(6, "LUA: ANY-FS -> SERVO9=900"); last_fs = true end
    SRV_Channels:set_output_pwm_chan_timeout(CH, PWM_CUT, TICK_MS + 150)
  elseif last_fs then
    gcs:send_text(6, "LUA: FS cleared")
    last_fs = false
  end

  return update, TICK_MS
end

return update()
