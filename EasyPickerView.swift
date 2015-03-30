class EasyPickerView: UIView {
    var easyPickerView: UIPickerView!
    var easyPickerViewToolbar: UIToolbar!
    var easyPickerViewtoolbarItems: [UIBarItem]!
    
    var delegates: EasyPickerViewDelegate? {
        didSet {
            easyPickerView.delegate = delegates
        }
    }
    private var selectedPickerRows: [Int]?
    
    override init() {
        super.init()
        initiationFunction()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initiationFunction()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initiationFunction()
    }
    private func initiationFunction() {
        let screenSize = UIScreen.mainScreen().bounds.size
        self.backgroundColor = UIColor.blackColor()
        
        easyPickerViewToolbar = UIToolbar()
        easyPickerView = UIPickerView()
        easyPickerViewtoolbarItems = []
        
        easyPickerViewToolbar.translucent = true
        easyPickerView.showsSelectionIndicator = true
        easyPickerView.backgroundColor = UIColor.whiteColor()
        
        self.bounds = CGRectMake(0, 0, screenSize.width, 260)
        self.frame = CGRectMake(0, screenSize.height, screenSize.width, 260)
        easyPickerViewToolbar.bounds = CGRectMake(0, 0, screenSize.width, 44)
        easyPickerViewToolbar.frame = CGRectMake(0, 0, screenSize.width, 44)
        easyPickerView.bounds = CGRectMake(0, 0, screenSize.width, 216)
        easyPickerView.frame = CGRectMake(0, 44, screenSize.width, 216)
        
        let spaces = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        spaces.width = 15
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("finishPickerAction"))
        easyPickerViewtoolbarItems! += [spaces, flexibleSpace, doneButtonItem, spaces]
        
        easyPickerViewToolbar.setItems(easyPickerViewtoolbarItems, animated: false)
        self.addSubview(easyPickerViewToolbar)
        self.addSubview(easyPickerView)
    }
    func showPickerView() {
        if selectedPickerRows == nil {
            selectedPickerRows = getSelectedPickerRows()
        }
        let screenSize = UIScreen.mainScreen().bounds.size
        UIView.animateWithDuration(0.2) {
            self.frame = CGRectMake(0, screenSize.height - 260.0, screenSize.width, 260.0)
        }
    }
    
    func finishPickerAction() {
        hidePickerView()
        delegates?.easyPickerView?(easyPickerView, didSelectPicker: getSelectedPickerRows())
        selectedPickerRows = nil
    }
    private func hidePickerView() {
        let screenSize = UIScreen.mainScreen().bounds.size
        UIView.animateWithDuration(0.2) {
            self.frame = CGRectMake(0, screenSize.height, screenSize.width, 260.0)
        }
    }
    private func getSelectedPickerRows() -> [Int] {
        var selectedPickerRows = [Int]()
        for i in 0..<easyPickerView.numberOfComponents {
            selectedPickerRows.append(easyPickerView.selectedRowInComponent(i))
        }
        return selectedPickerRows
    }
    private func restoreSelectedRows() {
        for i in 0..<selectedPickerRows!.count {
            easyPickerView.selectRow(selectedPickerRows![i], inComponent: i, animated: true)
        }
    }
}

@objc
protocol EasyPickerViewDelegate: UIPickerViewDelegate {
    optional func easyPickerView(pickerView: UIPickerView, didSelectPicker pickerRows: [Int])
}
