# electronic_warfare_failsafe_script

# FS → CH9 = 900µs (ArduPilot Lua)

**Що це:** Lua-скрипт для ArduPilot, який **постійно** моніторить **будь-який фейлсейф** (RC-loss / RX FS-кадри / Battery FS / EKF FS / глобальний FS / інші біти) і **миттєво** ставить **SERVO9** у **900 µs**. Працює у фоні.

## Особливості

* Тригер: `rc:in_failsafe()`, відсутність кадрів `rc:has_valid_input()==false`, Battery FS, EKF FS, `arming:is_failsafe()`, `vehicle:get_failsafe_mask()`.
* Діє лише на **SERVO9** (0-базовано канал `8`).
* Використовує `SRV_Channels:set_output_pwm_chan_timeout(...)` для “липкого” значення під час FS.

## Вимоги

* ArduPilot із Lua-скриптингом (`SCR_ENABLE=1`).
* **SERVO9** має бути PWM-виходом (не GPIO): для AUX увімкнути `BRD_PWM_COUNT ≥ 3`.
* `SERVO9_FUNCTION != 0` (рекомендовано `94: Script`).
* Для тестів: вимкни safety (`BRD_SAFETYENABLE=0`) або додай SERVO9 у `BRD_SAFETY_MASK` (біт 256).

## Параметри

* `TICK_MS=50` — період перевірки.
* `PWM_CUT=900` — цільове значення.
* `CH=8` — SERVO9 (0-базований індекс).

## Встановлення

1. Увімкни Lua: `SCR_ENABLE=1`, перезавантаж.
2. Скопіюй файл до **/APM/scripts/fs_ch9_any_900.lua** на SD автопілота.
3. Налаштуй параметри з розділу “Вимоги”.
4. Перезавантаж політний контролер.

## Перевірка

* RX failsafe: режим **no-pulses** і вимкни передавач → у повідомленнях: `LUA: ANY-FS -> SERVO9=900`, осцилограф/серво показує **900 µs**.
* Альтернатива в SITL: `param set SIM_RC_FAIL 1`.

## Зауваги безпеки

* Тестуй **без пропелерів**.
* Скрипт не змінює режим польоту/автодії, лише притискає вихід до мінімуму під час FS.
