/// ProjectCalculator provides utility functions for solar system calculations.
/// 
/// All calculations follow standard solar engineering formulas.
/// Handles edge cases like division by zero safely.
class ProjectCalculator {
  ProjectCalculator._();

  // ============================================================
  // ON-GRID SYSTEM CALCULATIONS
  // ============================================================

  /// Calculates the required solar system power (kW) for an on-grid installation.
  /// 
  /// Formula: System Power = Monthly Consumption (kWh) / (Sun Hours × Days in Month)
  /// 
  /// [consumptionKwh] - Monthly energy consumption in kWh
  /// [sunHours] - Average daily sun hours (typically 4-6 hours, default: 5)
  /// 
  /// Returns system power in kW, or 0 if invalid inputs.
  static double onGridPower(double consumptionKwh, {double sunHours = 5.0}) {
    if (consumptionKwh <= 0 || sunHours <= 0) {
      return 0.0;
    }
    
    // Assuming 30 days per month
    const daysInMonth = 30.0;
    
    // System power = Total consumption / (Daily sun hours × Days)
    return consumptionKwh / (sunHours * daysInMonth);
  }

  /// Calculates the number of solar panels needed for an on-grid system.
  /// 
  /// Formula: Number of Panels = System Power (kW) × 1000 / Panel Power (W)
  /// 
  /// [systemKw] - Required system power in kilowatts
  /// [panelWp] - Individual panel power rating in watts
  /// 
  /// Returns number of panels (rounded up), or 0 if invalid inputs.
  static double onGridPanels(double systemKw, double panelWp) {
    if (systemKw <= 0 || panelWp <= 0) {
      return 0.0;
    }
    
    // Convert kW to watts and divide by panel power
    return (systemKw * 1000) / panelWp;
  }

  // ============================================================
  // OFF-GRID SYSTEM CALCULATIONS
  // ============================================================

  /// Calculates the required battery capacity (Ah) for an off-grid system.
  /// 
  /// Formula: Battery Capacity = (Daily Consumption × Days of Autonomy) / (Voltage × Depth of Discharge)
  /// 
  /// [dailyConsumption] - Daily energy consumption in kWh
  /// [days] - Days of autonomy (backup days without sun, default: 2)
  /// 
  /// Assumes 12V battery system and 50% depth of discharge.
  /// Returns battery capacity in Ah, or 0 if invalid inputs.
  static double offGridBatteryCapacity(double dailyConsumption, {int days = 2}) {
    if (dailyConsumption <= 0 || days <= 0) {
      return 0.0;
    }
    
    const batteryVoltage = 12.0; // 12V battery system
    const depthOfDischarge = 0.5; // 50% DoD for lead-acid batteries
    
    // Convert kWh to Wh, then calculate Ah
    final totalEnergyWh = dailyConsumption * days * 1000;
    return totalEnergyWh / (batteryVoltage * depthOfDischarge);
  }

  /// Calculates the required PV power (kW) for an off-grid system.
  /// 
  /// Formula: PV Power = Daily Consumption / Sun Hours
  /// 
  /// [dailyConsumption] - Daily energy consumption in kWh
  /// [sunHours] - Average daily sun hours (default: 5)
  /// 
  /// Returns PV power in kW, or 0 if invalid inputs.
  static double offGridPvPower(double dailyConsumption, {double sunHours = 5.0}) {
    if (dailyConsumption <= 0 || sunHours <= 0) {
      return 0.0;
    }
    
    // PV power needed to generate daily consumption
    return dailyConsumption / sunHours;
  }

  /// Calculates the number of solar panels needed for an off-grid system.
  /// 
  /// Formula: Number of Panels = PV Power (kW) × 1000 / Panel Power (W)
  /// 
  /// [pvKw] - Required PV power in kilowatts
  /// [panelWp] - Individual panel power rating in watts
  /// 
  /// Returns number of panels, or 0 if invalid inputs.
  static double offGridPanels(double pvKw, double panelWp) {
    if (pvKw <= 0 || panelWp <= 0) {
      return 0.0;
    }
    
    // Convert kW to watts and divide by panel power
    return (pvKw * 1000) / panelWp;
  }

  // ============================================================
  // HYBRID SYSTEM CALCULATIONS
  // ============================================================

  /// Calculates the solar energy needed for a hybrid system.
  /// 
  /// Formula: Solar Energy = Total Consumption × Coverage Percentage
  /// 
  /// [consumption] - Total energy consumption in kWh
  /// [coveragePercent] - Percentage of consumption to cover with solar (0-100, default: 70)
  /// 
  /// Returns solar energy in kWh, or 0 if invalid inputs.
  static double hybridSolarEnergy(double consumption, {double coveragePercent = 70.0}) {
    if (consumption <= 0 || coveragePercent <= 0 || coveragePercent > 100) {
      return 0.0;
    }
    
    // Calculate energy needed from solar based on coverage percentage
    return consumption * (coveragePercent / 100);
  }

  /// Calculates the required PV power (kW) for a hybrid system.
  /// 
  /// Formula: PV Power = Solar Energy / Sun Hours
  /// 
  /// [energy] - Solar energy needed in kWh
  /// [sunHours] - Average daily sun hours (default: 5)
  /// 
  /// Returns PV power in kW, or 0 if invalid inputs.
  static double hybridPvPower(double energy, {double sunHours = 5.0}) {
    if (energy <= 0 || sunHours <= 0) {
      return 0.0;
    }
    
    // PV power needed to generate the required solar energy
    return energy / sunHours;
  }

  /// Calculates the required battery capacity (Ah) for a hybrid system.
  /// 
  /// Formula: Battery Capacity = Energy (kWh) × 1000 / (Voltage × Depth of Discharge)
  /// 
  /// [energy] - Energy to store in kWh
  /// 
  /// Assumes 12V battery system and 80% depth of discharge (lithium batteries).
  /// Returns battery capacity in Ah, or 0 if invalid inputs.
  static double hybridBatteryCapacity(double energy) {
    if (energy <= 0) {
      return 0.0;
    }
    
    const batteryVoltage = 12.0; // 12V battery system
    const depthOfDischarge = 0.8; // 80% DoD for lithium batteries
    
    // Convert kWh to Wh, then calculate Ah
    final energyWh = energy * 1000;
    return energyWh / (batteryVoltage * depthOfDischarge);
  }

  // ============================================================
  // PUMPING SYSTEM CALCULATIONS
  // ============================================================

  /// Calculates the daily energy consumption for a water pumping system.
  /// 
  /// Formula: Energy = Pump Power (kW) × Operating Hours
  /// 
  /// [pumpPower] - Pump power rating in kilowatts
  /// [hours] - Daily operating hours
  /// 
  /// Returns daily energy consumption in kWh, or 0 if invalid inputs.
  static double pumpingEnergy(double pumpPower, double hours) {
    if (pumpPower <= 0 || hours <= 0) {
      return 0.0;
    }
    
    // Energy = Power × Time
    return pumpPower * hours;
  }

  /// Calculates the required PV power (kW) for a pumping system.
  /// 
  /// Formula: PV Power = Daily Energy / Sun Hours
  /// 
  /// [energy] - Daily energy consumption in kWh
  /// [sunHours] - Average daily sun hours (default: 5)
  /// 
  /// Returns PV power in kW, or 0 if invalid inputs.
  static double pumpingPvPower(double energy, {double sunHours = 5.0}) {
    if (energy <= 0 || sunHours <= 0) {
      return 0.0;
    }
    
    // PV power needed to generate daily energy for pumping
    return energy / sunHours;
  }
}

