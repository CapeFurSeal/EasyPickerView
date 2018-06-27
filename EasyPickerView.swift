//
//  EasyPickerView.swift
//
//  Created by Blake Loizides on 19/05/15.
//  Copyright (c) 2018 Blake Loizides. All rights reserved.
//

import UIKit

// MARK: - EasyPickerView Protocols
@objc public protocol EasyPickerViewDataSource: class {
    func easyPickerViewNumberOfRows(_ pickerView: EasyPickerView) -> Int
    func easyPickerView(_ pickerView: EasyPickerView, titleForRow row: Int, index: Int) -> String
}

@objc public protocol EasyPickerViewDelegate: class {
    func easyPickerViewHeightForRows(_ pickerView: EasyPickerView) -> CGFloat
    @objc optional func easyPickerView(_ pickerView: EasyPickerView, didSelectRow row: Int, index: Int)
    @objc optional func easyPickerView(_ pickerView: EasyPickerView, didTapRow row: Int, index: Int)
    @objc optional func easyPickerView(_ pickerView: EasyPickerView, styleFor label: UILabel, highlighted: Bool)
    @objc optional func pickerView(_ pickerView: EasyPickerView, viewForRow row: Int, index: Int, highlighted: Bool, reusingView view: UIView?) -> UIView?
}

open class EasyPickerView: UIView {
    
    // MARK: Nested Types
    fileprivate class SimplePickerTableViewCell: UITableViewCell {
        lazy var titleLabel: UILabel = {
            let titleLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.contentView.frame.width, height: self.contentView.frame.height))
            titleLabel.textAlignment = .center
            
