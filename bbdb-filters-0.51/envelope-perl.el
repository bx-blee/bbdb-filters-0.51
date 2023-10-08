;;;(setq lisp-indent-offset 2)
;;;
;;; Time-stamp: "010318224609"
;;;  (setq debug-on-error nil)
;;; (setq debug-on-error t)
;;; Variables
;;;

;;; envelope-gen.el
;;; 
;;; This code will produce a LaTeX file for the letter.
;;; The originator's letter head
;;; are set in the originator-prefs.el.
;;; This function is intended to be used with bbdb.
;;; The recipient's information will automatically 
;;; inserted from the bbdb record.

(require 'bbdb-action-lib)

(defun a-envelope-gen-common ()
""
       (insert "[from]\n")

       (insert (concat "" originator-full-name "\n"))
       (insert (concat "" originator-street-address1 "\n"))
       (if (not (eq originator-street-address2 nil))
	   (insert (concat "" originator-street-address2 "\n")))
       (insert (concat "" originator-city-address ", " originator-state-address " " originator-zipcode-address "\n\n"))


       (insert "[to]\n")

       (insert (concat "" name "\n"))
       (if (not (eq company nil))
	   (insert (concat company "\n")))
       (bbdb-envelope-address records)
)


(defun bbdb-envelope-address (records)
  ""
   (let ( ns )

     (setq bbdb-current-address nil)
       (setq ns (bbdb-record-get-addressfield-string (car records) 'address-location))
       ;;(insert (format "%s\n" ns))

       (setq ns (bbdb-record-get-addressfield-string (car records) 'address-street1))
       (if ns (insert (format "%s\n" ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-street2))
      (if ns (insert (format "%s\n" ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-city))
      (if ns (insert (format "%s, " ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-state))
      (if ns (insert (format "%s   " ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-zip-string))
      (if ns (insert (format "%s" ns)))

      ))


(defun a-envelope-print-legal (records)
  ""

  (bbdb-a-get-file-name records)

   (let* (
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
;; Start the TeX format
;;
;(insert "% This is a machine-generated file through envelope-gen.el.\n")
;(insert "% Do not make any changes to this file.\n")
;(insert "% ===========================================================\n\n\n")
;(insert "% Envelope Size\n")
;(insert "\\hsize=9.5true in\\hoffset=0.5true in\n")
;(insert "\\vsize=4.125true in\\voffset=1.1875true in\n\n")

(a-envelope-gen-common)

(save-buffer)
(message "Envelope file %s generated." bbdb-a-file-name)
(kill-buffer  bbdb-a-output-buffer)

(setq printCommand (format 
		    "lcePrEnvelope.sh -p printerName=samsung -p envelopeType=number10 -p to=%s/%s -i print" 
		    tex-output-directory
		    bbdb-a-file-name))

(ndmt-run-command printCommand
   (ndmt-host)
   (ndmt-user)
   (ndmt-password))

 )))

(defun a-envelope-gen-legal (records)
  ""

  (bbdb-a-get-file-name records)

   (let* (
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
;; Start the TeX format
;;
;(insert "% This is a machine-generated file through envelope-gen.el.\n")
;(insert "% Do not make any changes to this file.\n")
;(insert "% ===========================================================\n\n\n")
;(insert "% Envelope Size\n")
;(insert "\\hsize=9.5true in\\hoffset=0.5true in\n")
;(insert "\\vsize=4.125true in\\voffset=1.1875true in\n\n")

(a-envelope-gen-common)

(save-buffer)
(message "Envelope file %s generated." bbdb-a-file-name)
;(kill-buffer  bbdb-a-output-buffer)

(setq printCommand (format 
		    "echo lcePrEnvelope.sh -p printerName=samsung -p envelopeType=number10 -p to=%s/%s -i print" 
		    tex-output-directory
		    bbdb-a-file-name))

(ndmt-run-command printCommand
   (ndmt-host)
   (ndmt-user)
   (ndmt-password))

 )))

(defun a-envelope-gen-7x5 (records)
  ""

  (bbdb-a-get-file-name records)

   (let* (
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
;; Start the TeX format
;;
;(insert "% This is a machine-generated file through envelope-gen.el.\n")
;(insert "% Do not make any changes to this file.\n")
;(insert "% ===========================================================\n\n\n")
;(insert "% Envelope Size\n")
;(insert "\\hsize=7.125true in\\hoffset=2.5true in\n")
;(insert "\\vsize=4.75true in\\voffset=0.5true in\n\n")

(a-envelope-gen-common)

 )))

;;(setq bbdb-action-alist nil)

(setq bbdb-action-alist
  (append
   bbdb-action-alist
   '(("envelope-print-legal"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-envelope-print-legal)
      (add-hook 'bbdb-action-hook 'bbdb-a-envelope-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      ;; NOTYET, Directory is not set right
       ))
   '(("envelope-gen-legal"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-envelope-gen-legal)
      (add-hook 'bbdb-action-hook 'bbdb-a-envelope-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      ;; NOTYET, Directory is not set right
       ))
   '(("envelope-gen-7x5"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-envelope-gen-7x5)
      (add-hook 'bbdb-action-hook 'bbdb-a-envelope-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      ))
))

(provide 'envelope-perl)



