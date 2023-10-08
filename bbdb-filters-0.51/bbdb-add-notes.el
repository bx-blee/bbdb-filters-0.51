;; This file is part of the BBDB Filters Package. BBDB Filters Package is a
;;; collection of input and output filters for BBDB.
;;;

;(setq debug-on-error t)
;(setq debug-on-error nil)


(defun bbdb-a-add-names-cat (records) 
  ""
  (let (
	(thisRec (car records))
	(origVal "")
	(seperator-names-cat " ")
	)

    (if bbdb-action-isFirstRecord
	(setq namesTag (bbdb-read-string "names-cat: ")))
      
    (setq origVal  (bbdb-record-getprop thisRec 'names-cat))

    ;; NOTYET, below does not happen a expected, perhaps origVal is nil?
    (if (string-equal origVal "")
	(setq seperator-names-cat ""))

    (bbdb-record-putprop thisRec 'names-cat 
			 (concat origVal seperator-names-cat namesTag))
    )

  (if (bbdb-action-isLastRecord records)
      (bbdb-a-refresh records))
  )



(setq bbdb-action-alist 
  (append 
   bbdb-action-alist
   '(("add-names-cat" 
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-add-names-cat)
      ))))


(defun bbdb-a-add-notes (records) 
  ""
  (let (
	(thisRec (car records))
	(origVal "")
	(seperator-names-cat " ")
	)

      (if bbdb-action-isFirstRecord
	  (progn
	    (setq tmpNameStr "")
	    (while (string= tmpNameStr "")
	      (setq tmpNameStr
		    (downcase
		     (completing-read "Insert Field: "
				      (append '(("notes"))
					      (bbdb-propnames))
				      nil
				      nil ; used to be t
				      nil))))
	    (setq namesTag (bbdb-read-string (concat tmpNameStr ": ")))))

      (setq tmpName (intern tmpNameStr))
      
      (setq origVal  (bbdb-record-getprop thisRec (symbol-name tmpName)))

      (if (string-equal origVal "")
	  (setq seperator-names-cat ""))

      ;(bbdb-record-putprop thisRec (symbol-name tmpName)
      (bbdb-record-putprop thisRec tmpName
			   (concat origVal seperator-names-cat namesTag))

      (if (bbdb-action-isLastRecord records)
	  (bbdb-a-refresh records))
      )
  )



(setq bbdb-action-alist 
  (append 
   bbdb-action-alist
   '(("add-notes" 
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-add-notes)
      ))))


(defun bbdb-a-refresh (records) 
  ""
  (if (bbdb-action-isLastRecord records)
      (bbdb-redisplay-records)
    )
  )


(setq bbdb-action-alist 
  (append 
   bbdb-action-alist
   '(("refresh" 
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-refresh)
      ))))

(provide 'bbdb-add-notes)