            return titleLabel
        }()
        
        var customView: UIView?
    }

    @objc public enum ScrollingStyle: Int {
        case `default`, infinite
    }
    
    @objc public enum SelectionStyle: Int {
        case none, defaultIndicator, overlay, image
    }
    
    var enabled = true {
        didSet {
            if enabled {
                enableEasyPickerView()
            } else {
                disableEasyPickerView()
            }
        }
    }
    
    fileprivate var selectionOverlayH: NSLayoutConstraint!
    fileprivate var selectionImageH: NSLayoutConstraint!
    fileprivate var selectionIndicatorB: NSLayoutConstraint!
    fileprivate var pickerCellBackgroundColor: UIColor?
    
    var numberOfRowsByDataSource: Int {
        get {
            return dataSource?.easyPickerViewNumberOfRows(self) ?? 0
        }
    }
    
    var rowHeight: CGFloat {
        get {
            return delegate?.easyPickerViewHeightForRows(self) ?? 0
        }
    }
    
    override open var backgroundColor: UIColor? {
        didSet {
            self.tableView.backgroundColor = self.backgroundColor
            self.pickerCellBackgroundColor = self.backgroundColor
        }
    }
    
    fileprivate let pickerViewCellIdentifier = "pickerViewCell"
    
    open weak var dataSource: EasyPickerViewDataSource?
    open weak var delegate: EasyPickerViewDelegate?
    
    open lazy var defaultSelectionIndicator: UIView = {
        let selectionIndicator = UIView()
        selectionIndicator.backgroundColor = self.tintColor
        selectionIndicator.alpha = 0.0
        
        return selectionIndicator
    }()
    
    open lazy var selectionOverlay: UIView = {
        let selectionOverlay = UIView()
        selectionOverlay.backgroundColor = self.tintColor
        selectionOverlay.alpha = 0.0
        
        return selectionOverlay
    }()
    
    open lazy var selectionImageView: UIImageView = {
        let selectionImageView = UIImageView()
        selectionImageView.alpha = 0.0
        
        return selectionImageView
    }()
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        return tableView
    }()
    
    fileprivate var infinityRowsMultiplier: Int = 1
    fileprivate var hasTouchedPickerViewYet = false
    open var currentSelectedRow: Int!
    open var currentSelectedIndex: Int {
        get {
            return indexForRow(currentSelectedRow)
        }
    }
    
    fileprivate var firstTimeOrientationChanged = true
    fileprivate var orientationChanged = false
    fileprivate var isScrolling = false
    fileprivate var setupHasBeenDone = false
    fileprivate var shouldSelectNearbyToMiddleRow = true
    
    open var scrollingStyle = ScrollingStyle.default {
        didSet {
            switch scrollingStyle {
            case .default:
                infinityRowsMultiplier = 1
            case .infinite:
                infinityRowsMultiplier = generateInfinityRowsMultiplier()
            }
        }
    }
    
    open var selectionStyle = SelectionStyle.none {
        didSet {
            setupSelectionViewsVisibility()
        }
    }
    
    // MARK: Initialization
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: Subviews Setup
    
    fileprivate func setup() {
        infinityRowsMultiplier = generateInfinityRowsMultiplier()
        
        // Setup subviews constraints and apperance
        translatesAutoresizingMaskIntoConstraints = false
        setupTableView()
        setupSelectionOverlay()
        setupSelectionImageView()
        setupDefaultSelectionIndicator()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        // This needs to be done after a delay - I am guessing it basically needs to be called once
        // the view is already displaying
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            // Some UI Adjustments we need to do after setting UITableView data source & delegate.
            self.adjustSelectionOverlayHeightConstraint()
        }
    }
    
    fileprivate func setupTableView() {
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.separatorColor = .none
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.scrollsToTop = false
        tableView.register(SimplePickerTableViewCell.classForCoder(), forCellReuseIdentifier: self.pickerViewCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        let tableViewH = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: self,
                                            attribute: .height, multiplier: 1, constant: 0)
        addConstraint(tableViewH)
        
        let tableViewW = NSLayoutConstraint(item: tableView, attribute: .width, relatedBy: .equal, toItem: self,
                                            attribute: .width, multiplier: 1, constant: 0)
        addConstraint(tableViewW)
        
        let tableViewL = NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: self,
                                            attribute: .leading, multiplier: 1, constant: 0)
        addConstraint(tableViewL)
        
        let tableViewTop = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self,
                                              attribute: .top, multiplier: 1, constant: 0)
        addConstraint(tableViewTop)
        
        let tableViewBottom = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self,
                                                 attribute: .bottom, multiplier: 1, constant: 0)
        addConstraint(tableViewBottom)
        
        let tableViewT = NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: self,
                                            attribute: .trailing, multiplier: 1, constant: 0)
        addConstraint(tableViewT)
    }
    
    fileprivate func setupSelectionViewsVisibility() {
        switch selectionStyle {
        case .defaultIndicator:
            defaultSelectionIndicator.alpha = 1.0
            selectionOverlay.alpha = 0.0
            selectionImageView.alpha = 0.0
        case .overlay:
            selectionOverlay.alpha = 0.25
            defaultSelectionIndicator.alpha = 0.0
            selectionImageView.alpha = 0.0
        case .image:
            selectionImageView.alpha = 1.0
            selectionOverlay.alpha = 0.0
            defaultSelectionIndicator.alpha = 0.0
        case .none:
            selectionOverlay.alpha = 0.0
            defaultSelectionIndicator.alpha = 0.0
            selectionImageView.alpha = 0.0
        }
    }
    
    fileprivate func setupSelectionOverlay() {
        selectionOverlay.isUserInteractionEnabled = false
        selectionOverlay.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(selectionOverlay)
        
        selectionOverlayH = NSLayoutConstraint(item: selectionOverlay, attribute: .height, relatedBy: .equal, toItem: nil,
                                               attribute: .notAnAttribute, multiplier: 1, constant: rowHeight)
        self.addConstraint(selectionOverlayH)
        
        let selectionOverlayW = NSLayoutConstraint(item: selectionOverlay, attribute: .width, relatedBy: .equal, toItem: self,
                                                   attribute: .width, multiplier: 1, constant: 0)
        addConstraint(selectionOverlayW)
        
        let selectionOverlayL = NSLayoutConstraint(item: selectionOverlay, attribute: .leading, relatedBy: .equal, toItem: self,
                                                   attribute: .leading, multiplier: 1, constant: 0)
        addConstraint(selectionOverlayL)
        
        let selectionOverlayT = NSLayoutConstraint(item: selectionOverlay, attribute: .trailing, relatedBy: .equal, toItem: self,
                                                   attribute: .trailing, multiplier: 1, constant: 0)
        addConstraint(selectionOverlayT)
        
        let selectionOverlayY = NSLayoutConstraint(item: selectionOverlay, attribute: .centerY, relatedBy: .equal, toItem: self,
                                                   attribute: .centerY, multiplier: 1, constant: 0)
        addConstraint(selectionOverlayY)
    }
    
    fileprivate func setupSelectionImageView() {
        selectionImageView.isUserInteractionEnabled = false
        selectionImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(selectionImageView)
        
        selectionImageH = NSLayoutConstraint(item: selectionImageView, attribute: .height, relatedBy: .equal, toItem: nil,
                                             attribute: .notAnAttribute, multiplier: 1, constant: rowHeight)
        self.addConstraint(selectionImageH)
        
        let selectionImageW = NSLayoutConstraint(item: selectionImageView, attribute: .width, relatedBy: .equal, toItem: self,
                                                 attribute: .width, multiplier: 1, constant: 0)
        addConstraint(selectionImageW)
        
        let selectionImageL = NSLayoutConstraint(item: selectionImageView, attribute: .leading, relatedBy: .equal, toItem: self,
                                                 attribute: .leading, multiplier: 1, constant: 0)
        addConstraint(selectionImageL)
        
        let selectionImageT = NSLayoutConstraint(item: selectionImageView, attribute: .trailing, relatedBy: .equal, toItem: self,
                                                 attribute: .trailing, multiplier: 1, constant: 0)
        addConstraint(selectionImageT)
        
        let selectionImageY = NSLayoutConstraint(item: selectionImageView, attribute: .centerY, relatedBy: .equal, toItem: self,
                                                 attribute: .centerY, multiplier: 1, constant: 0)
        addConstraint(selectionImageY)
    }
    
    fileprivate func setupDefaultSelectionIndicator() {
        defaultSelectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(defaultSelectionIndicator)
        
        let selectionIndicatorH = NSLayoutConstraint(item: defaultSelectionIndicator, attribute: .height, relatedBy: .equal, toItem: nil,
                                                     attribute: .notAnAttribute, multiplier: 1, constant: 2.0)
        addConstraint(selectionIndicatorH)
        
        let selectionIndicatorW = NSLayoutConstraint(item: defaultSelectionIndicator, attribute: .width, relatedBy: .equal,
                                                     toItem: self, attribute: .width, multiplier: 1, constant: 0)
        addConstraint(selectionIndicatorW)
        
        let selectionIndicatorL = NSLayoutConstraint(item: defaultSelectionIndicator, attribute: .leading, relatedBy: .equal,
                                                     toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        addConstraint(selectionIndicatorL)
        
        selectionIndicatorB = NSLayoutConstraint(item: defaultSelectionIndicator, attribute: .bottom, relatedBy: .equal,
                                                 toItem: self, attribute: .centerY, multiplier: 1, constant: (rowHeight / 2))
        addConstraint(selectionIndicatorB)
        
        let selectionIndicatorT = NSLayoutConstraint(item: defaultSelectionIndicator, attribute: .trailing, relatedBy: .equal,
                                                     toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        addConstraint(selectionIndicatorT)
    }
    
    // MARK: Infinite Scrolling Helpers
    
    fileprivate func generateInfinityRowsMultiplier() -> Int {
        if scrollingStyle == .default {
            return 1
        }
        
        if numberOfRowsByDataSource > 100 {
            return 100
        } else if numberOfRowsByDataSource < 100 && numberOfRowsByDataSource > 50 {
            return 200
        } else if numberOfRowsByDataSource < 50 && numberOfRowsByDataSource > 25 {
            return 400
        } else {
            return 800
        }
    }
    
    // MARK: Life Cycle
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if let _ = newWindow {
            NotificationCenter.default.addObserver(self, selector: #selector(EasyPickerView.adjustCurrentSelectedAfterOrientationChanges),
                                                   name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if !setupHasBeenDone {
            setup()
            setupHasBeenDone = true
        }
    }
    
    fileprivate func adjustSelectionOverlayHeightConstraint() {
        if selectionOverlayH.constant != rowHeight || selectionImageH.constant != rowHeight || selectionIndicatorB.constant != (rowHeight / 2) {
            selectionOverlayH.constant = rowHeight
            selectionImageH.constant = rowHeight
            selectionIndicatorB.constant = -(rowHeight / 2)
            layoutIfNeeded()
        }
    }
    
    @objc func adjustCurrentSelectedAfterOrientationChanges() {
        setNeedsLayout()
        layoutIfNeeded()
        
        shouldSelectNearbyToMiddleRow = true
        
        if firstTimeOrientationChanged {
            firstTimeOrientationChanged = false
            return
        }
        
        if !isScrolling {
            return
        }
        
        orientationChanged = true
    }
    
    fileprivate func indexForRow(_ row: Int) -> Int {
        return row % (numberOfRowsByDataSource > 0 ? numberOfRowsByDataSource : 1)
    }
    
    // MARK: - Actions
    
    /**
     Selects the nearby to middle row that matches with the provided index.
     
     - parameter row: A valid index provided by Data Source.
     */
    fileprivate func selectedNearbyToMiddleRow(_ row: Int) {
        currentSelectedRow = row
        tableView.reloadData()
        
        // This line adjust the contentInset to UIEdgeInsetZero because when the PickerView are inside of a UIViewController
        // presented by a UINavigation controller, the tableView contentInset is affected.
        tableView.contentInset = UIEdgeInsets.zero
        
        let indexOfSelectedRow = visibleIndexOfSelectedRow()
        tableView.setContentOffset(CGPoint(x: 0.0, y: CGFloat(indexOfSelectedRow) * rowHeight), animated: false)
        
        delegate?.easyPickerView?(self, didSelectRow: currentSelectedRow, index: currentSelectedIndex)
        shouldSelectNearbyToMiddleRow = false
    }
    
    /**
     Selects literally the row with index that the user tapped.
     
     - parameter row: The row index that the user tapped, i.e. the Data Source index times the `infinityRowsMultiplier`.
     */
    fileprivate func selectTappedRow(_ row: Int) {
        delegate?.easyPickerView?(self, didTapRow: row, index: indexForRow(row))
        selectRow(row, animated: true)
    }
    
    fileprivate func enableEasyPickerView() {
        tableView.isScrollEnabled = true
        setupSelectionViewsVisibility()
    }
    
    fileprivate func disableEasyPickerView() {
        tableView.isScrollEnabled = false
        selectionOverlay.alpha = 0.0
        defaultSelectionIndicator.alpha = 0.0
        selectionImageView.alpha = 0.0
    }
    
    /**
     This is an private helper that we use to reach the visible index of the current selected row.
     Because of we multiply the rows several times to create an Infinite Scrolling experience, the index of a visible selected row may
     not be the same as the index provided on Data Source.
     
     - returns: The visible index of current selected row.
     */
    fileprivate func visibleIndexOfSelectedRow() -> Int {
        let middleMultiplier = scrollingStyle == .infinite ? (infinityRowsMultiplier / 2) : infinityRowsMultiplier
        let middleIndex = numberOfRowsByDataSource * middleMultiplier
        let indexForSelectedRow: Int
        
        if let _ = currentSelectedRow , scrollingStyle == .default && currentSelectedRow == 0 {
            indexForSelectedRow = 0
        } else if let _ = currentSelectedRow {
            indexForSelectedRow = middleIndex - (numberOfRowsByDataSource - currentSelectedRow)
        } else {
            let middleRow = Int(ceil(Float(numberOfRowsByDataSource) / 2.0))
            indexForSelectedRow = middleIndex - (numberOfRowsByDataSource - middleRow)
        }
        
        return indexForSelectedRow
    }
    
    open func selectRow(_ row : Int, animated: Bool) {
        var finalRow = row
        
        if (scrollingStyle == .infinite && row <= numberOfRowsByDataSource) {
            let middleMultiplier = scrollingStyle == .infinite ? (infinityRowsMultiplier / 2) : infinityRowsMultiplier
            let middleIndex = numberOfRowsByDataSource * middleMultiplier
            finalRow = middleIndex - (numberOfRowsByDataSource - finalRow)
        }
        
        currentSelectedRow = finalRow
        
        delegate?.easyPickerView?(self, didSelectRow: currentSelectedRow, index: currentSelectedIndex)
        
        tableView.setContentOffset(CGPoint(x: 0.0, y: CGFloat(currentSelectedRow) * rowHeight), animated: animated)
    }
    
    open func reloadPickerView() {
        shouldSelectNearbyToMiddleRow = true
        tableView.reloadData()
    }
    
}

extension EasyPickerView: UITableViewDataSource {
    
    // MARK: UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = numberOfRowsByDataSource * infinityRowsMultiplier
        
        // Select the nearby to middle row when it's needed (first run or orientation change)
        if shouldSelectNearbyToMiddleRow && numberOfRows > 0 {
            // Configure the PickerView to select the middle row when the orientation changes during scroll
            if isScrolling {
                let middleRow = Int(ceil(Float(numberOfRowsByDataSource) / 2.0))
                selectedNearbyToMiddleRow(middleRow)
            } else {
                let rowToSelect = currentSelectedRow != nil ? currentSelectedRow : Int(ceil(Float(numberOfRowsByDataSource) / 2.0))
                selectedNearbyToMiddleRow(rowToSelect!)
            }
        }
        
        // If PickerView have items to show set it as enabled otherwise set it as disabled
        if numberOfRows > 0 {
            enableEasyPickerView()
        } else {
            disableEasyPickerView()
        }
        
        return numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indexOfSelectedRow = visibleIndexOfSelectedRow()
        
        let pickerViewCell = tableView.dequeueReusableCell(withIdentifier: pickerViewCellIdentifier, for: indexPath) as! SimplePickerTableViewCell
        
        let view = delegate?.pickerView?(self, viewForRow: (indexPath as NSIndexPath).row, index: indexForRow((indexPath as NSIndexPath).row), highlighted: (indexPath as NSIndexPath).row == indexOfSelectedRow, reusingView: pickerViewCell.customView)
        
        pickerViewCell.selectionStyle = .none
        pickerViewCell.backgroundColor = pickerCellBackgroundColor ?? UIColor.white
        
        if (view != nil) {
            var frame = view!.frame
            frame.origin.y = (indexPath as NSIndexPath).row == 0 ? (self.frame.height / 2) - (rowHeight / 2) : 0.0
            view!.frame = frame
            pickerViewCell.customView = view
            pickerViewCell.contentView.addSubview(pickerViewCell.customView!)
            
        } else {
            // As the first row have a different size to fit in the middle of the PickerView and rows below, the titleLabel position must be adjusted.
            let centerY = (indexPath as NSIndexPath).row == 0 ? (self.frame.height / 2) - (rowHeight / 2) : 0.0
            
            pickerViewCell.titleLabel.frame = CGRect(x: 0.0, y: centerY, width: frame.width, height: rowHeight)
            
            pickerViewCell.contentView.addSubview(pickerViewCell.titleLabel)
            pickerViewCell.titleLabel.backgroundColor = UIColor.clear
            pickerViewCell.titleLabel.text = dataSource?.easyPickerView(self, titleForRow: (indexPath as NSIndexPath).row, index: indexForRow((indexPath as NSIndexPath).row))
            
            delegate?.easyPickerView?(self, styleFor: pickerViewCell.titleLabel, highlighted: (indexPath as NSIndexPath).row == indexOfSelectedRow)
        }
        
        return pickerViewCell
    }
    
}

extension EasyPickerView: UITableViewDelegate {
    
    // MARK: UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectTappedRow((indexPath as NSIndexPath).row)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let numberOfRowsInPickerView = dataSource!.easyPickerViewNumberOfRows(self) * infinityRowsMultiplier
        
        // When the scrolling reach the end on top/bottom we need to set the first/last row to appear in the center of PickerView, so that row must be bigger.
        if (indexPath as NSIndexPath).row == 0 {
            return (frame.height / 2) + (rowHeight / 2)
        } else if numberOfRowsInPickerView > 0 && (indexPath as NSIndexPath).row == numberOfRowsInPickerView - 1 {
            return (frame.height / 2) + (rowHeight / 2)
        }
        
        return rowHeight
    }
    
}

