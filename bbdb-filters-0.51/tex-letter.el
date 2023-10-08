;;;(setq lisp-indent-offset 2)
;;;
;;; Time-stamp: "010318224609"
;;;  (setq debug-on-error nil)
;;; (setq debug-on-error t)
;;; Variables
;;;

;;; tex-letter.el
;;; 
;;; This code will produce a LaTeX file for the letter.
;;; The originator's letter head
;;; are set in the originator-prefs.el.
;;; This function is intended to be used with bbdb.
;;; The recipient's information will automatically 
;;; inserted from the bbdb record.

(require 'bbdb-action-lib)

(defun a-tex-letter (records)
  ""

  (bbdb-a-get-file-name records)

   (let* (
	  ;;(first-letter (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	  ;; raw fields
	  (name (bbdb-record-name (car records)))
	  (lastname (bbdb-record-lastname (car records)))
	  (net (bbdb-record-net (car records)))
	  (company (bbdb-record-company (car records)))
	  (primary-net (car net))
	  nsl ns
	  )

     (save-excursion
       (set-buffer bbdb-a-output-buffer)
;;
;; Start the LaTeX format
;;
       (insert "\\documentstyle [11pt]{letter}\n\n")

       (insert "\\setlength{\\textwidth}{16.5cm}\n")
       (insert "\\setlength{\\oddsidemargin}{0.0cm}\n")
       (insert "\\setlength{\\evensidemargin}{0.0cm}\n\n")

       (insert (concat "\\name{" originator-full-name "}\n"))
       (insert (concat "\\signature{" originator-full-name "\\\\" originator-title "}\n\n")) 
       (insert "\\begin{document}\n\n")

       (insert "\\begin{letter}\n")
       (insert (concat "{" name "\\\\\n"))
       (if (not (eq company nil))
	   (insert (concat company "\\\\\n")))
       (bbdb-tex-memo-address records)
       (insert "}\n\n")
       (setq time-stamp-format "%b %02d, %y")
       (insert "\\date{" )
       (insert (concat (time-stamp-string) "}\n\n"))
       (insert "\\vspace*{-1.8in}\n\n")
       (insert (concat "\\begin{flushleft}\n{\\Huge {\\bf " originator-header-name "}}\n\\end{flushleft}\n\n"))
       (insert "\\vspace*{-.2in}\n\n")
       (insert "\\makebox[16.5cm]{\\hrulefill}\n\n\\vspace*{-.2in}\n\n")
       (insert "\\begin{flushright}\n")
       (insert (concat "{\\small " originator-street-address1 "}\\\\\n"))
       (if (not (eq originator-street-address2 nil))
	   (insert (concat "{\\small " originator-street-address2 "}\\\\\n")))
       (insert (concat "{\\small " originator-city-address ", " originator-state-address " " originator-zipcode-address "}\\\\\n"))
       (insert (concat "{\\small " "Phone: " originator-phone-number "}\\\\\n"))
       (insert (concat "{\\small " "Fax: " originator-fax-number "}\\\\\n"))
       (insert (concat "{\\small " "E-mail: " originator-email-address "}\n"))
       (insert "\\end{flushright}\n\n")

       (insert (concat"\\opening{Dear Mr. " lastname ":}\n\n"))

       (insert "@START HERE@\n\n")

       (insert "\\closing{With best regards,}\n\n")
       
       (insert "\\end{letter}\n\n")

       (insert "\\end{document}\n")

 )))

;;(setq bbdb-action-alist nil)

(setq bbdb-action-alist
  (append
   bbdb-action-alist
   '(("tex-letter"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-tex-letter)
      (add-hook 'bbdb-action-hook 'bbdb-a-tex-letter-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      ))))

(provide 'tex-letter)



