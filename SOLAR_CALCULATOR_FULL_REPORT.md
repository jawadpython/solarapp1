# Solar Calculator Full Technical Report

## 1) Scope

This report documents the full calculation logic currently used by the app calculator service in:

- `lib/features/calculator/services/calculator_v1_service.dart`
- `lib/features/calculator/models/calculator_result.dart`

Covered systems:

- ON-GRID
- HYBRID
- OFF-GRID
- POMPAGE SOLAIRE

This is the "as-built" behavior from code (not theoretical-only documentation).

---

## 2) Global Constants and Rules

### Core constants

- `tariff_avg = 1.30` DH/kWh
- `PR = 0.80` (system performance ratio)
- `DoD = 0.80` (battery depth of discharge)
- `eff_batt = 0.90` (battery efficiency)
- `battery_usable_factor = 0.90`
- `rendement_pompe = 0.50`
- `fixedCharges = 50` DH
- `billMin = 50` DH
- `fixedSunHours = 5.5` h/day (fixed for all regions)

### Environmental constants

- `co2_factor = 0.6` kg CO2/kWh
- `kg_per_tree = 22` kg CO2/tree/year

### Voltage warning rule

Warning is shown when:

- inverter power `> 5 kW`
- and selected voltage is `220V`

### Inverter selection rule

Discrete table:

- <=3 -> 3
- <=5 -> 5
- <=7 -> 6
- <=9 -> 8
- <=11 -> 10
- <=13 -> 12
- <=16 -> 15
- <=18 -> 17
- <=22 -> 20
- <=27 -> 25
- <=33 -> 30
- <=40 -> 40
- <=50 -> 50
- <=60 -> 60
- <=80 -> 80
- <=100 -> 100

For systems above 100 kW:

- `inverter = ceil(pvKwc / 10) * 10`
- This means no hard cap at 100 anymore.

---

## 3) ON-GRID Calculation

## Inputs

- `montantDH` (monthly bill in DH)
- `regionCode` (kept but sun hours are fixed to 5.5)
- `panelWp` (panel watt-peak)
- `profile` (`Maison` or `Commerce`, optional)
- `voltage` (`220V` or `380V`)

## Profile self-consumption

- `Maison`: 45%
- `Commerce`: 65%
- Default if missing/unknown: 45%

## Formula steps

1. `kwhMonth = montantDH / tariff_avg`
2. `kwhDay = kwhMonth / 30`
3. `panelPowerKW = panelWp / 1000`
4. `pvPowerKW = kwhDay / (sunHours * PR)`
5. `panels = ceil(pvPowerKW / panelPowerKW)`
6. `pvKwc = panels * panelPowerKW`
7. `pvKwhMonth = pvKwc * sunHours * PR * 30`
8. `selfUsed = pvKwhMonth * SC`
9. `kwhCovered = min(selfUsed, kwhMonth)`
10. `billCalc = fixedCharges + (kwhMonth - kwhCovered) * tariff_avg`
11. `billAfter = max(billMin, billCalc)`
12. `savingMonthRaw = montantDH - billAfter`
13. `savingMonth = clamp(savingMonthRaw, 0, montantDH - billMin)`
14. `coveragePct = (kwhCovered / kwhMonth) * 100`
15. `inverterKW = selectInverter(pvKwc)`
16. `showVoltageWarning = inverterKW > 5 && voltage == '220V'`
17. `savingYear = savingMonth * 12`
18. `saving10Y = savingYear * 10`
19. `saving20Y = savingYear * 20`

---

## 4) HYBRID Calculation

## Inputs

- `montantDH`
- `regionCode`
- `panelWp`
- `coveragePct` (slider, expected 30 to 90)
- `batteryKwh`
- `profile` (`Maison`, `Commerce`, `Industrie`, `Maison Nuit`)
- `voltage`

## Day/night profile ratios

- Maison: day 60%, night 40%
- Commerce: day 80%, night 20%
- Industrie: day 90%, night 10%
- Maison Nuit / MaisonNuit: day 40%, night 60%

## Formula steps

1. `kwhMonth = montantDH / tariff_avg`
2. `kwhDay = kwhMonth / 30`
3. `covPct = clamp(coveragePct, 30, 90)`
4. `selfConsumptionRatio = covPct / 100`
5. `kwhTargetDay = kwhDay * selfConsumptionRatio`
6. `kwhDayPart = kwhTargetDay * dayRatio`
7. `kwhNight = kwhTargetDay * nightRatio`
8. `panelPowerKW = panelWp / 1000`
9. `pvPowerKW = kwhTargetDay / (sunHours * PR)`
10. `panels = ceil(pvPowerKW / panelPowerKW)`
11. `pvKwc = panels * panelPowerKW`
12. `pvKwhMonth = pvKwc * sunHours * PR * 30`
13. `targetKwhMonth = kwhMonth * selfConsumptionRatio`
14. `kwhCovered = min(pvKwhMonth, targetKwhMonth, kwhMonth)`
15. `batteryUsable = batteryKwh * battery_usable_factor`
16. `kwhNightCovered = min(kwhNight, batteryUsable)`
17. `kwhGridNight = max(0, kwhNight - kwhNightCovered)`
18. `nightCoveragePct = (kwhNightCovered / kwhNight) * 100` (if `kwhNight > 0`)
19. `billCalc = fixedCharges + (kwhMonth - kwhCovered) * tariff_avg`
20. `billAfter = max(billMin, billCalc)`
21. `savingMonthRaw = montantDH - billAfter`
22. `savingMonth = clamp(savingMonthRaw, 0, montantDH * 0.90)` (90% cap)
23. `inverterKW = selectInverter(pvKwc * 1.10)` (10% margin)
24. `showVoltageWarning = inverterKW > 5 && voltage == '220V'`
25. `savingYear = savingMonth * 12`
26. `saving10Y = savingYear * 10`
27. `saving20Y = savingYear * 20`
28. `coveragePctDisplay = (kwhCovered / kwhMonth) * 100`

