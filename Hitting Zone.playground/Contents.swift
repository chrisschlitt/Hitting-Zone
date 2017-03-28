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



// Create hits and strikes demo data
var hits = [[Int]]()
var strikes = [[Int]]()
for hit in 0..<100 {
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
        
        print("Setting frame to: \(ii * numberOfBoxes), \(i * numberOfBoxes)")
        print("Which makes it  : \(cellView.frame.minX), \(cellView.frame.minY)")
        print("Bounded at      : \(cellView.bounds.minX), \(cellView.bounds.minY)")
        
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
        rowView.addArrangedSubview(cellView)
        
        
        print("1Which makes it : \(cellView.frame.minX), \(cellView.frame.minY)")
        print("1Bounded at     : \(cellView.bounds.minX), \(cellView.bounds.minY)")
        
        cellView.tag = ii
        battersBoxViewsRow.append(cellView)
    }
    // Add the row to the view
    rowView.tag = i
    battersBoxView.addArrangedSubview(rowView)
    battersBoxViews.append(battersBoxViewsRow)
}

// Display the batters box view
PlaygroundPage.current.liveView = battersBoxView
battersBoxView.backgroundColor = UIColor.groupTableViewBackground



battersBoxView


for i in 0..<battersBoxViews.count {
    for ii in 0..<battersBoxViews[i].count {
        let battersBoxViewRef = battersBoxViews[i][ii]
        print("========")
        
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
            /*
            print("--------")
            print("Ref: \(j)")
            print("X = \(ii)")
            print("Y = \(i)")
            print("Frame: \(battersBoxViewRef.frame.minX), \(battersBoxViewRef.frame.minY) -- \(battersBoxViewRef.frame.width), \(battersBoxViewRef.frame.height)")
            // print("Bounds: \(battersBoxViewRef.bounds.minX), \(battersBoxViewRef.bounds.minY)")
            print("RefX = \(referenceColors[j][0])")
            print("RefY = \(referenceColors[j][1])")
            print("AdjX1 = \(adjX1)")
            print("AdjY1 = \(adjY1)")
            print("AdjX2 = \(adjX2)")
            print("AdjY2 = \(adjY2)")
            */
            
            // Get target color
            let colorA = UIColor.blend(color1: battersBoxViewRef.backgroundColor!, color2: battersBoxViews[referenceColors[j][1] + i][referenceColors[j][0] + ii].backgroundColor!)
            let colorB = UIColor.blend(color1: battersBoxViews[adjY1 + i][adjX1 + ii].backgroundColor!, color2: battersBoxViews[adjY2 + i][adjX2 + ii].backgroundColor!)
            let mixedColor = UIColor.blend(color1: colorA, color2: colorB)
            
            
            
            
            
            // let additionalDistance = (battersBoxViewRef.frame.width / 2.0) * (5.0 / 11.0)
            // var additionalDistance = CGFloat(((Double(battersBoxViewRef.frame.width).squareRoot()) / 2.0) * ((Double(battersBoxViewRef.frame.width).squareRoot()) / 2.0) - Double(battersBoxViewRef.frame.width / 2.0))
            
            
            // var additionalDistance = (battersBoxViewRef.frame.width / 2.0) * (4/11)
            // let additionalDistance = CGFloat((Double((battersBoxViewRef.frame.width * battersBoxViewRef.frame.width) * 2.0).squareRoot() - Double(battersBoxViewRef.frame.width)) / 2.0)
            
            
            
            // let sideLength = CGFloat((Double(((battersBoxViewRef.frame.width / 2.0) * (battersBoxViewRef.frame.width / 2.0)) / 2.0).squareRoot()) * 2.0 * (2.0/(2.0).squareRoot()))
            let sideLength = CGFloat((Double(((battersBoxViewRef.frame.width / 2.0) * (battersBoxViewRef.frame.width / 2.0)) / 2.0).squareRoot()) * 2.0)
            let additionalDistance = (sideLength - (battersBoxViewRef.frame.width / 2.0)) / 2.0
            
            print("Original: \(battersBoxViewRef.frame.width)")
            print("Length: \(sideLength)")
            print("Additional: \(additionalDistance)")
            
            // Create gradient view using background color and new mixed color
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
            print("New: \(gradientView.frame.minX), \(gradientView.frame.minY) | \(gradientView.frame.height), \(gradientView.frame.width)")
            /*
             if(j == 0){
             gradientView = UIView(frame: CGRect(x: CGFloat(ii) * CGFloat(100.0/CGFloat(numberOfBoxes)), y: (CGFloat(i) * CGFloat(100.0 / CGFloat(numberOfBoxes))), width: battersBoxViewRef.frame.width / 2.0, height: battersBoxViewRef.frame.height / 2.0))
             } else if(j == 1){
             gradientView = UIView(frame: CGRect(x: CGFloat(ii) * CGFloat(100.0/CGFloat(numberOfBoxes)) + (battersBoxViewRef.frame.width / 2.0), y: (CGFloat(i) * CGFloat(100.0 / CGFloat(numberOfBoxes))), width: battersBoxViewRef.frame.width / 2.0, height: battersBoxViewRef.frame.height / 2.0))
             } else if(j == 2){
             gradientView = UIView(frame: CGRect(x: CGFloat(ii) * CGFloat(100.0/CGFloat(numberOfBoxes)), y: (CGFloat(i) * CGFloat(100.0 / CGFloat(numberOfBoxes))) + (battersBoxViewRef.frame.height / 2.0), width: battersBoxViewRef.frame.width / 2.0, height: battersBoxViewRef.frame.height / 2.0))
             } else {
             gradientView = UIView(frame: CGRect(x: CGFloat(ii) * CGFloat(100.0/CGFloat(numberOfBoxes)) + (battersBoxViewRef.frame.width / 2.0), y: (CGFloat(i) * CGFloat(100.0 / CGFloat(numberOfBoxes))) + (battersBoxViewRef.frame.height / 2.0), width: battersBoxViewRef.frame.width / 2.0, height: battersBoxViewRef.frame.height / 2.0))
             }
            */
            
            
            // gradientView.backgroundColor = UIColor.yellow
            
            
            
            
            var gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(x: 0, y: 0, width: gradientView.frame.height, height: gradientView.frame.width)
            gradientLayer.colors = [mixedColor.cgColor, battersBoxViewRef.backgroundColor!.cgColor]
            gradientLayer.locations = [0.2, 1]
            // gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
            
            // print("===============HERE: \((gradientView.frame.height / 4.0))")
            
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
            
            // gradientLayer.anchorPoint = CGPoint(x: battersBoxViewRef.frame.width, y: battersBoxViewRef.frame.height)
            // print("Adding a cell at: \(gradientView.frame.minX), \(gradientView.frame.minY)")
            
            
            // gradientView.layer.insertSublayer(gradientLayer, at: 0)
            // battersBoxViewRef.insertSubview(gradientView, at: 0)
            gradientView.layer.addSublayer(gradientLayer)
            
            if(i == 0 && ii == 0 && j == 2){
                gradientView.layer.borderColor = UIColor.orange.cgColor
                gradientView
            }
            
            
            gradientView.transform = CGAffineTransform(rotationAngle: (CGFloat(-1.0) * CGFloat(M_PI_2 / 2.0)) + CGFloat(j) * CGFloat(M_PI_2))
            
            if(j > 0){
                // gradientView.transform = CGAffineTransform(rotationAngle: CGFloat(j) * CGFloat(M_PI))
            }
            
            
            
            // gradientView.transform = CGAffineTransform(rotationAngle: (CGFloat(M_PI_2 / 2) * -1) + CGFloat(M_PI_2 * Double(j)));
            battersBoxViewRef.addSubview(gradientView)
            
            
            if(i == 0 && ii == 0 && j == 3){
                gradientView.layer.borderColor = UIColor.orange.cgColor
                battersBoxViewRef
                print("w: \(battersBoxViewRef.frame.width)")
                print("w1: \(gradientView.frame.width)")
                // break
            }
            
            if(j == 0 && i == 0 && ii == 0){
                print("Color1: \(mixedColor)")
                print("Color2: \(battersBoxViewRef.backgroundColor)")
            }
        }
        // break
        
        
        // Now add the barrier gradient views
        
        
        referenceColors = [[0, -1], [1, 0], [0, 1], [-1, 0]]
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
            
            
            
            let mixedColor = UIColor.blend(color1: battersBoxViewRef.backgroundColor!, color2: battersBoxViews[referenceColors[j][1] + i][referenceColors[j][0] + ii].backgroundColor!)
            
            
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
            
            
            
            
            
            
            
            
            
            
            
            
            var gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(x: 0, y: 0, width: gradientView.frame.height, height: gradientView.frame.width)
            gradientLayer.colors = [mixedColor.cgColor, battersBoxViewRef.backgroundColor!.cgColor]
            gradientLayer.locations = [0.5, 1]
            // gradientLayer.colors = [UIColor.red.cgColor, UIColor.red.cgColor]
            
            
            
            
            
            
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
            
            
            
            
            // gradientView.layer.insertSublayer(gradientLayer, at: 0)
            // battersBoxViewRef.insertSubview(gradientView, at: 0)
            gradientView.layer.addSublayer(gradientLayer)
            
            
            
            gradientView.transform = CGAffineTransform(rotationAngle: (CGFloat(M_PI_2 * Double(j))))
            
            battersBoxViewRef.addSubview(gradientView)
            
            // break
        }
        
        
    }
}

battersBoxView

// Add Color Blending through Multiple Gradient Layers













/*
var referenceColors = [[-1, -1], [0, -1], [1, -1], [-1, 0], [0, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
for referenceColor in referenceColors {
    var view = UIView(frame: battersBoxView.frame)
    
}

var gradient = CAGradientLayer()
*/


// Print Statistics
print("Number of Boxes: \(numberOfBoxes)")
print("maxHits: \(maxScore)")
print("maxStrikes: \(minScore)")



