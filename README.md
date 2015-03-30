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
import UIKit
class ViewController: UIViewController, EasyPickerViewDelegate {
    var easyPickerView: EasyPickerView!
    let easyArray = ["option1", "option2", "option3", "option4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView = EasyPickerView()
        pickerView.delegates = self
        
        if let window = UIApplication.sharedApplication().keyWindow {
            window.addSubview(pickerView)
        } else {
            self.view.addSubview(pickerView)
        }
        
        let easyButton = UIButton.buttonWithType(UIButtonType.InfoDark) as UIButton
        easyButton.frame = CGRectMake(50, 50, 40, 40);
        easyButton.addTarget(self, action: "enableEasyPicker", forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(easyButton)
    }
    func enableEasyPicker() {
        pickerView.showPickerView()
    }
    
    override func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
     }
    override func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return easyArray.count
    }
    override func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return easyArray[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectPicker pickerRows: [Int]) {
        println(pickerRows)
    }
}
```
