;;;(setq lisp-indent-offset 2)
;;;
;;; Time-stamp: "01/04/03 11:31:20 pinneke"
;;;  (setq debug-on-error nil)
;;; (setq debug-on-error t)
;;; Variables
;;;

;;; comRecs.el
;;; 
;;; This code produce a Communication record which gets the input of
;;; the person of interest from BBDB buffer.
;;;
;;; Example: when you are making a phone conversation with someone,
;;; you may want to record what's your discussion are or take notes.
;;; By having the notes, you can visit that notes for later time.
;;;
;;; comRecs-create-new: create new comRecs -- this file will be placed
;;; in its own directory with the date extension
;;; (i.e. ~/bbdbGens/comRecs/Doe/010404115523.notes)
;;;
;;; comRecs-visit-file: visit the existing comRecs notes.

(require 'bbdb-action-lib)

;;; 
;;; NOTYET:  Should be done elsewhere
;;;

;(setq comRecs-output-directory (concat originator-tex-bbdb-dir "/comRecs/"))

;(make-directory comRecs-output-directory comRecs-output-directory)
;(setq bbdb-a-directory-name comRecs-output-directory)

(defun bbdb-record-comrec (record)
  (if (consp (bbdb-record-raw-notes record))
      (cdr (assq 'comrec (bbdb-record-raw-notes record)))
      (bbdb-record-raw-notes record)))

(defun bbdb-a-comrec-directory-hook (records) ;; should be move to bbdb-action-lib.el
  ""
   (let* (
	  (comrec (bbdb-record-comrec (car records)))
	  )

     (setq bbdb-a-file-name
	   (format "%s/" comrec))
     ))

(defun a-comRecs (records)
  ""

  (bbdb-a-get-file-name records)

   (let* (
	  ;;(first-letter (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	  ;; raw fields
	  (name (bbdb-record-name (car records)))
	  (lastname (bbdb-record-lastname (car records)))
	  (net (bbdb-record-net (car records)))
	  (company (bbdb-record-company (car records)))
	  (comrec (bbdb-record-comrec (car records)))
	  (primary-net (car net))
	  nsl ns
	  )

     (save-excursion
       (set-buffer bbdb-a-output-buffer)
       (setq time-stamp-format "%b %02d, %y -- %H:%M:%S by %u")
       (insert (concat "ComRecs for: " name " - " company "\n"))
       (insert (concat "Creation Date: " (time-stamp-string) "\n\n"))
 )))

;;(setq bbdb-action-alist nil)

(setq bbdb-action-alist
  (append
   bbdb-action-alist
   '(("comRecs-this-create"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-comRecs)
      (add-hook 'bbdb-action-hook 'bbdb-a-notes-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-date-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-directory-hook)
      ))

   '(("comRecs-this-visit"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-visit-file-name)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-directory-hook)
      ))

   '(("comRecs-group-create"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-comRecs)
      (add-hook 'bbdb-action-hook 'bbdb-a-notes-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-date-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-comrec-directory-hook)
      ))

   '(("comRecs-group-visit"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-visit-file-name)
      (add-hook 'bbdb-action-hook 'bbdb-a-comrec-directory-hook)
      ))))

(provide 'comRecs)



