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
 * @data detailed: Int -  integer between 1 and 100 and divisible by 100 corresponding
 *                        to how detailed the strike zone view will be
 *
 * @output battersBoxView: UIView - A UIView showing a heat map corresponding
 *                        to the players strike zone. Lighter reds for more 
 *                        successful areas, darker blues for less successful areas
 *
 */

import UIKit
import PlaygroundSupport


// Create hits and strikes random demo data
/*
var hits = [[Int]]()
var strikes = [[Int]]()
for hit in 0..<100 {
    hits.append([Int(arc4random_uniform(99)), Int(arc4random_uniform(99))])
    strikes.append([Int(arc4random_uniform(99)), Int(arc4random_uniform(99))])
}
*/

// Import hit and strike data for Maikel Franco (3rd Baseman for the Philadelphia Phillies)
var hits = CSVLoader.loadData(csv: "FrancoHits")
var strikes = CSVLoader.loadData(csv: "FrancoStrikes")

/*
 * Define how detailed the resulting view will be
 * In the form of a "box size" between 1 and 100
 * and a divisor of 100
 */
let detailed = 5
let numberOfBoxes = 100 / detailed
let hitColor = UIColor.red
let strikeColor = UIColor.blue
let neutralColor = UIColor.blend(color1: hitColor, intensity1: 0.5, color2: strikeColor, intensity2: 0.5)

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
var battersBoxViews = [[UIView]]()
var battersBoxView = UIStackView(frame: CGRect(x: 25, y: 50, width: 100, height: 100))
battersBoxView.distribution = .fillEqually
battersBoxView.axis = .vertical
battersBoxView.backgroundColor = UIColor.groupTableViewBackground

// Iterate over the data and create the batters box view
for i in 0..<numberOfBoxes {
    // Create the view for the row
    var rowView = UIStackView(frame: CGRect(x: 0, y: (i * numberOfBoxes), width: 100, height: (100 / numberOfBoxes)))
    rowView.distribution = .fillEqually
    rowView.axis = .horizontal
    
    var battersBoxViewsRow = [UIView]()
    
    // Iterate over each cell in the row
    for ii in 0..<numberOfBoxes {
        
        // Create the cell
        let cellView = UIView(frame: CGRect(x: (CGFloat(ii) * CGFloat(100.0/CGFloat(numberOfBoxes))), y: (CGFloat(i) * CGFloat(100.0 / CGFloat(numberOfBoxes))), width: CGFloat(100.0 / CGFloat(numberOfBoxes)), height: CGFloat(100.0 / CGFloat(numberOfBoxes))))
        cellView.clipsToBounds = true
        
        // Color the cell based on the cell's score
        if(battersBoxData[i][ii] > 0){
            // Calculate shade of red
            let shadeIntensity = CGFloat(battersBoxData[i][ii]) / CGFloat(maxScore)
            
            let boxColor = UIColor.blend(color1: hitColor, intensity1: shadeIntensity, color2: neutralColor, intensity2: (1.0 - shadeIntensity))
            cellView.backgroundColor = boxColor

        } else if(battersBoxData[i][ii] < 0){
            // Calculate shade of blue
            let shadeIntensity = CGFloat(abs(battersBoxData[i][ii])) / CGFloat(abs(minScore))
            
            let boxColor = UIColor.blend(color1: strikeColor, intensity1: shadeIntensity, color2: neutralColor, intensity2: (1.0 - shadeIntensity))
            cellView.backgroundColor = boxColor
        } else {
            // Neutral cell
            cellView.backgroundColor = neutralColor
        }
        
        // Add the cell to the row
        cellView.tag = ii
        rowView.addArrangedSubview(cellView)
        battersBoxViewsRow.append(cellView)
    }
    // Add the row to the view
    rowView.tag = i
    battersBoxView.addArrangedSubview(rowView)
    battersBoxViews.append(battersBoxViewsRow)
}

// Display the batters box view
PlaygroundPage.current.liveView = battersBoxView

// Raw colored batter's box view
battersBoxView


