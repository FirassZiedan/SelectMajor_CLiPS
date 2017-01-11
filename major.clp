(deftemplate node
   (slot name)
   (slot type)
   (slot question)
   (slot yes-node)
   (slot no-node)
   (slot answer))

   (deffunction ask-yes-or-no (?question)  
   (printout t ?question " (yes or no) ")
   (bind ?answer (read))                      
   (while (and (neq ?answer yes) (neq ?answer no)) 
      (printout t ?question " (yes or no) ")
      (bind ?answer (read)))                  
   (return ?answer))
   
(defrule initialize
   (not (node (name root)))
   =>
   (load-facts "major.dat")
   (assert (current-node root)))
   
(defrule ask-decision-node-question
   ?node <- (current-node ?name)
   (node (name ?name)
         (type decision)
         (question ?question))
   (not (answer ?))
   =>
   (assert (answer (ask-yes-or-no ?question))))

(defrule proceed-to-yes-branch
   ?node <- (current-node ?name)
   (node (name ?name)
         (type decision)
         (yes-node ?yes-branch))
   ?answer <- (answer yes)
   =>
   (retract ?node ?answer)
   (assert (current-node ?yes-branch)))

(defrule proceed-to-no-branch
   ?node <- (current-node ?name)
   (node (name ?name)
         (type decision)
         (no-node ?no-branch))
   ?answer <- (answer no)
   =>
   (retract ?node ?answer)
   (assert (current-node ?no-branch)))


(defrule ask-if-answer-node-is-correct
   ?node <- (current-node ?name)
   (node (name ?name) (type answer) 
         (answer ?value))
   (not (answer ?))
   =>
   (printout t "#################  I guess the best major for you is :" ?value crlf))   
   
   
 (defrule ask-try-again
   (ask-try-again)
   (not (answer ?))
   =>
   (assert (answer (ask-yes-or-no "Try again?"))))
   
   
   (defrule one-more-time
   ?phase <- (ask-try-again)
   ?answer <- (answer yes)
   =>
   (retract ?phase ?answer)
   (assert (current-node root)))
   
   
   (defrule no-more
   ?phase <- (ask-try-again)
   ?answer <- (answer no)
   =>
   (retract ?phase ?answer)
   (save-facts "major.dat" local node))