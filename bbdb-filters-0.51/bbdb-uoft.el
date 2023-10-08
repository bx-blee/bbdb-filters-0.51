;;; This file is part of the BBDB Filters Package. BBDB Filters Package is a
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

;;; This is bbdb-uoft.el

;;; This file is a bbdb filter.  It converts uoft files to the
;;; canonical bbdb input filter format (i.e., a file of
;;; bif-create-record expressions


(defvar bpf-default-bif-file "~/uoft-bif.el"
  "*Default file name for bbdb-uoft-input.")


(defvar bpf-default-domain-name (if (boundp '*eoe-site-name*) *eoe-site-name*)
  "*Default domain name for bbdb-uoft-input.")


(defvar bpf-default-org-name (if (boundp 'gnus-local-organization) gnus-local-organization
			       bpf-default-domain-name)
  "*Default organization name for bbdb-uoft-input.")




(defun bbdb-uoft-input (to-file)
  "Parse current buffer which contains a UNIX uoft file to generate a .bif format file"
  (interactive (list 
		(setq bpf-default-bif-file
		      (read-file-name "Output To File: "
				      (concat
				       (file-name-directory bpf-default-bif-file)
				       (concat "bif-" bpf-default-domain-name ".el"))
				      (concat
				       (file-name-directory bpf-default-bif-file)
				       (concat "bif-" bpf-default-domain-name ".el"))))))
  (let (to-buffer)
    (save-excursion
      (message (expand-file-name to-file))
      (set-buffer (find-file (expand-file-name to-file)))
      (delete-region (point-min) (point-max))
      (bif-buffer-insert-header)
      (setq to-buffer (current-buffer)))

    ;; walk the uoft file in the current buffer
    (goto-char (point-min))
    (while (not (eobp))
      (beginning-of-line)
      (bpf-parse-line "University Of Tehran" to-buffer)
      (forward-line 1))

    (message "Done.")
    (set-buffer to-buffer)
    ))


(defun bif-buffer-insert-header ()
  (insert "(require 'bbdb-uoft)\n\n"))


(defun bif-buffer-insert-record (pretty-name org-name email title)
  (insert (format "(bif-create-record"))

  (insert (format " \"%s\"" pretty-name)) ; NAME string

  (insert (format " \"%s\"" org-name))	; COMPANY is a string or nil

  (insert (format " \"%s\"" email))	; NET is a comma-separated list of email address,
					;  or a list of strings
  (insert " nil ")

  (insert "nil ")

  (insert (format " \"%s\"" title))

  (insert ")\n")
  )

;;; (bpf-parse-line "University Of Tehran" "*scratch*")

(defun bpf-parse-line (org-name to-buffer)
  "Parse the uoft file line.  Point is assumed to be at the beginning of line."
  (let (record-string this-title this-first this-last this-email)
    ;;(setq record-string "title:first:last:email")
    ;;(setq record-string "آموزشگر انفورماتیک:آناهیتا:آریان نیا:ariannia@ut.ac.ir")
    ;; (setq record-string ":اکرم:آقارضاکاشی:akashi@ut.ac.ir")
    (setq record-string (buffer-substring (point) (progn (end-of-line) (point))))

    (message "Processing record: %s" record-string)


    (sleep-for 1)


    ;; check for a valid and qualifying uid on line, else skip
    (cond ((and
	  
	   
	    (if (string-match "^\\([^:]+\\)" record-string)

		(setq this-title (substring record-string
	    				    (match-beginning 1)
	    				    (match-end 1)))
	      (setq this-title "")
	      )


	    (string-match "^[^:]*:\\([^:]+\\):" record-string)

	    (setq this-first (substring record-string
	    				    (match-beginning 1)
	    				    (match-end 1)))


	   (string-match "^[^:]*:[^:]*:\\([^:]+\\):" record-string)

	   (setq this-last (substring record-string
	    				    (match-beginning 1)
	    				    (match-end 1)))



	   ;;(string-match "^.*:\\(\\w*\\)" record-string)
	   (string-match "^.*:\\(.*\\)" record-string)

	   (setq this-email (substring record-string
	    				    (match-beginning 1)
	    				    (match-end 1)))
	   )

	   (message "Got Record: %s -- %s -- %s -- %s" this-title this-first this-last this-email )
	   )
	  (t
	   ;; not a valid line, skip
	   (message "Invalid Line Skiped: %s" record-string)
	   nil))

	   ;; output bif record
	   (save-excursion
	     (set-buffer to-buffer)
	     (bif-buffer-insert-record 
	      (concat  this-first " " this-last)
	      org-name
	      this-email
	      this-title
	      )
	     )
	   )
  )
    

(defun bif-create-record (name company net &optional addrs phones notes)
  "Try to add a record to BBDB; if one does not already exist."
  (condition-case err
      (progn
	(bbdb-create-internal name company net addrs phones notes)
	(message "%s <%s> added." name net))
    (error (message "%s" (car (cdr err)))
	   (sleep-for 1))))


(provide 'bbdb-uoft)

