;; This file is part of the BBDB Filters Package. BBDB Filters Package is a
;;; collection of input and output filters for BBDB.
;;;
;;; Copyright (C) 1995 Neda Communications, Inc.
;;;        Prepared by Mohsen Banan (mohsen@neda.com)
;;;
;;; This library is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU Library General Public License as
;;; published by the Free Software Foundation; either version 2 of the
;;; License, or (at your option) any later version.  This library is
;;; distributed in the hope that it will be useful, but WITHOUT ANY
;;; WARRANTY; without even the implied warranty of MERCHANTABILITY or
;;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
;;; License for more details.  You should have received a copy of the GNU
;;; Library General Public License along with this library; if not, write
;;; to the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139,
;;; USA.

;;; This is bbdb-names.el

;;; Names file are taken in as input or generated as output
;;; based on the current bbdb buffer.



(defun bbdb-names-input ()
  ""
  (interactive)
  (bbdb-names-blank)
  (bbdb-names-append))

(defun bbdb-names-append ()
  "Given current buffer of names, bring up each line in the BBDB buffer"
  (interactive)
    ;; walk the passwd file in the current buffer
    (goto-char (point-min))
    (while (not (eobp))
      (beginning-of-line)
      (bbdb-names-process-line)
      (forward-line 1))

    ;;(message "Done.")
    )


(defun bbdb-names-process-line ()
  ""
  (interactive)
  ;;
  ;; Watch for the first letter convention
  ;;
  (let (record-string)
    (setq record-string (buffer-substring (point)
					  (progn (end-of-line) (point))))

    (message "Processing record: %s" record-string)


    ;;; NOTYET, make sure the string is not blank.

    (cond
     ((string= "" record-string)
	(message "Skipping Empty Line")
     )

     ((string-match "^\\#" record-string) 
	(message "Skipping #Line")
     )

     ((string-match "^\\;;" record-string) 
      ;;; Comment Line
	(message "Skipping #Line")
     )

    (t
     (progn
       (save-excursion
	 (set-buffer "*BBDB*")
	 (bbdb-append-name record-string nil)))
     ;; NOTYET, process error if bbdb-appen fails
     )
    )
    ))


(defun bbdb-names-blank ()
  ""
  (interactive)
  ;;
  ;; Watch for the first letter convention
  ;;
  (bbdb-name "BlankZZZXXXAAABlank" nil)
  )

;;;
;;; BBDB Names Output
;;;

(setq bbdb-names-dirname (concat bbdb-a-public-dir-name "/Names/"))
(setq bbdb-names-new-filename (concat bbdb-names-dirname "freshFolks.names"))


(defun bbdb-a-namesOutGen (records) 
  ""
  (setq bbdb-names-dirname (concat bbdb-a-public-dir-name "/Names/"))
  (setq bbdb-names-new-filename (concat bbdb-names-dirname "freshFolks.names"))


  (if bbdb-action-isFirstRecord
      (let ((file-name
	     (expand-file-name
	      (read-file-name "Write To File: "
			      bbdb-names-new-filename)))
	    (completion-ignore-case t))
	(setq bbdb-a-namesGen-output-buffer (find-file file-name))
	(if (if (> (buffer-size) 0)
		(not (yes-or-no-p "File is not empty; delete contents "))
	      nil)
	    nil
	  (delete-region (point-min) (point-max))
	  ;(setq bbdb-action-isFirstRecord nil)
	  )))

   (let* (
	  ;;(first-letter (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	  ;; raw fields
	  (name (bbdb-record-name (car records)))
	  (net (bbdb-record-net (car records)))
	  (primary-net (car net))
	  )
     (save-excursion 
       (set-buffer bbdb-a-namesGen-output-buffer)
       (if (null primary-net)
	   (progn
	     (insert (format "#%s\n" name))
	     (message "Skiped name"))
	 (insert (format "%s\n" name))))
     ))


;; (setq bbdb-action-alist nil)

(setq bbdb-action-alist 
  (append 
   bbdb-action-alist
   '(("names-out-gen" 
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-namesOutGen)
      ;(setq bbdb-action-isFirstRecord t)
      ))))

(defun bbdb-a-namesOutAppend (records) 
  ""
  ;(interactive (list (if (bbdb-do-all-records-p)
  ;			 (mapcar 'car bbdb-records)
  ;		       (bbdb-current-record))))

  ;;(ding)

  (setq bbdb-names-dirname (concat bbdb-a-public-dir-name "/Names/"))
  (setq bbdb-names-new-filename (concat bbdb-names-dirname "newFolks.names"))

  (if bbdb-action-isFirstRecord
      (let ((file-name
	     (expand-file-name
	      (read-file-name "Write To File: "
			      bbdb-names-new-filename			    
			      )))
	    (completion-ignore-case t))
	(setq bbdb-a-namesGen-output-buffer (find-file file-name))
	))

   (let* (
	  ;;(first-letter (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	  ;; raw fields
	  (name (bbdb-record-name (car records)))
	  (net (bbdb-record-net (car records)))
	  (primary-net (car net))
	  )
     (save-excursion 
       (set-buffer bbdb-a-namesGen-output-buffer)
       (goto-char (point-max))
       (if (null primary-net)
	   (progn
	     (insert (format "#%s\n" name))
	     (message "Skiped name"))
	 (insert (format "%s\n" name)))
       (save-buffer)
       (kill-buffer bbdb-a-namesGen-output-buffer))
     ))


;; (setq bbdb-action-alist nil)

(setq bbdb-action-alist 
  (append 
   bbdb-action-alist
   '(("names-out-append" 
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-namesOutAppend)
      ;(setq bbdb-action-isFirstRecord t)
      ))))

(provide 'bbdb-names)


