;template stores information regarding the particular person and the range associated with 

(defglobal ?*firstName* = "")
(defglobal ?*lastName* = "")
(defglobal ?*bloodPressure* = 0)
(defglobal ?*cholesterol* = 0)
(defglobal ?*sugFasting* = 0)
(defglobal ?*sugNonFasting* = 0)
(defglobal ?*bmi* = 0)

(deftemplate Person 
    (slot firstName (default "N/A"))
    (slot lastName (default "N/A"))
    (slot bloodPressure (default 0.0))
    (slot bmi (default 0.0))
    (slot cholesterol (default 0.0))
    (slot sugFasting (default 0.0))
    (slot sugNonFasting (default 0.0))
)
(deftemplate Range 
    (slot bloodPressure (default "N/A"))
    (slot bmi (default "N/A"))
    (slot cholesterol (default "N/A"))
    (slot sugarLevel (default "N/A"))
)

(reset)
(assert (Person))
(assert (Range))

(deffunction measureBP () "Define the range of blood pressure based on the measure"
    (if(and (>= ?*bloodPressure* 90) (<= ?*bloodPressure* 120)) then
        (return "Normal")
      else
    	(return "Abnormal")
    )
)

(deffunction measureCholestrol () "Checks the if the cholesterol levels are normal or not"
    ( if(>= ?*cholesterol* 200) then
        (return "Abnormal")
      else
    	(return "Normal")
    )
)

(deffunction measureSugar () "Checks the if the sugar levels are normal or not"
    (if(and (and (>= ?*sugFasting* 70) (<= ?*sugFasting* 99)) (<= ?*sugNonFasting* 140)) then
    	(return "Normal")
      else
    	(return "Abnormal")
    )
)

(deffunction measureBMI () "Define the range of BMI based on the measure"
    (if(and (>= ?*bmi* 18.5) (<= ?*bmi* 24.9)) then
    	(return "Normal")
      else
    	(return "Abnormal")
    )
)

(defrule getDetails 
    ?c<-(Person{firstName == "N/A"})
    =>
    (printout t "Enter the patient's first name:" crlf)
    (bind ?*firstName* (read))
    (printout t "Enter the patient's last name:" crlf)
    (bind ?*lastName* (read))
    (printout t "Enter the patient's Blood Pressure:" crlf)
    (bind ?*bloodPressure* (read))
    (printout t "Enter the patient's BMI:" crlf)
    (bind ?*bmi* (read))    
    (printout t "Enter the patient's total Blood cholesterol level:" crlf)
    (bind ?*cholesterol* (read))
    (printout t "Enter the patient's Fasting Blood Sugar level:" crlf)
    (bind ?*sugFasting* (read))
    (printout t "Enter the patient's Non Fasting Blood Sugar Level (measured at least 2 hours after a meal):" crlf)
    (bind ?*sugNonFasting* (read))
    (retract ?c)
    (assert (Person (firstName ?*firstName*)(lastName ?*lastName*)(bloodPressure ?*bloodPressure*)(bmi ?*bmi*)(cholesterol ?*cholesterol*)(sugFasting ?*sugFasting*)(sugNonFasting ?*sugNonFasting*)))
)

(defrule checkBP 

    (Person{firstName != "N/A"}) 
    =>
		(assert (Range (bloodPressure (measureBP))))
)

(defrule norBP 
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "N/A"}) 
    =>
        (retract ?c)
    	(assert (Range (bloodPressure (measureBP))(cholesterol(measureCholestrol))))
)

(defrule norBPCH 
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Normal" && sugarLevel == "N/A"}) 
    =>
        (retract ?c)
    	(assert (Range (bloodPressure (measureBP))(cholesterol(measureCholestrol))(sugarLevel(measureSugar))))
)

(defrule norBPCHS 
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Normal" && sugarLevel == "Normal" && bmi == "N/A"}) 
    =>
        (retract ?c)
    	(assert (Range (bloodPressure (measureBP))(cholesterol(measureCholestrol))(sugarLevel(measureSugar))(bmi(measureBMI))))
)

(defrule norBPCHaS 
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Normal" && sugarLevel == "Abnormal" && bmi == "N/A"}) 
    =>
        (retract ?c)
    	(assert (Range (bloodPressure (measureBP))(cholesterol(measureCholestrol))(sugarLevel(measureSugar))(bmi(measureBMI))))
)

