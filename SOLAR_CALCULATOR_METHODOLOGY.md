# Méthodologie de Calcul du Calculateur Solaire | منهجية حساب الحاسبة الشمسية

## Vue d'ensemble | نظرة عامة

Ce document explique la méthodologie de calcul utilisée dans l'application du Calculateur d'Énergie Solaire. Le calculateur prend en charge quatre types de systèmes d'énergie solaire : **ON-GRID**, **HYBRID**, **OFF-GRID**, et **POMPAGE SOLAIRE**.

Ce المستند يشرح منهجية الحساب المستخدمة في تطبيق حاسبة الطاقة الشمسية. تدعم الحاسبة أربعة أنواع من أنظمة الطاقة الشمسية: **ON-GRID**، **HYBRID**، **OFF-GRID**، و **POMPAGE SOLAIRE**.

---

## Constantes et Paramètres du Système | ثوابت ومعاملات النظام

### Constantes Globales | الثوابت العامة

- **Tarif Moyen de l'Électricité**: 1.30 DH/kWh | **متوسط تعريفة الكهرباء**: 1.30 درهم/كيلوواط ساعة
- **Ratio de Performance (PR)**: 0.80 (80% d'efficacité système) | **نسبة الأداء (PR)**: 0.80 (كفاءة النظام 80%)
- **Profondeur de Décharge de la Batterie (DoD)**: 0.80 (80% pour batteries Lithium) | **عمق تفريغ البطارية (DoD)**: 0.80 (80% لبطاريات الليثيوم)
- **Efficacité de la Batterie**: 0.90 (90%) | **كفاءة البطارية**: 0.90 (90%)
- **Facteur de Capacité Utilisable de la Batterie**: 0.90 (90%) | **عامل السعة القابلة للاستخدام للبطارية**: 0.90 (90%)
- **Efficacité de la Pompe**: 0.50 (50%) | **كفاءة المضخة**: 0.50 (50%)
- **Frais Fixes (ON-GRID/HYBRID)**: 50.00 DH/mois | **الرسوم الثابتة (ON-GRID/HYBRID)**: 50.00 درهم/شهر
- **Montant Minimum de la Facture**: 50.00 DH/mois | **الحد الأدنى لمبلغ الفاتورة**: 50.00 درهم/شهر

### Constantes d'Impact Environnemental | ثوابت التأثير البيئي

- **Facteur d'Émission CO₂**: 0.6 kg CO₂ par kWh | **عامل انبعاثات CO₂**: 0.6 كجم CO₂ لكل كيلوواط ساعة
- **Absorption CO₂ par Arbre**: 22 kg CO₂ par arbre par an | **امتصاص CO₂ لكل شجرة**: 22 كجم CO₂ لكل شجرة سنوياً

### Heures d'Ensoleillement par Région | ساعات الإشعاع الشمسي حسب المنطقة

- **Nord**: 4.8 heures/jour | **الشمال**: 4.8 ساعة/يوم
- **Centre**: 5.3 heures/jour | **الوسط**: 5.3 ساعة/يوم
- **Sud**: 5.8 heures/jour | **الجنوب**: 5.8 ساعة/يوم

---

## 1. Calcul du Système ON-GRID | حساب نظام ON-GRID

### Paramètres d'Entrée | معاملات الإدخال
- Facture mensuelle d'électricité (DH) | فاتورة الكهرباء الشهرية (درهم)
- Région (Nord/Centre/Sud) | المنطقة (شمال/وسط/جنوب)
- Puissance du panneau (Wp) | قوة اللوحة (Wp)
- Type de profil : "Maison" ou "Commerce" | نوع الملف: "منزل" أو "تجاري"
- Tension : 220V ou 380V | الجهد: 220 فولت أو 380 فولت

### Taux d'Auto-Consommation par Profil | معدلات الاستهلاك الذاتي حسب الملف الشخصي
- **Maison (Résidentiel)**: 45% d'auto-consommation | **منزل (سكني)**: 45% استهلاك ذاتي
- **Commerce (Commercial)**: 65% d'auto-consommation | **تجاري**: 65% استهلاك ذاتي

### Étapes de Calcul | خطوات الحساب

#### Étape 1 : Calculer la Consommation Mensuelle d'Énergie | حساب استهلاك الطاقة الشهري
```
E_month (kWh/mois) = Facture Mensuelle (DH) ÷ Tarif Moyen (1.30 DH/kWh)
```

#### Étape 2 : Calculer la Consommation Quotidienne | حساب الاستهلاك اليومي
```
E_day (kWh/jour) = E_month ÷ 30 jours
```

#### Étape 3 : Calculer la Puissance du Panneau | حساب قوة اللوحة
```
P_panel (kW) = Puissance du Panneau (Wp) ÷ 1000
```

#### Étape 4 : Calculer la Puissance PV Requise | حساب قوة PV المطلوبة
```
P_PV (kW) = E_day ÷ (Heures d'Ensoleillement × Ratio de Performance)
```

#### Étape 5 : Calculer le Nombre de Panneaux | حساب عدد الألواح
```
N (panneaux) = Arrondir Vers le Haut (P_PV ÷ P_panel)
```

#### Étape 6 : Calculer la Capacité PV Installée | حساب السعة PV المثبتة
```
PV_kWc (kWc) = N × P_panel
```

#### Étape 7 : Calculer la Production Mensuelle PV | حساب الإنتاج الشهري PV
```
PV_kWh_month (kWh/mois) = PV_kWc × Heures d'Ensoleillement × Ratio de Performance × 30 jours
```

#### Étape 8 : Calculer l'Énergie Auto-Consommée | حساب الطاقة المستهلكة ذاتياً
```
Self_used (kWh/mois) = PV_kWh_month × Taux d'Auto-Consommation
```
Où Taux d'Auto-Consommation = 0.45 (Maison) ou 0.65 (Commerce) | حيث معدل الاستهلاك الذاتي = 0.45 (منزل) أو 0.65 (تجاري)

#### Étape 9 : Calculer l'Énergie Couverte | حساب الطاقة المغطاة
```
Covered_kWh (kWh/mois) = Minimum(Self_used, E_month)
```

#### Étape 10 : Calculer la Nouvelle Facture Mensuelle | حساب الفاتورة الشهرية الجديدة
```
Bill_calc (DH) = Frais Fixes (50 DH) + (E_month - Covered_kWh) × Tarif Moyen (1.30 DH/kWh)
```

#### Étape 11 : Appliquer la Règle de Facture Minimale | تطبيق قاعدة الحد الأدنى للفاتورة
```
Bill_after (DH) = Maximum(50 DH, Bill_calc)
```

#### Étape 12 : Calculer les Économies Mensuelles | حساب التوفير الشهري
```
Savings_month (DH) = Facture Mensuelle - Bill_after
```

#### Étape 13 : Calculer le Pourcentage de Couverture | حساب نسبة التغطية
```
Coverage (%) = (Covered_kWh ÷ E_month) × 100%
```

#### Étape 14 : Sélectionner la Taille de l'Onduleur | اختيار حجم العاكس
La taille de l'onduleur est sélectionnée en fonction de la capacité PV (kWc) selon le tableau suivant:

يتم اختيار حجم العاكس بناءً على السعة PV (kWc) وفقاً للجدول التالي:

| Capacité PV (kWc) | Onduleur Recommandé (kW) | العاكس الموصى به |
|-------------------|---------------------------|------------------|
| ≤ 3               | 3                         | 3                |
| ≤ 5               | 5                         | 5                |
| ≤ 7               | 6                         | 6                |
| ≤ 9               | 8                         | 8                |
| ≤ 11              | 10                        | 10               |
| ≤ 13              | 12                        | 12               |
| ≤ 16              | 15                        | 15               |
| ≤ 18              | 17                        | 17               |
| ≤ 22              | 20                        | 20               |
| ≤ 27              | 25                        | 25               |
| ≤ 33              | 30                        | 30               |
| ≤ 40              | 40                        | 40               |
| ≤ 50              | 50                        | 50               |
| ≤ 60              | 60                        | 60               |
| ≤ 80              | 80                        | 80               |
| ≤ 100             | 100                       | 100              |
| > 100             | 100                       | 100              |

#### Étape 15 : Recommandation de Tension | توصية الجهد
- **Avertissement** : Si puissance onduleur > 5 kW et tension = 220V, le système recommande 380V (triphasé) | **تحذير**: إذا كانت قوة العاكس > 5 كيلوواط والجهد = 220 فولت، يوصي النظام بـ 380 فولت (ثلاثي الطور)

#### Étape 16 : Calculer les Économies à Long Terme | حساب التوفير على المدى الطويل
```
Savings_year (DH) = Savings_month × 12
Savings_10years (DH) = Savings_year × 10
Savings_20years (DH) = Savings_year × 20
```

#### Étape 17 : Impact Environnemental | التأثير البيئي
```
kWh_saved/mois = E_month × (Coverage % ÷ 100)
kWh_saved/an = kWh_saved/mois × 12
CO₂_kg/an = kWh_saved/an × 0.6
CO₂_ton/an = CO₂_kg/an ÷ 1000
Trees_equivalent = CO₂_kg/an ÷ 22
```

---

## 2. Calcul du Système HYBRID | حساب نظام HYBRID

### Paramètres d'Entrée | معاملات الإدخال
- Facture mensuelle d'électricité (DH) | فاتورة الكهرباء الشهرية (درهم)
- Région (Nord/Centre/Sud) | المنطقة (شمال/وسط/جنوب)
- Puissance du panneau (Wp) | قوة اللوحة (Wp)
- Pourcentage de couverture souhaité (30% à 90%) | نسبة التغطية المطلوبة (30% إلى 90%)
- Capacité de la batterie (kWh) | سعة البطارية (كيلوواط ساعة)
- Profil de consommation : "Maison", "Commerce", "Industrie", ou "Maison Nuit" | ملف الاستهلاك: "منزل"، "تجاري"، "صناعي"، أو "منزل ليلي"
- Tension : 220V ou 380V | الجهد: 220 فولت أو 380 فولت

### Profils de Consommation (Ratios Jour/Nuit) | ملفات الاستهلاك (نسب النهار/الليل)

| Profil         | Ratio Jour | Ratio Nuit | نسبة النهار | نسبة الليل |
|----------------|------------|------------|-------------|------------|
| Maison         | 60%        | 40%        | 60%         | 40%        |
| Commerce       | 80%        | 20%        | 80%         | 20%        |
| Industrie      | 90%        | 10%        | 90%         | 10%        |
| Maison Nuit    | 40%        | 60%        | 40%         | 60%        |

### Étapes de Calcul | خطوات الحساب

#### Étapes 1-6 : Identiques au système ON-GRID | نفس خطوات نظام ON-GRID
Calculer E_month, E_day, P_panel, P_PV, N, et PV_kWc en utilisant les mêmes formules.

#### Étape 7 : Convertir la Couverture en Ratio d'Auto-Consommation | تحويل التغطية إلى نسبة الاستهلاك الذاتي
```
Ratio d'Auto-Consommation = Couverture Souhaitée (%) ÷ 100
```

#### Étape 8 : Calculer l'Énergie Cible | حساب الطاقة المستهدفة
```
E_target (kWh/jour) = E_day × Ratio d'Auto-Consommation
```

#### Étape 9 : Diviser l'Énergie par Profil Jour/Nuit | تقسيم الطاقة حسب ملف النهار/الليل
```
E_day_part (kWh) = E_target × Ratio Jour
E_night (kWh) = E_target × Ratio Nuit
```

#### Étape 10 : Calculer la Production Mensuelle PV | حساب الإنتاج الشهري PV
```
PV_kWh_month (kWh/mois) = PV_kWc × Heures d'Ensoleillement × Ratio de Performance × 30 jours
```

#### Étape 11 : Calculer l'Énergie Auto-Consommée | حساب الطاقة المستهلكة ذاتياً
```
Self_used (kWh/mois) = PV_kWh_month × Ratio d'Auto-Consommation
```

#### Étape 12 : Calculer l'Énergie Couverte | حساب الطاقة المغطاة
```
Covered_kWh (kWh/mois) = Minimum(Self_used, E_month)
```

#### Étape 13 : Calculs de la Batterie | حسابات البطارية
```
Battery_usable (kWh) = Battery_capacity (kWh) × 0.90
E_night_covered (kWh) = Minimum(E_night, Battery_usable)
E_grid_night (kWh) = E_night - E_night_covered
Couverture Nuit (%) = (E_night_covered ÷ E_night) × 100%
```

#### Étape 14 : Calculer la Nouvelle Facture Mensuelle | حساب الفاتورة الشهرية الجديدة
```
Bill_calc (DH) = Frais Fixes (50 DH) + (E_month - Covered_kWh) × Tarif Moyen (1.30 DH/kWh)
Bill_after (DH) = Maximum(50 DH, Bill_calc)
```

#### Étape 15 : Calculer les Économies Mensuelles (avec Limite) | حساب التوفير الشهري (مع حد)
```
Savings_month_raw (DH) = Facture Mensuelle - Bill_after
Savings_month (DH) = Minimum(Savings_month_raw, Facture Mensuelle × 0.90)
```
**Note** : Les économies sont limitées à 90% de la facture originale. | **ملاحظة**: التوفير محدود بنسبة 90% من الفاتورة الأصلية.

#### Étape 16 : Sélection de l'Onduleur | اختيار العاكس
Identique au système ON-GRID (voir Tableau de Sélection d'Onduleur).

#### Étape 17 : Recommandation de Tension | توصية الجهد
Identique au système ON-GRID.

#### Étape 18 : Économies à Long Terme et Impact Environnemental | التوفير على المدى الطويل والتأثير البيئي
Même calcul que le système ON-GRID.

---

## 3. Calcul du Système OFF-GRID | حساب نظام OFF-GRID

### Paramètres d'Entrée | معاملات الإدخال
- Profil d'utilisation (profils de consommation prédéfinis) | ملف الاستخدام (ملفات الاستهلاك المحددة مسبقاً)
- Région (Nord/Centre/Sud) | المنطقة (شمال/وسط/جنوب)
- Jours d'autonomie (1, 2, ou 3 jours) | أيام الاستقلالية (1، 2، أو 3 أيام)
- Puissance du panneau (Wp) | قوة اللوحة (Wp)
- Tension (optionnel) : 220V ou 380V | الجهد (اختياري): 220 فولت أو 380 فولت

### Profils d'Utilisation (Consommation Énergétique Quotidienne) | ملفات الاستخدام (الاستهلاك اليومي للطاقة)

| Profil                         | Énergie Quotidienne (kWh/jour) | الطاقة اليومية |
|--------------------------------|--------------------------------|----------------|
| Maison petite (rural)          | 5.0                            | 5.0            |
| Maison moyenne                 | 10.0                           | 10.0           |
| Maison grande / Villa rurale   | 20.0                           | 20.0           |
| Atelier / Commerce petit       | 30.0                           | 30.0           |

### Étapes de Calcul | خطوات الحساب

#### Étape 1 : Obtenir l'Énergie Quotidienne du Profil | الحصول على الطاقة اليومية من الملف
```
E_day (kWh/jour) = Énergie Quotidienne du Profil
```

#### Étape 2 : Calculer la Puissance PV Requise | حساب قوة PV المطلوبة
```
P_PV (kW) = E_day ÷ (Heures d'Ensoleillement × Ratio de Performance)
```

#### Étape 3 : Calculer la Puissance du Panneau | حساب قوة اللوحة
```
P_panel (kW) = Puissance du Panneau (Wp) ÷ 1000
```

#### Étape 4 : Calculer le Nombre de Panneaux | حساب عدد الألواح
```
N (panneaux) = Arrondir Vers le Haut (P_PV ÷ P_panel)
```

#### Étape 5 : Calculer la Capacité PV Installée | حساب السعة PV المثبتة
```
PV_kWc (kWc) = N × P_panel
```

#### Étape 6 : Calculer la Capacité de la Batterie | حساب سعة البطارية
```
Battery_kWh (kWh) = (E_day × Jours d'Autonomie) ÷ Profondeur de Décharge (0.80)
```

#### Étape 7 : Sélectionner la Taille de l'Onduleur | اختيار حجم العاكس
Identique au système ON-GRID (voir Tableau de Sélection d'Onduleur).

#### Étape 8 : Recommandation de Tension | توصية الجهد
- Si tension non spécifiée: | إذا لم يتم تحديد الجهد:
  - **Onduleur ≤ 5 kW** : Recommander 220V (monophasé) | **عاكس ≤ 5 كيلوواط**: التوصية بـ 220 فولت (أحادي الطور)
  - **Onduleur > 5 kW** : Recommander 380V (triphasé) | **عاكس > 5 كيلوواط**: التوصية بـ 380 فولت (ثلاثي الطور)
- Si tension spécifiée et onduleur > 5 kW avec 220V : Afficher un avertissement | إذا تم تحديد الجهد والعاكس > 5 كيلوواط مع 220 فولت: إظهار تحذير

#### Étape 9 : Impact Environnemental | التأثير البيئي
```
kWh_saved/an = E_day × 365 jours (100% de couverture pour off-grid)
CO₂_kg/an = kWh_saved/an × 0.6
CO₂_ton/an = CO₂_kg/an ÷ 1000
Trees_equivalent = CO₂_kg/an ÷ 22
```

---

## 4. Calcul du Système POMPAGE SOLAIRE | حساب نظام POMPAGE SOLAIRE

### Paramètres d'Entrée | معاملات الإدخال
- Débit (m³/h ou L/min) | معدل التدفق (م³/ساعة أو لتر/دقيقة)
- Hauteur manométrique (HMT) en mètres | الارتفاع الهيدروستاتيكي (HMT) بالمتر
- Heures de fonctionnement par jour | ساعات التشغيل يومياً
- Région (Nord/Centre/Sud) | المنطقة (شمال/وسط/جنوب)
- Type de pompe : AC ou DC | نوع المضخة: AC أو DC
- Puissance du panneau (Wp) | قوة اللوحة (Wp)

### Étapes de Calcul | خطوات الحساب

#### Étape 1 : Convertir le Débit (si nécessaire) | تحويل معدل التدفق (إذا لزم الأمر)
```
Si l'entrée est en L/min:
Débit (m³/h) = Débit (L/min) × 0.06
```

#### Étape 2 : Calculer la Puissance de la Pompe | حساب قوة المضخة
```
P_pump (kW) = (2.7 × Débit (m³/h) × HMT (m)) ÷ (1000 × Efficacité Pompe (0.50))
```

#### Étape 3 : Calculer la Puissance PV Requise | حساب قوة PV المطلوبة
```
P_PV (kW) = P_pump (kW) ÷ Ratio de Performance (0.80)
```

#### Étape 4 : Calculer le Nombre de Panneaux | حساب عدد الألواح
```
N (panneaux) = Arrondir Vers le Haut ((P_PV × 1000) ÷ Puissance Panneau (Wp))
```

---

## Calcul de l'Impact Environnemental | حساب التأثير البيئي

### Pour les Systèmes ON-GRID et HYBRID | لأنظمة ON-GRID و HYBRID
```
kWh_saved/mois = E_month × (Coverage % ÷ 100)
kWh_saved/an = kWh_saved/mois × 12
CO₂_kg/an = kWh_saved/an × 0.6 kg CO₂/kWh
CO₂_ton/an = CO₂_kg/an ÷ 1000
Trees_equivalent = CO₂_kg/an ÷ 22 kg CO₂/arbre
```

### Pour le Système OFF-GRID | لنظام OFF-GRID
```
kWh_saved/an = E_day × 365 jours (100% de couverture)
CO₂_kg/an = kWh_saved/an × 0.6 kg CO₂/kWh
CO₂_ton/an = CO₂_kg/an ÷ 1000
Trees_equivalent = CO₂_kg/an ÷ 22 kg CO₂/arbre
```

---

## Notes Importantes | ملاحظات مهمة

1. **Ratio de Performance (PR)** : Prend en compte les pertes du système incluant l'efficacité de l'onduleur, les pertes de câbles, l'ombrage, et les effets de température. | **نسبة الأداء (PR)**: تأخذ في الاعتبار خسائر النظام بما في ذلك كفاءة العاكس، خسائر الكابلات، التظليل، وتأثيرات الحرارة.

2. **Auto-Consommation** : Le pourcentage d'énergie solaire directement utilisée par le consommateur sans être renvoyée au réseau. | **الاستهلاك الذاتي**: النسبة المئوية للطاقة الشمسية المستخدمة مباشرة من قبل المستهلك دون إرجاعها إلى الشبكة.

3. **Frais Fixes** : Un montant mensuel fixe facturé indépendamment de la consommation (s'applique aux systèmes ON-GRID et HYBRID). | **الرسوم الثابتة**: مبلغ شهري ثابت يتم تحميله بغض النظر عن الاستهلاك (ينطبق على أنظمة ON-GRID و HYBRID).

4. **Facture Minimale** : Le montant minimum qui doit être payé même si la production solaire dépasse la consommation. | **الفاتورة الدنيا**: المبلغ الأدنى الذي يجب دفعه حتى لو تجاوز الإنتاج الشمسي الاستهلاك.

5. **Capacité Utilisable de la Batterie** : Seulement 90% de la capacité de la batterie est utilisable pour préserver la durée de vie de la batterie. | **السعة القابلة للاستخدام للبطارية**: فقط 90% من سعة البطارية قابلة للاستخدام للحفاظ على عمر البطارية.

6. **Limite d'Économies (HYBRID)** : Les économies sont limitées à 90% de la facture originale pour tenir compte des limitations du système et des attentes réalistes. | **حد التوفير (HYBRID)**: التوفير محدود بنسبة 90% من الفاتورة الأصلية للاعتراف بقيود النظام والتوقعات الواقعية.

7. **Dimensionnement de l'Onduleur** : Les onduleurs sont dimensionnés légèrement supérieurs à la capacité PV pour gérer la production de pointe et fournir une marge de sécurité. | **تحديد حجم العاكس**: يتم تحديد حجم العاكسات أعلى قليلاً من السعة PV للتعامل مع الإنتاج الذروي وتوفير هامش أمان.

8. **Sélection de Tension** : Les systèmes au-dessus de 5 kW sont recommandés pour utiliser 380V (triphasé) pour une meilleure efficacité et compatibilité réseau. | **اختيار الجهد**: يُوصى بأنظمة فوق 5 كيلوواط باستخدام 380 فولت (ثلاثي الطور) للحصول على كفاءة أفضل وتوافق مع الشبكة.

---

## Résumé | الملخص

Cette méthodologie garantit des calculs précis et réalistes pour tous les types de systèmes solaires. Toutes les formules sont basées sur des normes industrielles et tiennent compte des facteurs de performance réels, des pertes, et des limitations pratiques des systèmes d'énergie solaire.

هذه المنهجية تضمن حسابات دقيقة وواقعية لجميع أنواع الأنظمة الشمسية. تعتمد جميع الصيغ على المعايير الصناعية وتأخذ في الاعتبار عوامل الأداء الحقيقية، والخسائر، والقيود العملية لأنظمة الطاقة الشمسية.

**Dernière Mise à Jour** : 2024 | **آخر تحديث**: 2024  
**Version** : 1.0
