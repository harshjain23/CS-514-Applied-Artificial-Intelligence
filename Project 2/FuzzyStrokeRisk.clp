(import nrc.fuzzy.*)
(import nrc.fuzzy.jess.*)
(load-package nrc.fuzzy.jess.FuzzyFunctions)

;(watch all)

(defglobal ?*firstName* = "")
(defglobal ?*lastName* = "")
(defglobal ?*bloodPressure* = (new FuzzyVariable "bloodPressure" 40 320 "points"))
(defglobal ?*sugar* = (new FuzzyVariable "sugarLevel" 40 150 "mg/dl"))
(defglobal ?*bmi* = (new FuzzyVariable "bmi" 14 32 "points"))
(defglobal ?*cholesterol* = (new FuzzyVariable "cholesterol" 0 300 "points"))

(defrule init
    =>
    (?*bloodPressure* addTerm "low" (new RightLinearFuzzySet 40 90))
    (?*bloodPressure* addTerm "normal" (new TrapezoidFuzzySet 90 90 140 140))
    (?*bloodPressure* addTerm "high" (new LeftLinearFuzzySet 140 320))
    
    (?*sugar* addTerm "low" (new RightLinearFuzzySet 40 70))
    (?*sugar* addTerm "normal" (new TrapezoidFuzzySet 70 73 96 99))
    (?*sugar* addTerm "high" (new LeftLinearFuzzySet 99 150)) 
    
    (?*bmi* addTerm "low" (new RightLinearFuzzySet 14 18.5))
    (?*bmi* addTerm "normal" (new TrapezoidFuzzySet 18.5 19.5 23.9 24.9))
    (?*bmi* addTerm "high" (new LeftLinearFuzzySet 24.9 32)) 
    
    (?*cholesterol* addTerm "low" (new RightLinearFuzzySet 0 70))
    (?*cholesterol* addTerm "normal" (new TrapezoidFuzzySet 70 85 185 200))
    (?*cholesterol* addTerm "high" (new LeftLinearFuzzySet 200 300))
    
    (assert (initialize))
)

(defrule getDetails
    (initialize)
    =>
    (printout t "Enter the patient's first name:" crlf)
    (bind ?fn (readline))
    (printout t "Enter the patient's last name:" crlf)
    (bind ?ln (readline))
    (printout t "Choose the patient's Blood Pressure range (high-normal-low):" crlf)
    (bind ?bp (readline))
    (printout t "Choose the patient's BMI range (high-normal):" crlf)
    (bind ?bm (readline))    
    (printout t "Choose the patient's total Blood cholesterol level range (high-normal):" crlf)
    (bind ?ch (readline))
    (printout t "Choose the patient's Blood Sugar level range (high-normal-low):" crlf)
    (bind ?suglevel (readline))
    
    (assert (bplevel (new FuzzyValue ?*bloodPressure* ?bp)))
    (assert (bmiValue (new FuzzyValue ?*bmi* ?bm)))
    (assert (chValue (new FuzzyValue ?*cholesterol* ?ch)))
    (assert (sug (new FuzzyValue ?*sugar* ?suglevel)))
)

(defrule norAll
    (bplevel ?bp&:(fuzzy-match ?bp "normal"))
    (chValue ?ch&:(fuzzy-match ?ch "normal"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "normal"))
    (bmiValue ?bm&:(fuzzy-match ?bm "normal"))
    =>
   	(printout t "Extremely low risk. All measures are perfect." crlf)
)

(defrule norAllbHS
    (bplevel ?bp&:(fuzzy-match ?bp "normal"))
    (chValue ?ch&:(fuzzy-match ?ch "normal"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "high"))
    (bmiValue ?bm&:(fuzzy-match ?bm "normal"))
    =>
   	(printout t "Low risk. Sugar level needs to decrease." crlf)
)

(defrule norAllbLS
    (bplevel ?bp&:(fuzzy-match ?bp "normal"))
    (chValue ?ch&:(fuzzy-match ?ch "normal"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "low"))
    (bmiValue ?bm&:(fuzzy-match ?bm "normal"))
    =>
   	(printout t "Low risk. Sugar level needs to increase." crlf)
)

(defrule norAllbHBP
    (bplevel ?bp&:(fuzzy-match ?bp "high"))
    (chValue ?ch&:(fuzzy-match ?ch "normal"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "normal"))
    (bmiValue ?bm&:(fuzzy-match ?bm "normal"))
    =>
   	(printout t "Considerate risk. Blood Pressure level needs to decrease." crlf)
)

(defrule norAllbLBP
    (bplevel ?bp&:(fuzzy-match ?bp "low"))
    (chValue ?ch&:(fuzzy-match ?ch "normal"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "normal"))
    (bmiValue ?bm&:(fuzzy-match ?bm "normal"))
    =>
   	(printout t "Considerate risk. Blood Pressure level needs to increase." crlf)
)

