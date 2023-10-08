;;;(setq lisp-indent-offset 2)
;;;
;;; Time-stamp: "010318224609"
;;;  (setq debug-on-error nil)
;;; (setq debug-on-error t)
;;; Variables
;;;

;;; tex-memo.el
;;; 
;;; This code will produce a LaTeX file for the memo.
;;; The originator's memo head (similar to the letter head)
;;; are set in the originator-prefs.el.
;;; This function is intended to be used with bbdb.
;;; The recipient's information will automatically 
;;; inserted from the bbdb record.

(require 'bbdb-action-lib)

(defun a-tex-memo (records)
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

       (insert "\\documentstyle [contract,11pt]{article}\n\n")
       (insert "\\begin{document}\n\n")
       (insert "\\vspace*{-1.0in}\n\n")
       (insert (concat "\\begin{flushleft}\n{\\Huge {\\bf " originator-header-name "}}\n\\end{flushleft}\n\n"))
       (insert "\\vspace*{-.35in}\n\n")
       (insert "\\makebox[6.5in]{\\hrulefill}\n\n\\vspace*{-.35in}\n\n")
       (insert "\\begin{flushright}\n")
       (insert (concat "{\\small " originator-street-address1 "}\\\\\n"))
       (if (not (eq originator-street-address2 nil))
	   (insert (concat "{\\small " originator-street-address2 "}\\\\\n")))
       (insert (concat "{\\small " originator-city-address ", " originator-state-address " " originator-zipcode-address "}\\\\\n"))
       (insert (concat "{\\small " "Phone: " originator-phone-number "}\\\\\n"))
       (insert (concat "{\\small " "Fax: " originator-fax-number "}\\\\\n"))
       (insert (concat "{\\small " "E-mail: " originator-email-address "}\n"))
       (insert "\\end{flushright}\n\n")

       (insert "\\noindent\\begin{tabular}{ll}\n")

       (setq time-stamp-format "%b %02d, %y")
       (insert (concat "Date:      & " (time-stamp-string) "\\\\\n\\\\"))
       (insert (concat "To:        & " name " - " company "\\\\\n\\\\"))
       (insert (concat "CC:        & " "\\\\\n\\\\"))
       (insert (concat "From:      & " originator-full-name "\\\\\n\\\\"))
       (insert (concat "Subject:   & " "\\\\\n\\\\"))

       (insert "\\end{tabular}\n\\bigskip\n\n")

       (insert "@START HERE@\n\n")

       (insert "Sincerely,\n\n")
       (insert (concat originator-full-name "\n\n"))

       (insert "\\end{document}\n")

 )))

;;(setq bbdb-action-alist nil)

(setq bbdb-action-alist
  (append
   bbdb-action-alist
   '(("tex-memo"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-tex-memo)
      (add-hook 'bbdb-action-hook 'bbdb-a-tex-memo-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      ))))

(provide 'tex-memo)



