//
//  BarChartDataEntry.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class BarChartDataEntry: ChartDataEntry
{
    /// the values the stacked barchart holds
    private var _yVals: [Double]?
    
    /// the ranges for the individual stack values - automatically calculated
    private var _ranges: [Range]?
    
    /// the sum of all negative values this entry (if stacked) contains
    private var _negativeSum: Double = 0.0
    
    /// the sum of all positive values this entry (if stacked) contains
    private var _positiveSum: Double = 0.0
    
    var z: Double = 0
    
    public required init()
    {
        super.init()
    }
    
    /// Constructor for normal bars (not stacked).
    public init(x: Double, y: Double, z: Double)
    {
        self.z = z
        super.init(x: x, y: y)
    }
    
    /// Constructor for normal bars (not stacked).
    public convenience init(x: Double, y: Double, data: Any?)
    {
        self.init(x: x, y: y, z: 9.1)
        self.data = data
    }
    
    /// Constructor for normal bars (not stacked).
    public convenience init(x: Double, y: Double, icon: NSUIImage?)
    {
        self.init(x: x, y: y, z: 9.1)
        self.icon = icon
    }
    
    /// Constructor for normal bars (not stacked).
    public convenience init(x: Double, y: Double, icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, y: y, z: 9.1)
        self.icon = icon
        self.data = data
    }
    
    /// Constructor for stacked bar entries.
    @objc public init(x: Double, yValues: [Double])
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(values: yValues))
        self._yVals = yValues
        calcPosNegSum()
        calcRanges()
    }

    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public convenience init(x: Double, yValues: [Double], icon: NSUIImage?)
    {
        self.init(x: x, yValues: yValues)
        self.icon = icon
    }

    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public convenience init(x: Double, yValues: [Double], data: Any?)
    {
        self.init(x: x, yValues: yValues)
        self.data = data
    }

    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public convenience init(x: Double, yValues: [Double], icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, yValues: yValues)
        self.icon = icon
        self.data = data
    }
    
    @objc open func sumBelow(stackIndex: Int) -> Double
    {
        guard let yVals = _yVals, yVals.indices.contains(stackIndex) else
        {
            return 0
        }

        let remainder = yVals[stackIndex...].reduce(into: 0.0) { $0 += $1 }
        return remainder
    }
    
    /// The sum of all negative values this entry (if stacked) contains. (this is a positive number)
    @objc open var negativeSum: Double
    {
        return _negativeSum
    }
    
    /// The sum of all positive values this entry (if stacked) contains.
    @objc open var positiveSum: Double
    {
        return _positiveSum
    }

    var stackSize: Int { yValues?.count ?? 1}

    @objc open func calcPosNegSum()
    {
        (_negativeSum, _positiveSum) = _yVals?.reduce(into: (0,0)) { (result, y) in
            if y < 0
            {
                result.0 += -y
            }
            else
            {
                result.1 += y
            }
        } ?? (0,0)
    }
    
    /// Splits up the stack-values of the given bar-entry into Range objects.
    ///
    /// - Parameters:
    ///   - entry:
    /// - Returns:
    @objc open func calcRanges()
    {
        guard let values = yValues, !values.isEmpty else { return }

        if _ranges == nil
        {
            _ranges = [Range]()
        }
        else
        {
            _ranges!.removeAll()
        }
        
        _ranges!.reserveCapacity(values.count)
        
        var negRemain = -negativeSum
        var posRemain: Double = 0.0
        
        for value in values
        {
            if value < 0
            {
                _ranges!.append(Range(from: negRemain, to: negRemain - value))
                negRemain -= value
            }
            else
            {
                _ranges!.append(Range(from: posRemain, to: posRemain + value))
                posRemain += value
            }
        }
    }
    
    // MARK: Accessors
    
    /// the values the stacked barchart holds
    @objc open var isStacked: Bool { return _yVals != nil }
    
    /// the values the stacked barchart holds
    @objc open var yValues: [Double]?
    {
        get { return self._yVals }
        set
        {
            self.y = BarChartDataEntry.calcSum(values: newValue ?? [])
            self._yVals = newValue
            calcPosNegSum()
            calcRanges()
        }
    }
    
    /// The ranges of the individual stack-entries. Will return null if this entry is not stacked.
    @objc open var ranges: [Range]?
    {
        return _ranges
    }
    
    // MARK: NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! BarChartDataEntry
        copy._yVals = _yVals
        copy.y = y
        copy._negativeSum = _negativeSum
        copy._positiveSum = _positiveSum
        return copy
    }
    
    /// Calculates the sum across all values of the given stack.
    ///
    /// - Parameters:
    ///   - vals:
    /// - Returns:
    private static func calcSum(values: [Double]) -> Double
    {
        values.reduce(into: 0, +=)
    }
}
