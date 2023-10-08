;;;(setq lisp-indent-offset 2)
;;;
;;; Time-stamp: "01/04/04 16:26:30 pinneke"
;;;
;;;
;;; Variables
;;;

(setq bbdb-letter-address-default "Office")

(setq bbdb-a-file-name "output.bbdb")

(setq bbdb-a-directory-name "~/")

(setq bbdb-a-public-dir-name "/usr/devenv/bbdbNames")

(setq output-tex-bbdb-dir "~/bbdbGens")

(setq tex-output-directory (concat output-tex-bbdb-dir "/texOutputFiles/"))

(setq comRecs-output-directory (concat output-tex-bbdb-dir "/comRecs/"))


(defun create-directory (finalOutputDir)
""
(make-directory finalOutputDir finalOutputDir)
(setq bbdb-a-directory-name finalOutputDir)
)

;;; bbdb-a-output-buffer

;;;
;;; auto-load function to bring in the library
(time-stamp)

;;;
;;; bbdb-a-neda-lastname-date-file-hook is used to create
;;; the filename in the form of <lastname-date>.
;;; For example: Banan-000929102338 for Mohsen Banan's record.
;;;

(defun bbdb-a-lastname-date-file-hook (records)
  ""
;  (interactive (list (if (bbdb-do-all-records-p)
;			 (mapcar 'car bbdb-records)
;		       (bbdb-current-record))))

  (setq time-stamp-format "%02y%02m%02d%02H%02M%02S")

   (let* (
	  (lastname (bbdb-record-lastname (car records)))
	  )

     (setq bbdb-a-file-name
	   (format "%s-%s" lastname (time-stamp-string) ))
     ))

(defun bbdb-a-lastname-file-hook (records)
  ""
   (let* (
	  (lastname (bbdb-record-lastname (car records)))
	  )

     (setq bbdb-a-file-name
	   (format "%s" lastname))
     ))

(defun bbdb-a-lastname-directory-hook (records)
  ""
   (let* (
	  (lastname (bbdb-record-lastname (car records)))
	  )

     (setq bbdb-a-file-name
	   (format "%s/" lastname))
     ))

(defun bbdb-a-comrec-directory-hook (records)
  ""
   (let* (
	  (comrec (bbdb-record-comrec (car records)))
	  )

     (setq bbdb-a-file-name
	   (format "%s/" comrec))
     ))

(defun bbdb-a-date-file-hook (records)
  ""
;  (interactive (list (if (bbdb-do-all-records-p)
;			 (mapcar 'car bbdb-records)
;		       (bbdb-current-record))))

  (setq time-stamp-format "%02y%02m%02d%02H%02M%02S")

  (setq bbdb-a-file-name
	   (concat bbdb-a-file-name (format "%s" (time-stamp-string)))
     ))

(defun bbdb-a-tex-file-hook (records)
  "Adding the .tex extension to a filename"

  (setq bbdb-a-file-name
	(concat bbdb-a-file-name ".tex"))
  )

(defun bbdb-a-tex-letter-file-hook (records)
  "Adding the -letter.tex extension to a filename and create texOutputFiles directory"

  (create-directory tex-output-directory)

  (setq bbdb-a-file-name
	(concat bbdb-a-file-name "-letter.tex"))
  )

(defun bbdb-a-tex-memo-file-hook (records)
  "Adding the .tex extension to a filename"

  (create-directory tex-output-directory)

  (setq bbdb-a-file-name
	(concat bbdb-a-file-name "-memo.tex"))
  )

(defun bbdb-a-tex-fax-file-hook (records)
  "Adding the .tex extension to a filename"

  (create-directory tex-output-directory)

  (setq bbdb-a-file-name
	(concat bbdb-a-file-name "-fax.tex"))
  )

(defun bbdb-a-tex-envelope-file-hook (records)
  "Adding the .tex extension to a filename"

  (create-directory tex-output-directory)

  (setq bbdb-a-file-name
	(concat bbdb-a-file-name "-envelope.tex"))
  )

(defun bbdb-a-envelope-file-hook (records)
  "Adding the .envelope extension to a filename"

  ;; NOTYET, temporary HOOK
  ;;(setq tex-output-directory "/opt/priv/data/envelops/to/")

  (create-directory tex-output-directory)

  (setq bbdb-a-file-name
	(concat bbdb-a-file-name ".envelope"))
  )

(defun bbdb-a-fax-file-hook (records)
  "Adding the .fax extension to a filename"

  ;; NOTYET, temporary HOOK
  ;;(setq tex-output-directory "/opt/priv/data/envelops/to/")

  (create-directory tex-output-directory)

  (setq bbdb-a-file-name
	(concat bbdb-a-file-name ".fax"))
  )

(defun bbdb-a-notes-file-hook (records)
  "Adding the .tex extension to a filename"

  (create-directory comRecs-output-directory)

  (setq bbdb-a-file-name
	(concat bbdb-a-file-name ".notes"))
  )

(defun bbdb-a-txt-file-hook (records)
  "Adding the .txt extension to a filename"
  (setq bbdb-a-file-name
	(concat bbdb-a-file-name ".txt"))
  )

(defun bbdb-a-get-file-name (records)
  ""
  ;(interactive (list (if (bbdb-do-all-records-p)
  ;			 (mapcar 'car bbdb-records)
  ;		       (bbdb-current-record))))

  (if bbdb-action-isFirstRecord
      (let ((file-name
	     (expand-file-name
	      (read-file-name "Write To File: "
			      (concat bbdb-a-directory-name
				      bbdb-a-file-name))))
	    (completion-ignore-case t))
	(setq bbdb-a-output-buffer (find-file file-name))
	(if (if (> (buffer-size) 0)
		(not (yes-or-no-p "File is not empty; delete contents "))
	      nil)
	    nil
	  (delete-region (point-min) (point-max))
	  )))
  )

(defun bbdb-a-visit-file-name (records)
  ""
  ;(interactive (list (if (bbdb-do-all-records-p)
  ;			 (mapcar 'car bbdb-records)
  ;		       (bbdb-current-record))))

  (if bbdb-action-isFirstRecord
      (let ((file-name
	     (expand-file-name
	      (read-file-name "Visit To File: "
			      (concat bbdb-a-directory-name
				      bbdb-a-file-name))))
	    (completion-ignore-case t))
	(setq bbdb-a-output-buffer (find-file file-name))
	  )))

(defun a-load-originator-tex-bbdb-prefs (baseDir origFileName)
  ""
  (load-file (concat baseDir origFileName))
)

(defun a-example-output (records)
  ""
  ;(interactive (list (if (bbdb-do-all-records-p)
  ;			 (mapcar 'car bbdb-records)
  ;		       (bbdb-current-record))))

  ;;(setq bbdb-a-directory-name "/usr/devenv/doc/nedaComRecs/vc-sharpShooter/coverLetters/")
  ;;(bbdb-a-neda-lastname-date-file-hook records)
  ;;(bbdb-a-tex-file-hook records)

  (bbdb-a-get-file-name records)

   (let* (
	  ;;(first-letter (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	  ;; raw fields
	  (name (bbdb-record-name (car records)))
	  (lastname (bbdb-record-lastname (car records)))
	  (net (bbdb-record-net (car records)))
	  (primary-net (car net))
	  )
     (save-excursion
       (set-buffer bbdb-a-output-buffer)

      (insert (time-stamp-string))

      (insert "\n\n")

      (insert (concat "Mr. " lastname ",\n"))

      )))



;;(setq bbdb-action-alist nil)

(setq bbdb-action-alist
  (append
   bbdb-action-alist
   '(("example-output"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-example-output)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-tex-file-hook)
      (setq bbdb-a-directory-name "/tmp/")
      )
      )))

;;; (insert (format "\n%s" bbdb-action-hook))

(provide 'bbdb-action-lib)
