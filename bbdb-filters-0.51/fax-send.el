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
(require 'tex-fax-cover)

(defun a-fax-send (records)
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

(a-tex-fax-cover)

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

(defun a-fax-gen (records)
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

(a-tex-fax-cover)

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

;;(setq bbdb-action-alist nil)

(setq bbdb-action-alist
  (append
   bbdb-action-alist
   '(("fax-send"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-fax-send)
      (add-hook 'bbdb-action-hook 'bbdb-a-fax-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      ;; NOTYET, Directory is not set right
       ))
   '(("fax-gen"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-fax-gen)
      (add-hook 'bbdb-action-hook 'bbdb-a-fax-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      ;; NOTYET, Directory is not set right
       ))
))

(provide 'fax-send)



