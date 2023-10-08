;;;(setq lisp-indent-offset 2)
;;;
;;; Time-stamp: "010318224609"
;;;  (setq debug-on-error nil)
;;; (setq debug-on-error t)
;;; Variables
;;;

;;; tex-fax-cover.el
;;; 
;;; This code will produce a LaTeX file for the fax cover.
;;; The originator's fax head (similar to the letter head)
;;; are set in the originator-prefs.el.
;;; This function is intended to be used with bbdb.
;;; The recipient's information will automatically 
;;; inserted from the bbdb record.

(require 'bbdb-action-lib)

;; NOTYET, is this the right place?
(setq bbdb-letter-phone-default "Home")

(defun a-tex-fax-cover (records)
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
	  nsl ns fax-number
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
       (insert "{\\Large\n\\begin{center}\nFACSIMILE TRANSMITTAL COVER SHEET\n\\end{center}\n}\n\n")

       (setq time-stamp-format "%b %02d, %y")
       (insert (concat "Date: " (time-stamp-string) "\n\n"))

       (insert (concat "From: " originator-full-name "\n\n"))

       (insert (concat "To: " name " - " company "\\\\ \n"))

       (insert "Fax: ") 
       (setq bbdb-letter-phone-default "Fax")
       (setq fax-number (bbdb-tex-memo-phone records))
       (insert "\\\\")
       (insert "\n")

       (insert "Phone: ") 
       (setq bbdb-letter-phone-default "Office")
       (bbdb-tex-memo-phone records)

       (insert "\n\n")

       (insert "Total number of pages (including cover sheet): \n\n")

       (insert "{\\Large \\underline{MESSAGE}: }\n\n")

       (insert "\\end{document}\n")

;;(save-buffer)
(message "Tex file %s generated." bbdb-a-file-name)

(split-window)

(setq printCommand (format 
"echo mimeMailInject.sh -p envelopeAddr=envelope@mohsen.banan.1.byname.net -p fromAddr=office@mohsen.banan.1.byname.net -p toAddrList=\"faxout-%s@mohsen.banan.1.byname.net\" -i email_qmail %s/%s" 
		    fax-number
		    tex-output-directory
		    bbdb-a-file-name))

(ndmt-run-command printCommand
   (ndmt-host)
   (ndmt-user)
   (ndmt-password))

(pop-to-buffer  bbdb-a-output-buffer)

 )))

;;(setq bbdb-action-alist nil)

(setq bbdb-action-alist
  (append
   bbdb-action-alist
   '(("tex-fax-cover"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-tex-fax-cover)
      (add-hook 'bbdb-action-hook 'bbdb-a-tex-fax-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      ))
))

(provide 'tex-fax-cover)



