import Foundation

public class CSVLoader {
    public static func loadData(csv: String) -> [[Int]] {
        let fileURL = Bundle.main.url(forResource: csv, withExtension: "csv")
        var content: String!
        do {
            content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
        } catch {
            print("File error")
        }
        
        let items = content.components(separatedBy: "\n")
        var valX = [Double]()
        var valY = [Double]()
        for i in 1..<items.count {
            let lineData = (items[i].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)).components(separatedBy: ",")
            if(lineData.count < 2){
                continue
            }
            valX.append(Double(lineData[0])!)
            valY.append(Double(lineData[1])!)
        }
        
        let maxX = valX.max()
        let minX = valX.min()
        let maxY = valY.max()
        let minY = valY.min()
        
        var convertedPoints = [[Int]]()
        
        for i in 0..<valX.count {
            valX[i] = ((valX[i] + Double(abs(minX!))) / (Double(abs(minX!)) + maxX!)) * 99
            valY[i] = ((valY[i] + Double(abs(minY!))) / (Double(abs(minY!)) + maxY!)) * 99
            convertedPoints.append([Int(valX[i]), Int(valY[i])])
        }
        
        return convertedPoints
    }
}
