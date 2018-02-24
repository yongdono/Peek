/*
 Copyright © 23/04/2016 Shaps
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit

internal final class PeekContext: Context {
    
    @objc fileprivate(set) var properties = [Property]()
    
    @objc func configure(_ inspector: Inspector, _ category: String, configuration: (_ config: Configuration) -> Void) {
        let config = PeekConfiguration(category: category, inspector: inspector)
        configuration(config)
        properties.append(contentsOf: config.properties)
    }
    
}

final class PeekConfiguration: Configuration {
    
    fileprivate var category: String
    fileprivate var inspector: Inspector
    fileprivate(set) var properties = [Property]()
    
    init(category: String, inspector: Inspector) {
        self.category = category
        self.inspector = inspector
    }
    
    @objc func addProperty(_ keyPath: String, displayName: String? = nil, cellConfiguration: PropertyCellConfiguration = nil) -> Property {
        let property = PeekProperty(keyPath: keyPath, displayName: displayName, category: category, inspector: inspector, configuration: cellConfiguration)
        properties.append(property)
        return property
    }
    
    @objc func addProperties(_ keyPaths: [String]) -> [Property] {
        var properties = [Property]()
        keyPaths.forEach { properties.append(addProperty($0)) }
        return properties
    }
    
    @objc func addProperties(keyPaths: [[String : String]]) -> [Property] {
        return keyPaths.flatMap {
            guard let key = $0.keys.first, let value = $0.values.first else { return nil }
            return addProperty(key, displayName: value, cellConfiguration: nil)
        }
    }
    
}

final class PeekProperty: Property, CustomStringConvertible, Equatable {
    
    @objc let keyPath: String
    @objc let displayName: String
    @objc let category: String
    @objc let inspector: Inspector
    @objc var configurationBlock: PropertyCellConfiguration
    
    var description: String {
        return "\(displayName) – \(keyPath)"
    }
    
    @objc init(keyPath: String, displayName: String?, category: String, inspector: Inspector, configuration: PropertyCellConfiguration = nil) {
        self.keyPath = keyPath
        self.displayName = displayName ?? String.capitalized(keyPath)
        self.category = category
        self.inspector = inspector
        self.configurationBlock = configuration
    }
    
    @objc func value(forModel model: AnyObject) -> Any? {
        return model.value(forKeyPath: keyPath)
    }
    
}

func ==(lhs: PeekProperty, rhs: PeekProperty) -> Bool {
    return lhs.keyPath == rhs.keyPath && lhs.category == rhs.category && lhs.inspector == rhs.inspector
}