(defrule norAllbS 
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Normal" && sugarLevel == "Abnormal" && bmi == "Normal"}) 
    =>
   		(printout t "Low risk. Sugar level needs to improve." crlf)
)

(defrule norAll 
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Normal" && sugarLevel == "Normal" && bmi == "Normal"}) 
    =>
   		(printout t "Extremely low risk. All measures are perfect." crlf)
)

(defrule nBPCHaSaBMI
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Normal" && sugarLevel == "Abnormal" && bmi == "Abnormal"}) 
    =>
   		(printout t "Considerate risk. Sugar level and BMI need to improve." crlf)
)

(defrule norAllbBMI
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Normal" && sugarLevel == "Normal" && bmi == "Abnormal"}) 
    =>
   		(printout t "Considerately low risk. BMI needs to improve." crlf)
)

(defrule norBPaCH 
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Abnormal" && sugarLevel == "N/A"}) 
    =>
        (retract ?c)
    	(assert (Range (bloodPressure (measureBP))(cholesterol(measureCholestrol))(sugarLevel(measureSugar))))
)

(defrule norBPaCHnS 
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Abnormal" && sugarLevel == "Normal" && bmi == "N/A"}) 
    =>
        (retract ?c)
    	(assert (Range (bloodPressure (measureBP))(cholesterol(measureCholestrol))(sugarLevel(measureSugar))(bmi(measureBMI))))
)

(defrule norAllbCH 
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Abnormal" && sugarLevel == "Normal" && bmi == "Normal"}) 
    =>
   		(printout t "Low risk. cholesterol level needs to improve." crlf)
)

(defrule nBPnSaCHaBMI
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Abnormal" && sugarLevel == "Normal" && bmi == "Abnormal"}) 
    =>
   		(printout t "Considerate risk. cholesterol level and BMI need to improve." crlf)
)

(defrule norBPaCHaS 
    ?c<-(Range{bloodPressure == "Normal" && cholesterol == "Abnormal" && sugarLevel == "Abnormal" && bmi == "N/A"}) 
    =>
   		(printout t "Moderate risk. cholesterol and Sugar levels need to improve." crlf)
)

(defrule abnBP 
    ?c<-(Range{bloodPressure == "Abnormal" && sugarLevel == "N/A"}) 
    =>
        (retract ?c)
    	(assert (Range (bloodPressure (measureBP))(sugarLevel(measureSugar))))
)

(defrule abnBPaS 
    ?c<-(Range{bloodPressure == "Abnormal" && sugarLevel == "Abnormal" && cholesterol == "N/A"}) 
    =>
       	(printout t "Extremely high risk. Blood Pressure and Sugar levels need to improve." crlf)
)

(defrule abnBPnS 
    ?c<-(Range{bloodPressure == "Abnormal" && sugarLevel == "Normal" && cholesterol == "N/A"}) 
    =>	
    	(retract ?c)
    	(assert (Range (bloodPressure (measureBP))(sugarLevel(measureSugar))(cholesterol(measureCholestrol))))
)

(defrule abnBPnSaCH 
    ?c<-(Range{bloodPressure == "Abnormal" && cholesterol == "Abnormal" && sugarLevel == "Normal" && bmi == "N/A"}) 
    =>
   		(printout t "High risk. cholesterol and Blood Pressure levels need to improve." crlf)
)

(defrule abnBPnSnCH 
    ?c<-(Range{bloodPressure == "Abnormal" && cholesterol == "Normal" && sugarLevel == "Normal" && bmi == "N/A"}) 
    =>
    	(retract ?c)
    	(assert (Range (bloodPressure (measureBP))(sugarLevel(measureSugar))(cholesterol(measureCholestrol))(bmi(measureBMI))))
)

(defrule abnBPnSnCHnBMI
    ?c<-(Range{bloodPressure == "Abnormal" && cholesterol == "Normal" && sugarLevel == "Normal" && bmi == "Normal"}) 
    =>
   		(printout t "Considerate risk. Blood Pressure level needs to improve." crlf)
)

(defrule abnBPnSnCHaBMI
    ?c<-(Range{bloodPressure == "Abnormal" && cholesterol == "Normal" && sugarLevel == "Normal" && bmi == "Abnormal"}) 
    =>
   		(printout t "Moderate risk. Blood Pressure level and BMI needs to improve." crlf)
)

(run)