extension EasyPickerView: UIScrollViewDelegate {
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let partialRow = Float(targetContentOffset.pointee.y / rowHeight) // Get the estimative of what row will be the selected when the scroll animation ends.
        var roundedRow = Int(lroundf(partialRow)) // Round the estimative to a row
        
        if roundedRow < 0 {
            roundedRow = 0
        } else {
            targetContentOffset.pointee.y = CGFloat(roundedRow) * rowHeight // Set the targetContentOffset (where the scrolling position will be when the animation ends) to a rounded value.
        }
        
        // Update the currentSelectedRow and notify the delegate that we have a new selected row.
        currentSelectedRow = roundedRow % numberOfRowsByDataSource
        
        delegate?.easyPickerView?(self, didSelectRow: currentSelectedRow, index: currentSelectedIndex)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // When the orientation changes during the scroll, is required to reset the picker to select the nearby to middle row.
        if orientationChanged {
            selectedNearbyToMiddleRow(currentSelectedRow)
            orientationChanged = false
        }
        
        isScrolling = false
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let partialRow = Float(scrollView.contentOffset.y / rowHeight)
        let roundedRow = Int(lroundf(partialRow))
        
        // Avoid to have two highlighted rows at the same time
        if let visibleRows = tableView.indexPathsForVisibleRows {
            for indexPath in visibleRows {
                if let cellToUnhighlight = tableView.cellForRow(at: indexPath) as? SimplePickerTableViewCell , (indexPath as NSIndexPath).row != roundedRow {
                    let _ = delegate?.pickerView?(self, viewForRow: (indexPath as NSIndexPath).row, index: indexForRow((indexPath as NSIndexPath).row), highlighted: false, reusingView: cellToUnhighlight.customView)
                    delegate?.easyPickerView?(self, styleFor: cellToUnhighlight.titleLabel, highlighted: false)
                }
            }
        }
        
        // Highlight the current selected cell during scroll
        if let cellToHighlight = tableView.cellForRow(at: IndexPath(row: roundedRow, section: 0)) as? SimplePickerTableViewCell {
            let _ = delegate?.pickerView?(self, viewForRow: roundedRow, index: indexForRow(roundedRow), highlighted: true, reusingView: cellToHighlight.customView)
            let _ = delegate?.easyPickerView?(self, styleFor: cellToHighlight.titleLabel, highlighted: true)
        }
    }
    
}
