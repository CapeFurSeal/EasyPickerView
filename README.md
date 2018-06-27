# EasyPickerView

An easy extension to show a picker view

# Usage

1. Import `EasyPickerView.swift` into your project.
2. Add the `EasyPickerViewDelegate` to your `ViewController`
3. Setup PickerView: `var pickerView: EasyPickerView!`
4. Remember to declare the delegate `pickerView.delegates = self`
5. Add the EasyPickerView to your subview self.view.addSubview(pickerView)` 
3. Finally show the EasyPickerView `pickerView.showPickerView()`

## Examples

```
let easyPickerView = PickerView()
easyPickerView.translatesAutoresizingMaskIntoConstraints = false
easyPickerView.dataSource = self
easyPickerView.delegate = self
view.addSubview(examplePicker)
view.addConstraints([easyPickerConstraints])

@objc public protocol EasyPickerViewDataSource: class {
func easyPickerViewNumberOfRows(_ pickerView: EasyPickerView) -> Int
func easyPickerickerView(_ pickerView: EasyPickerView, titleForRow row: Int, index: Int) -> String
}

```