(defrule norAllbACH
    (bplevel ?bp&:(fuzzy-match ?bp "normal"))
    (chValue ?ch&:(fuzzy-match ?ch "high"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "normal"))
    (bmiValue ?bm&:(fuzzy-match ?bm "normal"))
    =>
   	(printout t "Low risk. cholesterol level needs to improve." crlf)
)

(defrule norAllbABMI
    (bplevel ?bp&:(fuzzy-match ?bp "normal"))
    (chValue ?ch&:(fuzzy-match ?ch "normal"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "normal"))
    (bmiValue ?bm&:(fuzzy-match ?bm "high"))
    =>
   	(printout t "Considerately low risk. BMI needs to improve." crlf)
)

(defrule hSughBP
    (bplevel ?bp&:(fuzzy-match ?bp "high"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "high"))
    =>
   	(printout t "Extremely high risk. Blood Pressure and Sugar levels need to decrease." crlf)
)

(defrule hSuglBP
    (bplevel ?bp&:(fuzzy-match ?bp "low"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "high"))
    =>
   	(printout t "Extremely high risk. Blood Pressure level needs to increase and Sugar level needs to decrease." crlf)
)

(defrule lSughBP
    (bplevel ?bp&:(fuzzy-match ?bp "high"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "low"))
    =>
   	(printout t "Extremely high risk. Blood Pressure level needs to decrease and Sugar level needs to increase." crlf)
)

(defrule lSuglBP
    (bplevel ?bp&:(fuzzy-match ?bp "low"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "low"))
    =>
   	(printout t "Extremely high risk. Blood Pressure and Sugar levels need to increase." crlf)
)

(defrule aCHlBP
    (bplevel ?bp&:(fuzzy-match ?bp "low"))
    (chValue ?ch&:(fuzzy-match ?ch "high"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "normal"))
       =>
   	(printout t "High risk. Blood Pressure needs to increase and cholesterol level needs to improve." crlf)
)

(defrule aCHhBP
    (bplevel ?bp&:(fuzzy-match ?bp "high"))
    (chValue ?ch&:(fuzzy-match ?ch "high"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "normal"))
    =>
   	(printout t "High risk. Blood Pressure needs to decrease and cholesterol level needs to improve." crlf)
)

(defrule hSaBMI
    (bplevel ?bp&:(fuzzy-match ?bp "normal"))
    (chValue ?ch&:(fuzzy-match ?ch "normal"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "high"))
    (bmiValue ?bm&:(fuzzy-match ?bm "high"))
    =>
   	(printout t "Considerate risk. Sugar needs to decrease and BMI needs to improve." crlf)
)

(defrule lSaBMI
    (bplevel ?bp&:(fuzzy-match ?bp "normal"))
    (chValue ?ch&:(fuzzy-match ?ch "normal"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "low"))
    (bmiValue ?bm&:(fuzzy-match ?bm "high"))
    =>
   	(printout t "Considerate risk. Sugar needs to increase and BMI needs to improve." crlf)
)

(defrule aCHaBMI
    (bplevel ?bp&:(fuzzy-match ?bp "normal"))
    (chValue ?ch&:(fuzzy-match ?ch "high"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "normal"))
    (bmiValue ?bm&:(fuzzy-match ?bm "high"))
    =>
   	(printout t "Considerate risk. Cholesterol level and BMI need to improve." crlf)
)

(defrule aCHhS
    (bplevel ?bp&:(fuzzy-match ?bp "normal"))
    (chValue ?ch&:(fuzzy-match ?ch "high"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "high"))
    =>
   	(printout t "Moderate risk. Cholesterol level needs to improve and Sugar needs to decrease." crlf)
)

(defrule aCHlS
    (bplevel ?bp&:(fuzzy-match ?bp "normal"))
    (chValue ?ch&:(fuzzy-match ?ch "high"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "low"))
    =>
   	(printout t "Moderate risk. Cholesterol level needs to improve and Sugar needs to increase." crlf)
)

(defrule hBPaBMI
    (bplevel ?bp&:(fuzzy-match ?bp "high"))
    (chValue ?ch&:(fuzzy-match ?ch "normal"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "normal"))
    (bmiValue ?bm&:(fuzzy-match ?bm "high"))
    =>
   	(printout t "Moderate risk. Blood Pressure level needs to decrease and BMI needs to improve." crlf)
)

(defrule lBPaBMI
    (bplevel ?bp&:(fuzzy-match ?bp "low"))
    (chValue ?ch&:(fuzzy-match ?ch "normal"))
    (sug ?suglevel&:(fuzzy-match ?suglevel "normal"))
    (bmiValue ?bm&:(fuzzy-match ?bm "high"))
    =>
   	(printout t "Moderate risk. Blood Pressure level needs to increase and BMI needs to improve." crlf)
)

(reset)
(run)
;(facts)