// Iterate over each box and add gradients between diagional neighboring boxes
for i in 0..<battersBoxViews.count {
    for ii in 0..<battersBoxViews[i].count {
        let battersBoxViewRef = battersBoxViews[i][ii]
        
        // Iterate over the diagional neighboring boxes
        var referenceColors: [[Int]] = [[-1, -1], [1, -1], [1, 1], [-1, 1]]
        for j in 0..<referenceColors.count {
            // Correct edge cases
            if(referenceColors[j][0] + ii < 0){
                referenceColors[j][0] = 0
            } else if (referenceColors[j][0] + ii >= battersBoxViews[i].count){
                referenceColors[j][0] = 0
            }
            if(referenceColors[j][1] + i < 0){
                referenceColors[j][1] = 0
            } else if(referenceColors[j][1] + i >= battersBoxViews.count){
                referenceColors[j][1] = 0
            }
            
            // Get adjacent cells
            let adjX1 = referenceColors[j][0]
            let adjY1 = 0
            let adjX2 = 0
            let adjY2 = referenceColors[j][1]
            
            // Create the compound target color
            let colorA = UIColor.blend(color1: battersBoxViewRef.backgroundColor!, color2: battersBoxViews[referenceColors[j][1] + i][referenceColors[j][0] + ii].backgroundColor!)
            let colorB = UIColor.blend(color1: battersBoxViews[adjY1 + i][adjX1 + ii].backgroundColor!, color2: battersBoxViews[adjY2 + i][adjX2 + ii].backgroundColor!)
            let mixedColor = UIColor.blend(color1: colorA, color2: colorB)
            
            // Calculate the size of the shaded box
            let sideLength = CGFloat((Double(((battersBoxViewRef.frame.width / 2.0) * (battersBoxViewRef.frame.width / 2.0)) / 2.0).squareRoot()) * 2.0)
            let additionalDistance = (sideLength - (battersBoxViewRef.frame.width / 2.0)) / 2.0
            
            // Create gradient view
            var gradientView: UIView!
            if(j == 0){
                gradientView = UIView(frame: CGRect(x: 0.0 - additionalDistance, y: 0.0 - additionalDistance, width: sideLength, height: sideLength))
            } else if(j == 1){
                gradientView = UIView(frame: CGRect(x: battersBoxViewRef.frame.width / 2.0 - additionalDistance, y: 0.0 - additionalDistance, width: sideLength, height: sideLength))
            } else if(j == 2){
                gradientView = UIView(frame: CGRect(x: battersBoxViewRef.frame.width / 2.0 - additionalDistance, y: battersBoxViewRef.frame.width / 2.0 - additionalDistance, width: sideLength, height: sideLength))
            } else {
                gradientView = UIView(frame: CGRect(x: 0.0 - additionalDistance, y: battersBoxViewRef.frame.width / 2.0 - additionalDistance, width: sideLength, height: sideLength))
            }
            gradientView.backgroundColor = UIColor.clear
            
            // Create the gradient layer using background color and new mixed color
            var gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(x: 0, y: 0, width: gradientView.frame.height, height: gradientView.frame.width)
            gradientLayer.colors = [mixedColor.cgColor, battersBoxViewRef.backgroundColor!.cgColor]
            gradientLayer.locations = [0.2, 1]
            
            // Crop the gradient layer
            let dimenstion = gradientView.frame.height
            var aPath = UIBezierPath()
            aPath.move(to: CGPoint(x: (dimenstion / 2.0), y: 0.0))
            aPath.addLine(to: CGPoint(x: dimenstion, y: (dimenstion / 2.0)))
            aPath.addLine(to: CGPoint(x: (dimenstion / 2.0), y: dimenstion))
            aPath.addLine(to: CGPoint(x: 0.0, y: (dimenstion / 2.0)))
            aPath.addLine(to: CGPoint(x: (dimenstion / 2.0), y: 0.0))
            aPath.close()
            var shapeLayer = CAShapeLayer()
            shapeLayer.path = aPath.cgPath
            gradientLayer.mask = shapeLayer
            
            // Add the layer and rotate
            gradientView.layer.addSublayer(gradientLayer)
            gradientView.transform = CGAffineTransform(rotationAngle: (CGFloat(-1.0) * CGFloat(M_PI_2 / 2.0)) + CGFloat(j) * CGFloat(M_PI_2))
            battersBoxViewRef.addSubview(gradientView)
        }
    }
}

