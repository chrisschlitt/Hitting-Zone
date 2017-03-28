# Hitting-Zone
A Baseball Player Strike Zone Heat Map

Chris Schlitt
WWDC 2017 Scholarship Application

@data hits: [[Int]] -  array of coordinates in a 1-100 plane corresponding 
                       to locations in the strike zone where a baseball 
                       player has hit the ball

@data strikes: [[Int]] -  array of coordinates in a 1-100 plane corresponding 
                       to locations in the strike zone where a baseball 
                       player has swung and missed

@data detailed: Int -  integer between 1 and 100 and divisible by 100 corresponding
                       to how detailed the strike zone view will be

@output battersBoxView: UIView - A UIView showing a heat map corresponding
                       to the players strike zone. Lighter reds for more 
                       successful areas, darker blues for less successful areas
