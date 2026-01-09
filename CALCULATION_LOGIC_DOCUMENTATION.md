# 📊 توثيق منطق الحسابات في تطبيق طوفير للطاقة
## Calculation Logic Documentation - Tawfir Energy App

---

## 📋 جدول المحتويات

1. [الحاسبة السكنية (Residential Calculator)](#1-الحاسبة-السكنية)
2. [حاسبة الضخ الشمسي (Solar Pumping Calculator)](#2-حاسبة-الضخ-الشمسي)
3. [حساب التأثير البيئي (Environmental Impact)](#3-حساب-التأثير-البيئي)
4. [الثوابت والمعاملات (Constants & Factors)](#4-الثوابت-والمعاملات)
5. [بيانات المناطق (Region Data)](#5-بيانات-المناطق)

---

## 1️⃣ الحاسبة السكنية (Residential Calculator)

### الملف: `lib/features/calculator/services/calculator_service.dart`

### المدخلات (Inputs):
- `factureDH`: مبلغ الفاتورة الشهرية بالدرهم المغربي
- `systemType`: نوع النظام ("ON-GRID", "HYBRID", "OFF-GRID")
- `regionCode`: رمز المنطقة (12 منطقة مغربية)
- `usageType`: نوع الاستخدام ("Maison", "Commerce", "Industrie")
- `panelWp`: قوة اللوحة الشمسية بالواط (افتراضي: 550W)

### الثوابت المستخدمة:
```dart
loss = 0.15          // 15% خسائر في النظام
safety = 0.10        // 10% هامش أمان
```

### خطوات الحساب:

#### الخطوة 1: تحديد سعر الكيلوواط/ساعة
```dart
getPricePerKwh(factureDH):
  if factureDH < 300:
    return 1.10 DH/kWh
  else if factureDH <= 1000:
    return 1.20 DH/kWh
  else:
    return 1.30 DH/kWh
```

**مثال:**
- فاتورة 200 DH → 1.10 DH/kWh
- فاتورة 500 DH → 1.20 DH/kWh
- فاتورة 1500 DH → 1.30 DH/kWh

#### الخطوة 2: تحويل الدرهم إلى كيلوواط/ساعة
```dart
pricePerKwh = getPricePerKwh(factureDH)
kwhMonth = factureDH / pricePerKwh
```

**مثال:**
- فاتورة 500 DH → 500 / 1.20 = 416.67 kWh/شهر

#### الخطوة 3: الحصول على ساعات الشمس
```dart
sunH = getSunHoursByRegion(regionCode)
// يتم الحصول على ساعات الشمس من ملف JSON حسب الشهر الحالي
```

#### الخطوة 4: حساب قوة النظام المطلوبة
```dart
// الصيغة الأساسية
powerKW = kwhMonth / (30 * sunH * (1 - loss))

// تطبيق هامش الأمان
powerKW = powerKW * (1 + safety)
```

**الصيغة الكاملة:**
```
powerKW = (kwhMonth / (30 * sunH * 0.85)) * 1.10
```

**مثال:**
- kwhMonth = 416.67
- sunH = 5.3 ساعة
- powerKW = 416.67 / (30 * 5.3 * 0.85) = 3.08 kW
- مع هامش الأمان: 3.08 * 1.10 = 3.39 kW

#### الخطوة 5: حساب عدد الألواح الشمسية
```dart
panels = ceil((powerKW * 1000) / panelWp)
```

**مثال:**
- powerKW = 3.39
- panelWp = 550W
- panels = ceil(3390 / 550) = ceil(6.16) = 7 ألواح

#### الخطوة 6: حساب معدل التوفير
```dart
savingRate = {
  "ON-GRID": {
    "Maison": 0.75,      // 75%
    "Commerce": 0.85,    // 85%
    "Industrie": 0.88,   // 88%
  },
  "HYBRID": {
    "Maison": 0.88,      // 88%
    "Commerce": 0.92,    // 92%
    "Industrie": 0.93,   // 93%
  },
  "OFF-GRID": {
    "Maison": 0.95,      // 95%
    "Commerce": 0.96,    // 96%
    "Industrie": 0.97,   // 97%
  },
}
```

#### الخطوة 7: حساب التوفير المالي
```dart
savingRateValue = savingRate[systemType][usageType]

savingMonthDH = factureDH * savingRateValue
savingYearDH = savingMonthDH * 12
saving10Y = savingYearDH * 10
saving20Y = savingYearDH * 20
```

**مثال:**
- factureDH = 500 DH
- systemType = "ON-GRID"
- usageType = "Maison"
- savingRateValue = 0.75
- savingMonthDH = 500 * 0.75 = 375 DH/شهر
- savingYearDH = 375 * 12 = 4,500 DH/سنة
- saving10Y = 4,500 * 10 = 45,000 DH
- saving20Y = 4,500 * 20 = 90,000 DH

---

## 2️⃣ حاسبة الضخ الشمسي (Solar Pumping Calculator)

### الملف: `lib/features/pumping/services/pumping_service.dart`

### الثوابت المستخدمة:
```dart
eta = 0.45              // كفاءة المضخة (45%)
derating = 0.75         // معامل تقليل الأداء للطاقة الشمسية (75%)
panelWp = 550.0         // قوة اللوحة بالواط
pipeLossPercent = 0.10  // خسائر الأنابيب (10%)
electricityPrice = 1.2  // سعر الكهرباء (DH/kWh)
dieselPrice = 11.0      // سعر الديزل (DH/liter)
dieselConsumption = 0.4 // استهلاك الديزل (l/kWh)
```

### ثلاثة أوضاع حساب:

#### الوضع 1: وضع التدفق (FLOW Mode)

**المدخلات:**
- `flowValue`: قيمة التدفق
- `flowUnit`: وحدة التدفق ("m3/h" أو "L/min")
- `headMeters`: الارتفاع المانومتري (متر)
- `hoursPerDay`: ساعات التشغيل يومياً
- `regionCode`: رمز المنطقة

**الحسابات:**

1. **تحويل التدفق إلى m³/h:**
```dart
if flowUnit == "L/min":
  qM3h = (flowValue * 60) / 1000
else:
  qM3h = flowValue
```

2. **حساب القوة الهيدروليكية:**
```dart
pHydW = 2.725 * qM3h * headMeters
```

3. **حساب القوة المطلوبة:**
```dart
pRequiredW = pHydW / eta
```

4. **حساب قوة النظام الشمسي:**
```dart
sunH = getSunHoursByRegion(regionCode)
pvWp = (pRequiredW * hoursPerDay) / (sunH * derating)
```

5. **حساب عدد الألواح:**
```dart
panels = ceil(pvWp / panelWp)
```

6. **حساب قوة المضخة بالكيلوواط:**
```dart
pumpKW = pRequiredW / 1000.0
```

**مثال:**
- flowValue = 10 m³/h
- headMeters = 30 متر
- hoursPerDay = 8 ساعات
- sunH = 5.3 ساعة

```
pHydW = 2.725 * 10 * 30 = 817.5 W
pRequiredW = 817.5 / 0.45 = 1,816.67 W
pvWp = (1,816.67 * 8) / (5.3 * 0.75) = 3,655 W
panels = ceil(3,655 / 550) = 7 ألواح
pumpKW = 1,816.67 / 1000 = 1.82 kW
```

#### الوضع 2: وضع المساحة الزراعية (AREA Mode)

**المدخلات:**
- `areaValue`: قيمة المساحة
- `areaUnit`: وحدة المساحة ("m²" أو "ha")
- `cropType`: نوع المحصول
- `irrigationType`: نوع الري
- `headMeters`: الارتفاع المانومتري
- `hoursPerDay`: ساعات التشغيل
- `regionCode`: رمز المنطقة

**جداول البيانات:**

**احتياج الماء حسب نوع المحصول (m³/ha/day):**
```dart
waterNeedTable = {
  'Blé': 4.0,
  'Orge': 3.5,
  'Maïs': 6.0,
  'Tomate': 5.5,
  'Pomme de terre': 4.5,
  'Luzerne': 7.0,
  'Agrumes': 5.0,
  'Olivier': 3.0,
  'Autre': 4.5,
}
```

**معامل كفاءة الري:**
```dart
irrigationFactor = {
  'Goutte à goutte': 0.90,  // 90%
  'Aspersion': 0.75,         // 75%
  'Gravitaire': 0.60,        // 60%
  'Autre': 0.70,             // 70%
}
```

**الحسابات:**

1. **تحويل المساحة إلى هكتار:**
```dart
if areaUnit == "m²":
  areaHa = areaValue / 10000.0
else:
  areaHa = areaValue
```

2. **حساب احتياج الماء اليومي:**
```dart
waterNeed = waterNeedTable[cropType]
factor = irrigationFactor[irrigationType]
waterDay = areaHa * waterNeed * factor
```

3. **حساب التدفق:**
```dart
qM3h = waterDay / hoursPerDay
```

4. **بعد ذلك نفس حسابات وضع التدفق:**
```dart
pHydW = 2.725 * qM3h * headMeters
pRequiredW = pHydW / eta
pvWp = (pRequiredW * hoursPerDay) / (sunH * derating)
panels = ceil(pvWp / panelWp)
```

**مثال:**
- areaValue = 2 ha
- cropType = "Maïs" (6.0 m³/ha/day)
- irrigationType = "Goutte à goutte" (0.90)
- headMeters = 25 متر
- hoursPerDay = 6 ساعات

```
waterDay = 2 * 6.0 * 0.90 = 10.8 m³/day
qM3h = 10.8 / 6 = 1.8 m³/h
pHydW = 2.725 * 1.8 * 25 = 122.625 W
pRequiredW = 122.625 / 0.45 = 272.5 W
pvWp = (272.5 * 6) / (5.3 * 0.75) = 411 W
panels = ceil(411 / 550) = 1 لوحة
```

#### الوضع 3: وضع الخزان (TANK Mode)

**المدخلات:**
- `tankVolumeM3`: حجم الخزان (m³)
- `fillHours`: وقت التعبئة (ساعات)
- `wellDepthM`: عمق البئر (متر)
- `tankHeightM`: ارتفاع الخزان (متر)
- `regionCode`: رمز المنطقة

**الحسابات:**

1. **حساب التدفق:**
```dart
qM3h = tankVolumeM3 / fillHours
```

2. **حساب الارتفاع الكلي:**
```dart
pipeLoss = (wellDepthM + tankHeightM) * pipeLossPercent
headMeters = wellDepthM + tankHeightM + pipeLoss
```

3. **بعد ذلك نفس حسابات وضع التدفق**

**مثال:**
- tankVolumeM3 = 50 m³
- fillHours = 4 ساعات
- wellDepthM = 20 متر
- tankHeightM = 5 متر

```
qM3h = 50 / 4 = 12.5 m³/h
pipeLoss = (20 + 5) * 0.10 = 2.5 متر
headMeters = 20 + 5 + 2.5 = 27.5 متر
```

### حساب التوفير للضخ الشمسي:

```dart
_calculateSavings(pumpKW, hoursPerDay, currentSource):
  
  if currentSource == "electricity":
    monthlyCost = pumpKW * hoursPerDay * 30 * 1.2
    
  else if currentSource == "diesel":
    litersMonth = pumpKW * hoursPerDay * 30 * 0.4
    monthlyCost = litersMonth * 11.0
    
  else: // unknown
    elecCost = pumpKW * hoursPerDay * 30 * 1.2
    dieselLiters = pumpKW * hoursPerDay * 30 * 0.4
    dieselCost = dieselLiters * 11.0
    monthlyCost = (elecCost + dieselCost) / 2
    
  yearlyCost = monthlyCost * 12
  
  return {monthly: monthlyCost, yearly: yearlyCost}
```

**مثال (كهرباء):**
- pumpKW = 1.82 kW
- hoursPerDay = 8 ساعات
- currentSource = "electricity"

```
monthlyCost = 1.82 * 8 * 30 * 1.2 = 524.16 DH/شهر
yearlyCost = 524.16 * 12 = 6,289.92 DH/سنة
```

**مثال (ديزل):**
- pumpKW = 1.82 kW
- hoursPerDay = 8 ساعات
- currentSource = "diesel"

```
litersMonth = 1.82 * 8 * 30 * 0.4 = 174.72 لتر/شهر
monthlyCost = 174.72 * 11.0 = 1,921.92 DH/شهر
yearlyCost = 1,921.92 * 12 = 23,063.04 DH/سنة
```

---

## 3️⃣ حساب التأثير البيئي (Environmental Impact)

### الملف: `lib/features/calculator/screens/result_*_screen.dart`

### المدخلات:
- `kWhMonth`: الاستهلاك الشهري بالكيلوواط/ساعة
- `tauxEconomie`: معدل التوفير (قيمة عشرية، مثال: 0.75 = 75%)
- `systemType`: نوع النظام ("ON-GRID", "HYBRID", "OFF-GRID")

### الثوابت:
```dart
EF = 0.7  // Emission Factor: kg CO₂ / kWh
TreeFactor = 20  // kg CO₂ / tree / year
```

### خطوات الحساب:

#### الخطوة 1: حساب التغطية الشمسية (Solar Coverage)
```dart
if systemType == "ON-GRID" || "ON_GRID":
  couverture = min(tauxEconomie, 0.9)  // حد أقصى 90%
  
else if systemType == "HYBRID":
  couverture = min(tauxEconomie, 0.95)  // حد أقصى 95%
  
else if systemType == "OFF-GRID" || "OFF_GRID":
  couverture = 1.0  // 100% تغطية
  
else:
  couverture = min(tauxEconomie, 0.9)  // افتراضي 90%
```

**مثال:**
- systemType = "ON-GRID"
- tauxEconomie = 0.75
- couverture = min(0.75, 0.9) = 0.75

#### الخطوة 2: حساب الطاقة المحفوظة سنوياً
```dart
kWhSavedYear = kWhMonth * 12 * couverture
```

**مثال:**
- kWhMonth = 416.67 kWh
- couverture = 0.75
- kWhSavedYear = 416.67 * 12 * 0.75 = 3,750 kWh/سنة

#### الخطوة 3: حساب ثاني أكسيد الكربون المحفوظ
```dart
co2Kg = kWhSavedYear * EF
co2Tonnes = co2Kg / 1000
```

**مثال:**
- kWhSavedYear = 3,750 kWh
- EF = 0.7 kg CO₂/kWh
- co2Kg = 3,750 * 0.7 = 2,625 kg CO₂
- co2Tonnes = 2,625 / 1000 = 2.625 طن CO₂

#### الخطوة 4: حساب المعادل بالأشجار
```dart
arbres = co2Kg / 20
```

**مثال:**
- co2Kg = 2,625 kg
- arbres = 2,625 / 20 = 131.25 ≈ 131 شجرة

### ملخص الصيغ:
```
1. couverture = min(tauxEconomie, max_coverage[systemType])
2. kWhSavedYear = kWhMonth * 12 * couverture
3. co2Kg = kWhSavedYear * 0.7
4. co2Tonnes = co2Kg / 1000
5. arbres = co2Kg / 20
```

---

## 4️⃣ الثوابت والمعاملات (Constants & Factors)

### الحاسبة السكنية:

#### معدلات التوفير (Saving Rates):
```
ON-GRID:
  Maison:     75%
  Commerce:   85%
  Industrie:  88%

HYBRID:
  Maison:     88%
  Commerce:   92%
  Industrie:  93%

OFF-GRID:
  Maison:     95%
  Commerce:   96%
  Industrie:  97%
```

#### معاملات النظام:
```
loss = 0.15        // 15% خسائر في النظام
safety = 0.10      // 10% هامش أمان
```

#### أسعار الكهرباء:
```
فاتورة < 300 DH:     1.10 DH/kWh
فاتورة 300-1000 DH:  1.20 DH/kWh
فاتورة > 1000 DH:    1.30 DH/kWh
```

### حاسبة الضخ:

#### معاملات المضخة:
```
eta = 0.45              // كفاءة المضخة (45%)
derating = 0.75         // معامل تقليل الأداء (75%)
pipeLossPercent = 0.10  // خسائر الأنابيب (10%)
```

#### أسعار الطاقة:
```
electricityPrice = 1.2 DH/kWh
dieselPrice = 11.0 DH/liter
dieselConsumption = 0.4 l/kWh
```

#### احتياج الماء حسب المحصول (m³/ha/day):
```
Blé:              4.0
Orge:             3.5
Maïs:             6.0
Tomate:           5.5
Pomme de terre:   4.5
Luzerne:          7.0
Agrumes:          5.0
Olivier:          3.0
Autre:            4.5 (افتراضي)
```

#### كفاءة الري:
```
Goutte à goutte:  90%
Aspersion:        75%
Gravitaire:       60%
Autre:            70% (افتراضي)
```

### التأثير البيئي:
```
Emission Factor (EF):    0.7 kg CO₂ / kWh
Tree Factor:             20 kg CO₂ / tree / year
```

---

## 5️⃣ بيانات المناطق (Region Data)

### الملف: `assets/data/regionSunHours.json`

### المناطق المغربية (12 منطقة):
1. Tanger-Tétouan-Al Hoceïma
2. Oriental
3. Fès-Meknès
4. Rabat-Salé-Kénitra
5. Béni Mellal-Khénifra
6. Casablanca-Settat
7. Marrakech-Safi
8. Drâa-Tafilalet
9. Souss-Massa
10. Guelmim-Oued Noun
11. Laâyoune-Sakia El Hamra
12. Dakhla-Oued Ed-Dahab

### ساعات الشمس:
- كل منطقة لديها 12 قيمة (شهر لكل شهر)
- القيم بالترتيب: يناير، فبراير، مارس، أبريل، مايو، يونيو، يوليو، أغسطس، سبتمبر، أكتوبر، نوفمبر، ديسمبر
- القيم النموذجية: من 4.0 إلى 6.5 ساعة يومياً حسب المنطقة والشهر

### الحصول على ساعات الشمس:
```dart
getSunHoursByRegion(regionCode):
  monthIndex = DateTime.now().month - 1  // 0-11
  sunH = regionSunHours[regionCode][monthIndex]
  return sunH
```

**مثال:**
- regionCode = "CAS"
- الشهر الحالي = مارس (الشهر 3)
- monthIndex = 2
- sunH = regionSunHours["CAS"][2] = 5.3 ساعة

---

## 📐 الصيغ الرياضية الكاملة

### الحاسبة السكنية:

#### 1. تحويل الفاتورة إلى kWh:
```
kWhMonth = factureDH / pricePerKwh
```

#### 2. حساب قوة النظام:
```
powerKW = (kWhMonth / (30 * sunH * (1 - loss))) * (1 + safety)
powerKW = (kWhMonth / (30 * sunH * 0.85)) * 1.10
```

#### 3. حساب عدد الألواح:
```
panels = ceil((powerKW * 1000) / panelWp)
```

#### 4. حساب التوفير:
```
savingMonth = factureDH * savingRate
savingYear = savingMonth * 12
saving10Y = savingYear * 10
saving20Y = savingYear * 20
```

### حاسبة الضخ:

#### 1. القوة الهيدروليكية:
```
P_hyd (W) = 2.725 × Q (m³/h) × H (m)
```

#### 2. القوة المطلوبة:
```
P_required (W) = P_hyd / eta
P_required (W) = P_hyd / 0.45
```

#### 3. قوة النظام الشمسي:
```
PV_Wp = (P_required × hoursPerDay) / (sunH × derating)
PV_Wp = (P_required × hoursPerDay) / (sunH × 0.75)
```

#### 4. عدد الألواح:
```
panels = ceil(PV_Wp / panelWp)
```

#### 5. حساب التدفق (وضع المساحة):
```
waterDay = areaHa × waterNeed × irrigationFactor
Q = waterDay / hoursPerDay
```

#### 6. حساب الارتفاع (وضع الخزان):
```
pipeLoss = (wellDepth + tankHeight) × 0.10
H = wellDepth + tankHeight + pipeLoss
```

### التأثير البيئي:

#### 1. التغطية الشمسية:
```
ON-GRID:   couverture = min(tauxEconomie, 0.9)
HYBRID:    couverture = min(tauxEconomie, 0.95)
OFF-GRID:  couverture = 1.0
```

#### 2. الطاقة المحفوظة:
```
kWhSavedYear = kWhMonth × 12 × couverture
```

#### 3. ثاني أكسيد الكربون:
```
CO₂ (kg) = kWhSavedYear × 0.7
CO₂ (tonnes) = CO₂ (kg) / 1000
```

#### 4. المعادل بالأشجار:
```
Trees = CO₂ (kg) / 20
```

---

## ✅ أمثلة حسابية كاملة

### مثال 1: حاسبة سكنية - ON-GRID

**المدخلات:**
- factureDH = 500 DH
- systemType = "ON-GRID"
- regionCode = "CAS" (Casablanca)
- usageType = "Maison"
- panelWp = 550W

**الحسابات:**

1. **سعر الكهرباء:**
   - 500 DH → 1.20 DH/kWh

2. **الاستهلاك الشهري:**
   - kWhMonth = 500 / 1.20 = 416.67 kWh

3. **ساعات الشمس (مارس):**
   - sunH = 5.3 ساعة

4. **قوة النظام:**
   - powerKW = (416.67 / (30 * 5.3 * 0.85)) * 1.10
   - powerKW = (416.67 / 135.15) * 1.10
   - powerKW = 3.08 * 1.10 = 3.39 kW

5. **عدد الألواح:**
   - panels = ceil((3.39 * 1000) / 550) = ceil(6.16) = 7 ألواح

6. **معدل التوفير:**
   - savingRate = 0.75 (75%)

7. **التوفير:**
   - savingMonth = 500 * 0.75 = 375 DH/شهر
   - savingYear = 375 * 12 = 4,500 DH/سنة
   - saving10Y = 4,500 * 10 = 45,000 DH
   - saving20Y = 4,500 * 20 = 90,000 DH

8. **التأثير البيئي:**
   - couverture = min(0.75, 0.9) = 0.75
   - kWhSavedYear = 416.67 * 12 * 0.75 = 3,750 kWh
   - co2Kg = 3,750 * 0.7 = 2,625 kg
   - co2Tonnes = 2.625 طن
   - arbres = 2,625 / 20 = 131 شجرة

---

### مثال 2: حاسبة ضخ - وضع التدفق

**المدخلات:**
- flowValue = 10 m³/h
- headMeters = 30 متر
- hoursPerDay = 8 ساعات
- regionCode = "CAS"
- currentSource = "electricity"

**الحسابات:**

1. **التدفق:**
   - Q = 10 m³/h

2. **القوة الهيدروليكية:**
   - pHydW = 2.725 * 10 * 30 = 817.5 W

3. **القوة المطلوبة:**
   - pRequiredW = 817.5 / 0.45 = 1,816.67 W

4. **ساعات الشمس:**
   - sunH = 5.3 ساعة

5. **قوة النظام الشمسي:**
   - pvWp = (1,816.67 * 8) / (5.3 * 0.75)
   - pvWp = 14,533.36 / 3.975 = 3,655 W

6. **عدد الألواح:**
   - panels = ceil(3,655 / 550) = 7 ألواح

7. **قوة المضخة:**
   - pumpKW = 1,816.67 / 1000 = 1.82 kW

8. **التوفير:**
   - monthlyCost = 1.82 * 8 * 30 * 1.2 = 524.16 DH/شهر
   - yearlyCost = 524.16 * 12 = 6,289.92 DH/سنة

---

### مثال 3: حاسبة ضخ - وضع المساحة

**المدخلات:**
- areaValue = 2 ha
- cropType = "Maïs"
- irrigationType = "Goutte à goutte"
- headMeters = 25 متر
- hoursPerDay = 6 ساعات
- regionCode = "CAS"

**الحسابات:**

1. **احتياج الماء:**
   - waterNeed = 6.0 m³/ha/day
   - factor = 0.90
   - waterDay = 2 * 6.0 * 0.90 = 10.8 m³/day

2. **التدفق:**
   - Q = 10.8 / 6 = 1.8 m³/h

3. **القوة الهيدروليكية:**
   - pHydW = 2.725 * 1.8 * 25 = 122.625 W

4. **القوة المطلوبة:**
   - pRequiredW = 122.625 / 0.45 = 272.5 W

5. **قوة النظام الشمسي:**
   - pvWp = (272.5 * 6) / (5.3 * 0.75) = 411 W

6. **عدد الألواح:**
   - panels = ceil(411 / 550) = 1 لوحة

---

## 🔍 ملاحظات مهمة

### 1. دقة الحسابات:
- جميع الحسابات تستخدم `double` لدقة عالية
- عدد الألواح يتم تقريبه للأعلى (`ceil`)
- النتائج النهائية يتم تقريبها عند العرض فقط

### 2. معالجة الأخطاء:
- التحقق من القيم السالبة أو الصفر
- استخدام قيم افتراضية عند عدم توفر البيانات
- رسائل خطأ واضحة للمستخدم

### 3. التحديثات المستقبلية:
- يمكن تحديث الثوابت بسهولة
- يمكن إضافة مناطق جديدة
- يمكن تعديل معاملات الحساب

### 4. الاختبار:
- يجب اختبار جميع الحالات الحدية
- يجب التحقق من دقة النتائج
- يجب التأكد من عدم وجود أخطاء في الصيغ

---

## 📝 ملخص الصيغ الرئيسية

### الحاسبة السكنية:
```
1. kWhMonth = factureDH / pricePerKwh
2. powerKW = (kWhMonth / (30 * sunH * 0.85)) * 1.10
3. panels = ceil((powerKW * 1000) / panelWp)
4. savingMonth = factureDH * savingRate
```

### حاسبة الضخ:
```
1. P_hyd = 2.725 × Q × H
2. P_required = P_hyd / 0.45
3. PV_Wp = (P_required × hours) / (sunH × 0.75)
4. panels = ceil(PV_Wp / panelWp)
```

### التأثير البيئي:
```
1. couverture = min(tauxEconomie, max_coverage)
2. kWhSavedYear = kWhMonth × 12 × couverture
3. CO₂ (tonnes) = (kWhSavedYear × 0.7) / 1000
4. Trees = (kWhSavedYear × 0.7) / 20
```

---

**تم إعداد هذا الملف:** ديسمبر 2024  
**آخر تحديث:** ديسمبر 2024  
**الحالة:** ✅ مكتمل وجاهز للمراجعة