// Colored batter's box with corner gradients
battersBoxView


// Iterate over each box and add gradients between neighboring boxes
for i in 0..<battersBoxViews.count {
    for ii in 0..<battersBoxViews[i].count {
        let battersBoxViewRef = battersBoxViews[i][ii]
        
        // Iterate over the neighboring boxes
        var referenceColors = [[0, -1], [1, 0], [0, 1], [-1, 0]]
        for j in 0..<referenceColors.count{
            // Correct edge cases
            if(referenceColors[j][0] + ii < 0){
                referenceColors[j][0] = 0
            } else if (referenceColors[j][0] + ii >= battersBoxViews[i].count){
                referenceColors[j][0] = 0
            }
            if(referenceColors[j][1] + i < 0){
                referenceColors[j][1] = 0
            } else if(referenceColors[j][1] + i >= battersBoxViews.count){
                referenceColors[j][1] = 0
            }
            
            // Bland the colors
            let mixedColor = UIColor.blend(color1: battersBoxViewRef.backgroundColor!, color2: battersBoxViews[referenceColors[j][1] + i][referenceColors[j][0] + ii].backgroundColor!)
            
            // Create the gradient view
            var gradientView: UIView!
            if(j == 0){
                gradientView = UIView(frame: CGRect(x: 0.0, y: 0.0 - (battersBoxViewRef.frame.width / 2.0), width: battersBoxViewRef.frame.width, height: battersBoxViewRef.frame.height))
            } else if(j == 1){
                gradientView = UIView(frame: CGRect(x: 0.0 + (battersBoxViewRef.frame.width / 2.0), y: 0.0, width: battersBoxViewRef.frame.width, height: battersBoxViewRef.frame.height))
            } else if(j == 2){
                gradientView = UIView(frame: CGRect(x: 0.0, y: 0.0 + (battersBoxViewRef.frame.width / 2.0), width: battersBoxViewRef.frame.width, height: battersBoxViewRef.frame.height))
            } else {
                gradientView = UIView(frame: CGRect(x: 0.0 - (battersBoxViewRef.frame.width / 2.0), y: 0.0, width: battersBoxViewRef.frame.width, height: battersBoxViewRef.frame.height))
            }
            gradientView.backgroundColor = UIColor.clear
            
            // Create the gradient layer using the background color and the new blended color
            var gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(x: 0, y: 0, width: gradientView.frame.height, height: gradientView.frame.width)
            gradientLayer.colors = [mixedColor.cgColor, battersBoxViewRef.backgroundColor!.cgColor]
            gradientLayer.locations = [0.5, 1]
            
            // Crop the gradient layer
            let dimenstion = gradientView.frame.height
            var aPath = UIBezierPath()
            aPath.move(to: CGPoint(x: 0.0, y: 0.0))
            aPath.addLine(to: CGPoint(x: dimenstion, y: 0.0))
            aPath.addLine(to: CGPoint(x: dimenstion / 2.0, y: dimenstion))
            aPath.addLine(to: CGPoint(x: 0.0, y: 0.0))
            aPath.close()
            var shapeLayer = CAShapeLayer()
            shapeLayer.path = aPath.cgPath
            gradientLayer.mask = shapeLayer
            
            // Add the layer and rotate
            gradientView.layer.addSublayer(gradientLayer)
            gradientView.transform = CGAffineTransform(rotationAngle: (CGFloat(M_PI_2 * Double(j))))
            battersBoxViewRef.addSubview(gradientView)
        }
        
        
    }
}

// Colored batter's box view after compound gradients
battersBoxView



