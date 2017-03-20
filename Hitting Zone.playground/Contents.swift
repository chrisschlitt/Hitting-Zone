/*
 * Hitting Zone
 * @author: Chris Schlitt (https://chrisschlitt.com)
 *
 * @data hits: [[Int]] -  array of coordinates in a 1-100 plane corresponding 
 *                        to locations in the strike zone where a baseball 
 *                        player has hit the ball
 * @data strikes: [[Int]] -  array of coordinates in a 1-100 plane corresponding 
 *                        to locations in the strike zone where a baseball 
 *                        player has swung and missed
 *
 * @output battersBoxView: UIView - A UIView showing a heat map corresponding
 *                        to the players strike zone. Lighter reds for more 
 *                        successful areas, darker blues for less successful areas
 *
 */

import UIKit
import PlaygroundSupport

// Color Extenstion
extension UIColor {
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
    
    static func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

// Create hits and strikes demo data
var hits = [[Int]]()
var strikes = [[Int]]()
for hit in 0..<500 {
    hits.append([Int(arc4random_uniform(99)), Int(arc4random_uniform(99))])
    strikes.append([Int(arc4random_uniform(99)), Int(arc4random_uniform(99))])
}

/*
 * Define how detailed the resulting view will be
 * In the form of a "box size" between 1 and 100
 * and a divisor of 100
 */
let detailed = 5
let numberOfBoxes = 100 / detailed

// Initialize the batter's box data
var battersBoxData = [[Int]]()
for i in 0..<numberOfBoxes {
    var row = [Int]()
    for ii in 0..<numberOfBoxes{
        row.append(0)
    }
    battersBoxData.append(row)
}

// Generate the batter's box data
// Note: This is built to account for different numbers of hits and strikes
for hit in hits {
    let boxX = hit[0] / (100 / numberOfBoxes)
    let boxY = hit[1] / (100 / numberOfBoxes)
    battersBoxData[boxX][boxY] += 1
}
for strike in strikes {
    let boxX = strike[0] / (100 / numberOfBoxes)
    let boxY = strike[1] / (100 / numberOfBoxes)
    battersBoxData[boxX][boxY] -= 1
}

// Calculate the max and min box score
var maxScore = 0
var minScore = 0
for i in 0..<numberOfBoxes {
    for ii in 0..<numberOfBoxes {
        if(battersBoxData[i][ii] < minScore){
            minScore = battersBoxData[i][ii]
        }
        if(battersBoxData[i][ii] > maxScore){
            maxScore = battersBoxData[i][ii]
        }
    }
}

// Create the batters box view
var battersBoxView = UIStackView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
battersBoxView.distribution = .fillEqually
battersBoxView.axis = .vertical
battersBoxView.backgroundColor = UIColor.groupTableViewBackground

// Iterate over the data and create the batters box view
for i in 0..<numberOfBoxes {
    // Create the view for the row
    var rowView = UIStackView(frame: CGRect(x: 0, y: (i * numberOfBoxes), width: 100, height: (100 / numberOfBoxes)))
    rowView.distribution = .fillEqually
    rowView.axis = .horizontal
    
    // Iterate over each cell in the row
    for ii in 0..<numberOfBoxes {
        
        // Create the cell
        let cellView = UIView(frame: CGRect(x: (ii * numberOfBoxes), y: (i * numberOfBoxes), width: (100 / numberOfBoxes), height: (100 / numberOfBoxes)))
        
        // Color the cell based on the cell's score
        if(battersBoxData[i][ii] > 0){
            // Calculate shade of red
            let shadeDirection = battersBoxData[i][ii] - (maxScore / 2)
            let shadeIntensity = CGFloat(abs((shadeDirection / (maxScore / 2)) * 1))
            if(shadeDirection > 0){
                cellView.backgroundColor = UIColor.red.lighter(by: CGFloat(shadeIntensity))
            } else {
                cellView.backgroundColor = UIColor.red.darker(by: CGFloat(shadeIntensity))
            }
        } else if(battersBoxData[i][ii] < 0){
            // Calculate shade of blue
            let shadeDirection = abs(battersBoxData[i][ii]) - (abs(minScore) / 2)
            let shadeIntensity = CGFloat(abs((shadeDirection / (abs(minScore) / 2)) * 1))
            if(shadeDirection < 0){
                cellView.backgroundColor = UIColor.blue.lighter(by: CGFloat(shadeIntensity))
            } else {
                cellView.backgroundColor = UIColor.blue.darker(by: CGFloat(shadeIntensity))
            }
        } else {
            // Neutral cell
            cellView.backgroundColor = UIColor.hexStringToUIColor(hex: "#802456")
        }
        // Add the cell to the row
        rowView.addArrangedSubview(cellView)
    }
    // Add the row to the view
    battersBoxView.addArrangedSubview(rowView)
}

// Display the batters box view
PlaygroundPage.current.liveView = battersBoxView
battersBoxView.backgroundColor = UIColor.groupTableViewBackground

// Print Statistics
print("Number of Boxes: \(numberOfBoxes)")
print("maxHits: \(maxScore)")
print("maxStrikes: \(minScore)")



