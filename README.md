# EasyPickerView
<article class="markdown-body entry-content" itemprop="text">
 
<p align="center"><img src="https://camo.githubusercontent.com/709b02161cc5fa920dcf1017f12a209ab02e395a/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f53776966742d342e312d6f72616e67652e737667" data-canonical-src="https://img.shields.io/badge/Swift-4.1-orange.svg" style="max-width:100%;"> </p>

<p>An easy extension to show a picker view</p>

<p>Enjoy it! 🙂</p>

<h2>🌟 Features</h2>
<ul class="contains-task-list">
<li class="task-list-item"><input type="checkbox" id="" disabled="" class="task-list-item-checkbox" checked=""> Easy to use</li>
<li class="task-list-item"><input type="checkbox" id="" disabled="" class="task-list-item-checkbox" checked=""> Universal (iPhone &amp; iPad)</li>
<li class="task-list-item"><input type="checkbox" id="" disabled="" class="task-list-item-checkbox" checked=""> Interface Builder friendly</li>
<li class="task-list-item"><input type="checkbox" id="" disabled="" class="task-list-item-checkbox" checked=""> Simple Swift syntax</li>
<li class="task-list-item"><input type="checkbox" id="" disabled="" class="task-list-item-checkbox" checked=""> Lightweight readable codebase</li>
 <li class="task-list-item"><input type="checkbox" id="" disabled="" class="task-list-item-checkbox" checked=""> Unit Tested</li>
</ul>

<h3>📋 Supported OS &amp; SDK Versions</h3>
<ul>
<li>iOS 10.0+</li>
<li>Swift 4</li>
</ul>

<h3>🔮 Example</h3>

<pre><code>
let easyPickerView = PickerView()
easyPickerView.translatesAutoresizingMaskIntoConstraints = false
easyPickerView.dataSource = self
easyPickerView.delegate = self
view.addSubview(examplePicker)
view.addConstraints([easyPickerConstraints])

@objc public protocol EasyPickerViewDataSource: class {
func easyPickerViewNumberOfRows(_ pickerView: EasyPickerView) -> Int
func easyPickerickerView(_ pickerView: EasyPickerView, titleForRow row: Int, index: Int) -> String
}</code></pre>

<h2>👨🏻‍💻 Author</h2>

<ul>
<li>Blake Loizides <a href="http://www.twitter.com/capefurseal" rel="nofollow"><img src="https://camo.githubusercontent.com/7cf10772eb6ccebe92d678c452a971e6e2778653/687474703a2f2f692e696d6775722e636f6d2f7458536f5468462e706e67" alt="alt text" data-canonical-src="http://i.imgur.com/tXSoThF.png" style="max-width:100%;"></a></li>
</ul>
<p><a href="https://www.buymeacoffee.com/OQpzu8T" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a></p>

<h2>👮🏻 License</h2>
<pre><code>MIT License

Copyright (c) 2018 Blake Loizides

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
</code></pre>
</article>