---

## 5) OFF-GRID Calculation

## Inputs

- `profile` (usage profile key)
- `regionCode`
- `autonomyDays`
- `panelWp`
- `voltage` (optional)

## Usage profile daily energy

- Maison petite (rural): 5 kWh/day
- Maison moyenne: 10 kWh/day
- Maison grande / Villa rurale: 20 kWh/day
- Atelier / Commerce petit: 30 kWh/day

## Formula steps

1. `kwhDay = usageProfiles[profile]` (fallback 10)
2. `pvPowerKW = kwhDay / (sunHours * PR)`
3. `panelPowerKW = panelWp / 1000`
4. `panels = ceil(pvPowerKW / panelPowerKW)`
5. `pvKwc = panels * panelPowerKW`
6. `batteryKwh = (kwhDay * autonomyDays) / (DoD * eff_batt)`
7. `inverterKW = selectInverter(pvKwc * 1.20)` (20% margin)

Voltage logic:

- If user selected voltage:
  - warning if `inverterKW > 5` and `220V`
- If voltage not selected:
  - recommend `220V` if `inverterKW <= 10`, else `380V`

---

## 6) POMPAGE SOLAIRE Calculation

## Inputs

- `flowValue`
- `flowUnit` (`m3/h` or `L/min`)
- `hmtMeters`
- `hoursPerDay` (currently carried in result but not used in sizing formula)
- `regionCode`
- `pumpType` (`AC` or `DC`)
- `panelWp`
- `voltage` (optional)

## Formula steps

1. Flow conversion:
   - if `L/min`: `flowM3h = flowValue * 0.06`
   - else: `flowM3h = flowValue`
2. `hydraulicPowerKW = (flowM3h * hmtMeters) / 367`
3. `pumpPowerKW = hydraulicPowerKW / rendement_pompe`
4. `pvPowerKW = pumpPowerKW / PR`
5. `panels = ceil((pvPowerKW * 1000) / panelWp)`

AC pump branch:

6. `vfdNeeded = pumpPowerKW * 1.20`
7. `vfdRecommendedKW = selectInverter(vfdNeeded)`
8. Recommended voltage:
   - `220V` if `vfdRecommendedKW <= 10`, else `380V`
9. Warning:
   - `vfdRecommendedKW > 5` and (`voltage` is null or `220V`)

DC pump branch:

- Sets `vfdType = "Contrôleur / Driver DC (pompe DC)"`

---

## 7) Result Objects Returned

### ON-GRID result

- Consumption: `kwhMonth`, `kwhDay`, `kwhCovered`
- PV sizing: `pvPowerKW`, `panels`, `pvKwc`, `panelWp`
- Electrical: `inverterKW`, `voltage`, `showVoltageWarning`
- Financial: `savingMonth`, `savingYear`, `saving10Y`, `saving20Y`, `billAfter`
- Meta: `regionCode`, `sunHours`, `systemType`

### HYBRID result

- ON-GRID-like fields plus:
- `kwhTarget`, `profile`, `dayRatio`, `nightRatio`
- `kwhDayPart`, `kwhNight`, `batteryKwh`, `batteryUsable`
- `kwhNightCovered`, `kwhGridNight`, `nightCoveragePct`

### OFF-GRID result

- `profile`, `kwhDay`, `autonomyDays`
- `pvPowerKW`, `panels`, `pvKwc`, `batteryKwh`, `inverterKW`
- `voltage`, `recommendedVoltage`, `showVoltageWarning`

### POMPAGE result

- `flowValue`, `flowUnit`, `hmtMeters`, `hoursPerDay`, `pumpType`
- `pumpPowerKW`, `pvPowerKW`, `panels`, `panelWp`
- `vfdRecommendedKW`, `vfdType`, `recommendedVoltage`, `showVoltageWarning`

---

## 8) Worked Validation Examples (Automated Test Bench)

From `test/calculator_verification_test.dart`:

1. ON-GRID sample:
   - Input: 1000 DH, 550 W panel, Maison, 220V
   - Expected around: 11 panels, 6.05 kWc, ~417 DH monthly savings

2. HYBRID sample:
   - Input: 1000 DH, 70% target, 10 kWh battery, Maison Nuit
   - Expected around: 8 panels, 4.4 kWc, ~650 DH monthly savings

3. OFF-GRID sample:
   - Input: Maison moyenne, autonomy 2 days
   - Expected around: 5 panels, 2.75 kWc, 27.8 kWh battery

4. POMPAGE sample:
   - Input: 10 m3/h, 40 m HMT, AC
   - Expected around: 5 panels, 2.18 kW pump, 2.72 kW PV

---

## 9) Known Implementation Notes

- Sun hours are currently fixed to 5.5 for all regions.
- HYBRID coverage input is clamped to 30%-90%.
- OFF-GRID recommended voltage uses threshold 10 kW for recommendation, but warning threshold is 5 kW when user forces 220V.
- Inverter now scales above 100 kW to nearest 10 kW (no hard cap).

---

## 10) Traceability

Primary source files:

- `lib/features/calculator/services/calculator_v1_service.dart`
- `lib/features/calculator/models/calculator_result.dart`
- `test/calculator_verification_test.dart`

Report generated on: 2026-05-08

