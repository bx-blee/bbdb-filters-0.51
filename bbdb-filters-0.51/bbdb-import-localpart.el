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

;;; This is bbdb-localpart.el

;;; This file is a bbdb filter.  It converts passwd files to the
;;; canonical bbdb input filter format (i.e., a file of
;;; bif-create-record expressions


(defvar bpf-default-bif-file "~/passwd-bif.el"
  "*Default file name for bbdb-localpart-input.")


(defvar bpf-default-domain-name (if (boundp '*eoe-site-name*) *eoe-site-name*)
  "*Default domain name for bbdb-localpart-input.")


(defvar bpf-default-org-name (if (boundp 'gnus-local-organization) gnus-local-organization
			       bpf-default-domain-name)
  "*Default organization name for bbdb-localpart-input.")


(defvar bpf-omit-pretty-name-regexp "\\(Slip \\\|Listserv\\\|PPP\\)"
  "Skip pretty names that match this regular expression.
E.g., \"\\\\(Slip \\\\\\|Listserv\\\\\\|PPP\\\\)\"
")

(defvar bpf-omit-pretty-name-list '()
  "Skip pretty names that match this regular expression.
E.g., '(\"John Q. Public\")
")


(defun bbdb-localpart-input (domain-name org-name to-file)
  "Parse current buffer which contains a UNIX passwd file to generate a .bif format file"
  (interactive (list (setq bpf-default-domain-name (read-string "Domain name: "
								bpf-default-domain-name))
		     (setq bpf-default-org-name (read-string "Organization name: "
							     bpf-default-org-name))
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

    ;; walk the passwd file in the current buffer
    (goto-char (point-min))
    (while (not (eobp))
      (beginning-of-line)
      (name-local-part-parse-line domain-name org-name to-buffer)
      ;;(bpf-parse-line domain-name org-name to-buffer)
      (forward-line 1))

    (message "Done.")
    (set-buffer to-buffer)
    ))


(defun bif-buffer-insert-header ()
  (insert "(require 'bbdb-localpart)\n\n"))


(defun bif-buffer-insert-record (pretty-name org-name email)
  (insert (format "(bif-create-record"))

  (insert (format " \"%s\"" pretty-name)) ; NAME string

  (insert (format " \"%s\"" org-name))	; COMPANY is a string or nil

  (insert (format " \"%s\"" email))	; NET is a comma-separated list of email address,
					;  or a list of strings

  ;; (insert " nil")			 ; ADDRS is a list of address objects.
					; An address is a vector of the form
					; ["location" "line1" "line2" "line3" "City" "State" zip]

  ;; (insert " nil")                         ; PHONES is a list of phone-number objects.
					;  A phone-number is a vector of the form
					;  ["location" areacode prefix suffix extension-or-nil]
					;  or
					;  ["location" "phone-number"]

  ;; (insert " nil")                         ; NOTES is a string, or an alist associating symbols with
					;  strings.

  (insert ")\n")
  )


(defun bbdb-name-local-part-parse-line ()
  "Parse the passwd file line.  Point is assumed to be at the beginning of line."
  (interactive)
  (setq domain-name "sharif.edu")
  (let (record-string uid user-name pretty-name email)
    (setq record-string (buffer-substring (point)
					  (progn (end-of-line) (point))))

    (message "Processing record: %s" record-string)

    (sleep-for 1)

    ;; (setq record-string "mohsen:x:100:10:Mohsen Banan:/home/arash/mohsen:/bin/csh")
    ;; (setq record-string "Mohammad Saleh Tavazoei:Tavazoeixx")
    ;; check for a valid and qualifying uid on line, else skip
    (cond ((and
	   ;;(string-match "^[^:]*:[^:]*:[^:]*:[^:]*:\\([^:]+\\):" record-string)
	   (setq sep-pos (string-match ":" record-string))
	   ;;(string-match "^\\([^:]+\\):" record-string)
	   ;;(string-match "^\\w*:\\w*" record-string)
	  
	   (string-match "^\\([^:]+\\)" record-string)

	   (setq pretty-name (substring record-string
	    				    (match-beginning 1)
	    				    (match-end 1)))

	   (string-match "^.*:\\(\\w*\\)" record-string)

	   (setq user-name (substring record-string
	    				    (match-beginning 1)
	    				    (match-end 1)))


	   ;; synthesize email address
	   (setq email (concat user-name "@" domain-name))
	   (message "Got Email: %s" email)
	   ))
	  (t
	   ;; not a valid line, skip
	   (message "Invalid Line Skiped: %s" record-string)
	   nil))))



(defun name-local-part-parse-line (domain-name org-name to-buffer)
  "Parse the passwd file line.  Point is assumed to be at the beginning of line."
  (let (record-string uid user-name pretty-name email)
    (setq record-string (buffer-substring (point)
					  (progn (end-of-line) (point))))

    (message "Processing record: %s" record-string)

    ;; (setq record-string "mohsen:x:100:10:Mohsen Banan:/home/arash/mohsen:/bin/csh")
    ;; (setq record-string "Mohammad Saleh Tavazoei:Tavazoeixx")

    ;; check for a valid and qualifying uid on line, else skip
    (cond (
	   (and

	    (string-match "^\\([^:]+\\)" record-string)

	    (setq pretty-name (substring record-string
					 (match-beginning 1)
					 (match-end 1)))

	    (string-match "^.*:\\(\\w*\\)" record-string)

	    (setq user-name (substring record-string
				       (match-beginning 1)
				       (match-end 1)))

	    ;; synthesize email address
	    (setq email (concat (downcase user-name) "@" domain-name))

	    ;; output bif record
	    (save-excursion
	      (set-buffer to-buffer)
	      (bif-buffer-insert-record pretty-name org-name email)
	      )
	    ))
	  (t
	   ;; not a valid line, skip
	   (message "Invalid Line Skiped: %s" record-string)
	   nil)
	  )))


(defun bif-create-record (name company net &optional addrs phones notes)
  "Try to add a record to BBDB; if one does not already exist."
  (condition-case err
      (progn
	(bbdb-create-internal name company net addrs phones notes)
	(message "%s <%s> added." name net))
    (error (message "%s" (car (cdr err)))
	   (sleep-for 1))))


(provide 'bbdb-localpart)

