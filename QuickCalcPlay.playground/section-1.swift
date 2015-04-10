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
    
    init (initialAmountValue:Double,periodicalAmountValue:Double,targetAmountValue:Double, ratePercentageValue:Double,inflationPercentageValue:Double,vestingPeriodValue:Int){
        targetAmount = targetAmountValue
        initialAmount=initialAmountValue
        periodicalAmount = periodicalAmountValue
        ratePercentage = ratePercentageValue
        inflationPercentage = inflationPercentageValue
        vestingPeriod = vestingPeriodValue
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
        // NOTE: compound interest
        var effectRate:Double = (1.0+newRatePercentage/100.0-newInflationPercentage/100.0)
        var compound:Double = initialAmount*pow(effectRate, Double(newVestingPeriod))
        // NOTE: periodical installment
        var accumulatedInstallment:Double = 0
        newVestingPeriod-=1 // the last installment does not count
        
        while newVestingPeriod > 0 {
            accumulatedInstallment+=(periodicalAmount/Double(factor))*pow(effectRate, Double(newVestingPeriod))
            newVestingPeriod-=1
        }
        return compound+accumulatedInstallment
    }
    func solvePeriodicalAmount(option:VestingOption) -> Double{
        var calc0 = QuickCalc(initialAmountValue: initialAmount, periodicalAmountValue: 0, targetAmountValue: 0, ratePercentageValue: ratePercentage, inflationPercentageValue: inflationPercentage, vestingPeriodValue: vestingPeriod)
        var compound:Double = calc0.solveTargetAmount(option)
        var factor = getFactor(option)
        var newRatePercentage = ratePercentage / Double(factor)
        var newInflationPercentage = inflationPercentage / Double(factor)
        var newVestingPeriod = vestingPeriod * factor
        newVestingPeriod-=1
        var gain:Double = 0
        var effectRate:Double = (1.0+newRatePercentage/100.0-newInflationPercentage/100.0)
        while newVestingPeriod > 0 {
            gain+=pow(effectRate, Double(newVestingPeriod))
            newVestingPeriod-=1
        }
        return (targetAmount-compound)/gain*Double(factor)
    }
    func solveInitialAmount(option:VestingOption) -> Double {
        var calc0 = QuickCalc(initialAmountValue: 0, periodicalAmountValue: periodicalAmount, targetAmountValue: 0, ratePercentageValue: ratePercentage, inflationPercentageValue: inflationPercentage, vestingPeriodValue: vestingPeriod)
        var accumulatedInstallment:Double = calc0.solveTargetAmount(option)
        var factor = getFactor(option)
        var newRatePercentage = ratePercentage / Double(factor)
        var newInflationPercentage = inflationPercentage / Double(factor)
        var newVestingPeriod = vestingPeriod * factor
        var effectRate:Double = (1.0+newRatePercentage/100.0-newInflationPercentage/100.0)
        return (targetAmount-accumulatedInstallment)/pow(effectRate, Double(newVestingPeriod))
    }
    func solveVestingPeriod(option:VestingOption) -> Double {
        var factor = getFactor(option)
        var rawPeriod = 0
        var newRatePercentage = ratePercentage / Double(factor)
        var newInflationPercentage = inflationPercentage / Double(factor)
        var compound:Double = initialAmount
        var accumulation:Double = 0.0
        var effectRate:Double = (1.0+newRatePercentage/100.0-newInflationPercentage/100.0)
        if ((targetAmount > (compound+accumulation)) && (effectRate < 1.0 || (initialAmount+periodicalAmount/Double(factor))<=0)) {
            return -1.0
        }
        while (targetAmount>(compound+accumulation)) {
            compound*=effectRate
            accumulation=accumulation*effectRate+periodicalAmount/Double(factor)
            rawPeriod+=1
        }
        return Double(rawPeriod)/Double(factor)
    }
    func solveRatePercentage(option:VestingOption) -> Double {
        var rate:Double = 0.1
        var rateInc:Double = 0.1
        var calc1 = QuickCalc(initialAmountValue: initialAmount, periodicalAmountValue: periodicalAmount, targetAmountValue: 0.0, ratePercentageValue: rate, inflationPercentageValue: inflationPercentage, vestingPeriodValue: vestingPeriod)
        while calc1.solveTargetAmount(option) < targetAmount {
            rate+=rateInc;
            calc1 = QuickCalc(initialAmountValue: initialAmount, periodicalAmountValue: periodicalAmount, targetAmountValue: 0.0, ratePercentageValue: rate, inflationPercentageValue: inflationPercentage, vestingPeriodValue: vestingPeriod)
        }
        return rate
    }
}

