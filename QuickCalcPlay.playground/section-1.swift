// Playground - noun: a place where people can play

import UIKit

class QuickCalc {
    enum VestingOption {
        case Monthly,Quarterly,Annually
    }
    var initialAmount:Double = 0.0 // initial amount
    var periodicalAmount:Double = 0.0 // annual installment
    var ratePercentage:Double = 0.0 // rate in percentage
    var inflationPercentage:Double = 0.0 // inflation rate in percentage
    var vestingPeriod:Int = 0 // period of investment
    var targetAmount:Double = 0.0 // target amount
    var taxRatePercentage:Double = 0.0 // tax rate
    
    init (initialAmount:Double,periodicalAmount:Double,targetAmount:Double, ratePercentage:Double,inflationPercentage:Double = 0.0,vestingPeriod:Int,taxRatePercentage:Double = 0.0){
        self.targetAmount = targetAmount
        self.initialAmount=initialAmount
        self.periodicalAmount = periodicalAmount
        self.ratePercentage = ratePercentage
        self.inflationPercentage = inflationPercentage
        self.vestingPeriod = vestingPeriod
        self.taxRatePercentage = taxRatePercentage
    }
    func getFactor(option:VestingOption) -> Int {
        var factor = 1
        switch option {
        case .Annually:
            factor = 1
        case .Monthly:
            factor = 12
        case .Quarterly:
            factor = 4
        }
        return factor
    }
    func solveTargetAmount(option:VestingOption) -> Double {
        var factor = getFactor(option)
        var newRatePercentage = ratePercentage / Double(factor)
        var newInflationPercentage = inflationPercentage / Double(factor)
        var newVestingPeriod = vestingPeriod * factor
        var afterTax = (100-self.taxRatePercentage)/100.0
        // NOTE: compound interest
        var effectRate:Double = (1.0+newRatePercentage*afterTax/100.0-newInflationPercentage/100.0)
        var compound:Double = initialAmount*pow(effectRate, Double(newVestingPeriod))
        // NOTE: periodical installment
        var accumulatedInstallment:Double = 0
        if (effectRate != 1) {
            var gain:Double = (pow(effectRate,Double(newVestingPeriod))-1)/(effectRate-1)
            accumulatedInstallment = (periodicalAmount/Double(factor)) * gain
        } else {
            accumulatedInstallment = (periodicalAmount/Double(factor)) * Double(newVestingPeriod)
        }
        return compound+accumulatedInstallment
    }
    func solvePeriodicalAmount(option:VestingOption) -> Double{
        var calc0 = QuickCalc(initialAmount: self.initialAmount, periodicalAmount: 0, targetAmount: 0, ratePercentage: self.ratePercentage, inflationPercentage: self.inflationPercentage, vestingPeriod: self.vestingPeriod)
        var compound:Double = calc0.solveTargetAmount(option)
        var factor = getFactor(option)
        var newRatePercentage = ratePercentage / Double(factor)
        var newInflationPercentage = inflationPercentage / Double(factor)
        var newVestingPeriod = vestingPeriod * factor
        var gain:Double = 0
        var afterTax = (100-self.taxRatePercentage)/100.0
        var effectRate:Double = (1.0+newRatePercentage*afterTax/100.0-newInflationPercentage/100.0)
        if (effectRate != 1 ) {
            gain = (pow(effectRate,Double(newVestingPeriod))-1)/(effectRate-1)
        } else {
            gain = Double(newVestingPeriod)
        }
        return (targetAmount-compound)/gain*Double(factor)
    }
    func solveInitialAmount(option:VestingOption) -> Double {
        var calc0 = QuickCalc(initialAmount: 0, periodicalAmount: self.periodicalAmount, targetAmount: 0, ratePercentage: self.ratePercentage, inflationPercentage: self.inflationPercentage, vestingPeriod: self.vestingPeriod)
        var accumulatedInstallment:Double = calc0.solveTargetAmount(option)
        var factor = getFactor(option)
        var newRatePercentage = ratePercentage / Double(factor)
        var newInflationPercentage = inflationPercentage / Double(factor)
        var newVestingPeriod = vestingPeriod * factor
        var afterTax = (100-self.taxRatePercentage)/100.0
        var effectRate:Double = (1.0+newRatePercentage*afterTax/100.0-newInflationPercentage/100.0)
        return (targetAmount-accumulatedInstallment)/pow(effectRate, Double(newVestingPeriod))
    }
    func solveVestingPeriod(option:VestingOption) -> Double {
        var factor = getFactor(option)
        var rawPeriod = 0.0
        var newRatePercentage = ratePercentage / Double(factor)
        var newInflationPercentage = inflationPercentage / Double(factor)
        var newPeriodAmount = periodicalAmount / Double(factor)
        var afterTax = (100-self.taxRatePercentage)/100.0
        var effectRate:Double = (1.0+newRatePercentage*afterTax/100.0-newInflationPercentage/100.0)
        if (effectRate != 1) {
            rawPeriod = (log10((targetAmount*(effectRate-1)+newPeriodAmount))-log10(initialAmount*effectRate-initialAmount+newPeriodAmount))/log10(effectRate)
        } else if (effectRate < 1) {
            rawPeriod = 0.0
        } else {
            rawPeriod = (targetAmount - initialAmount)/periodicalAmount
        }
        return Double(rawPeriod)/Double(factor)
    }
    func solveRatePercentage(option:VestingOption) -> Double {
        var rate:Double = 0.0
        if (vestingPeriod == 0) {
            rate = 0.0
        } else if (periodicalAmount != 0) {
            var rateInc:Double = 0.1
            var calc1 = QuickCalc(initialAmount: self.initialAmount, periodicalAmount: self.periodicalAmount, targetAmount: 0.0, ratePercentage: rate, inflationPercentage: self.inflationPercentage, vestingPeriod: self.vestingPeriod)
            while calc1.solveTargetAmount(option) < targetAmount {
                rate+=rateInc;
                calc1 = QuickCalc(initialAmount: self.initialAmount, periodicalAmount: self.periodicalAmount, targetAmount: 0.0, ratePercentage: rate, inflationPercentage: self.inflationPercentage, vestingPeriod: self.vestingPeriod)
            }
        } else if (initialAmount != 0) {
            var factor = getFactor(option)
            var newVestingPeriod = vestingPeriod * factor
            var effectRate:Double = pow(10.0,log10(targetAmount/initialAmount)/Double(newVestingPeriod))
            rate = (effectRate - 1.0 + inflationPercentage*Double(factor)/100.0)*100.0*Double(factor)
        }
        var afterTax = (100-self.taxRatePercentage)/100.0
        return rate/afterTax
    }
}

