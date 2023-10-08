;;;  This file is part of the BBDB Filters Package. BBDB Filters Package is a
;;;  collection of input and output filters for BBDB.
;;; 
;;;  Copyright (C) 1995 Neda Communications, Inc.
;;; 	Prepared by Mohsen Banan (mohsen@neda.com)
;;; 
;;;  This library is free software; you can redistribute it and/or modify
;;;  it under the terms of the GNU Library General Public License as
;;;  published by the Free Software Foundation; either version 2 of the
;;;  License, or (at your option) any later version.  This library is
;;;  distributed in the hope that it will be useful, but WITHOUT ANY
;;;  WARRANTY; without even the implied warranty of MERCHANTABILITY or
;;;  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
;;;  License for more details.  You should have received a copy of the GNU
;;;  Library General Public License along with this library; if not, write
;;;  to the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139,
;;;  USA.
;;; 
;;; This is bbdb-export.el
;;;

(defvar bexp-export-compactly nil 
  "If nil, the exported records are compactly printed.  
Otherwise the exported forms are indented for human-readability (at a
cost of somewhat longer processing time for exporting records.  
The default value is nil.")

(defvar bexp-buffer-name "*BBDB* Export"
  "*Default buffer name for exporting the contents of the *BBDB* buffer.")

(defvar bexp-scratch-buffer-name " bbdb-export scratch")

(defvar bexp-mime-boundary "bexp-NextPart"
  "Use this string as the boundary for parts in a MIME message.")

(defvar bexp-exported-names '()
  "List of BBDB record-names last exported.")

(defun bbdb-export-elisp (non-email)
  "Export selected BBDB entries as a self-extracting elisp in
an email message.  If ARG then simply export to buffer 
`*BBDB* Export'."
  (interactive "P")
  (bbdb-export-elisp-internal)
  (cond (non-email t)
	(t (and (get-buffer "*mail*")
		(kill-buffer "*mail*"))
	   (mail)
	   (erase-buffer)
	   (insert (format "To: 
Subject: %s
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=\"%s\"
--text follows this line--
This is a multi-part message in MIME format.
%s
--%s
Content-Transfer-Encoding: 7bit
Content-Type: text/plain

Warning!  Evaluating the application/x-unsafe-elisp in this message is
potentially dangerous.  Be sure that the elisp code therein is safe.

--%s
Content-Transfer-Encoding: 7bit
Content-Type: application/x-unsafe-elisp; charset=us-ascii\n\n"
			   (bexp-summary4subject bexp-exported-names)
			   bexp-mime-boundary
			   (bexp-summary4text-plain bexp-exported-names)
			   bexp-mime-boundary
			   bexp-mime-boundary))
	   (goto-char (point-max))
	   (insert-buffer bexp-buffer-name)
	   (goto-char (point-max))
	   (insert (format "--%s--" bexp-mime-boundary))
	   (goto-char (point-min))
	   (search-forward "To:")
	   (end-of-line))))

(defun bbdb-export-elisp-internal ()
  "Export the selected BBDB entries as elisp."
  (save-excursion
    (let ((to-buffer (get-buffer-create bexp-buffer-name))
	  (records (progn (set-buffer bbdb-buffer-name)
			  bbdb-records))
	  (current-letter ""))
      ;; wipe to-buffer
      (switch-to-buffer to-buffer)
      (delete-region (point-min) (point-max))

      ;; insert header, records, trailer
      (bexp-buffer-insert-text-header)
      (goto-char (point-max))
      (bexp-buffer-insert-elisp-header)
      (goto-char (point-max))
      (setq bexp-exported-names '())
      (while records
	(setq current-letter
	      (bexp-do-record (car (car records)) current-letter))
	(setq records (cdr records)))
      (setq bexp-exported-names (reverse bexp-exported-names))
      (bexp-buffer-insert-elisp-trailer)
      (goto-char (point-max)) 
      (bexp-buffer-insert-text-trailer)
      
      ;; now indent the elisp
      (goto-char (point-min))
      (search-forward "(progn")
      (search-backward "(progn")
      (indent-sexp)
      (goto-char (point-min))
      ))
  (message "BBDB export buffer %s generated." bexp-buffer-name))

(defun bbdb-export-text (non-email)
  "Export selected BBDB entries as plain text in an email message.
If ARG then simply export to buffer `*BBDB* Export'."
  (interactive "P")
  (bbdb-export-text-internal)
  (cond (non-email t)
	(t (and (get-buffer "*mail*")
		(kill-buffer "*mail*"))
	   (mail)
	   (erase-buffer)
	   (insert (format "To: 
Subject: %s
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=\"%s\"
--text follows this line--
This is a multi-part message in MIME format.
%s
--%s
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii\n\n"
			   (bexp-summary4subject bexp-exported-names)
			   bexp-mime-boundary
			   (bexp-summary4text-plain bexp-exported-names)
			   bexp-mime-boundary))
	   (goto-char (point-max))
	   (insert-buffer bexp-buffer-name)
	   (goto-char (point-max))
	   (insert (format "--%s--" bexp-mime-boundary))
	   (goto-char (point-min))
	   (search-forward "To:")
	   (end-of-line))))

(defun bbdb-export-text-internal ()
  "Export the selected BBDB entries as elisp."
  (save-excursion
    (let ((to-buffer (get-buffer-create bexp-buffer-name))
	  (records (progn (set-buffer bbdb-buffer-name)
			  bbdb-records))
	  (current-letter ""))
      ;; wipe to-buffer
      (switch-to-buffer to-buffer)
      (delete-region (point-min) (point-max))

      ;; insert header, records, trailer
      (bexp-buffer-insert-text-header)
      (goto-char (point-max))
      (setq bexp-exported-names '())
      (mapcar '(lambda (record)
		 (setq bexp-exported-names 
		       (cons (bbdb-record-name (car record))
			     bexp-exported-names)))
	      records)
      (setq bexp-exported-names (reverse bexp-exported-names))
      (insert-buffer "*BBDB*")
      (goto-char (point-max))
      (bexp-buffer-insert-text-trailer)

      (goto-char (point-min))
      ))
  (message "BBDB export buffer %s generated." bexp-buffer-name))

(defun bexp-do-record (record current-letter)
  "Insert the bbdb RECORD in export format."
  (let* ((name   (bbdb-record-name record))
	 (comp   (bbdb-record-company record))
	 (net    (bbdb-record-net record))
	 (phones (bbdb-record-phones record))
	 (addrs  (bbdb-record-addresses record))
	 (notes  (bbdb-record-raw-notes record))
	 (first-letter (upcase (substring (concat (bbdb-record-sortkey record) "?") 0 1))))

    (if (not (string-equal first-letter current-letter))
	(progn (message "Now processing \"%s\" entries..." first-letter)
	       (sleep-for 1)))
    ;; save record name
    (setq bexp-exported-names (cons name bexp-exported-names))
    ;; output the record
    (bexp-buffer-insert-record name comp net addrs phones notes)
    first-letter))

(defun bexp-buffer-insert-elisp-header()
  (insert "(progn  
(require 'bbdb-com)
(defun bbdb-maybe-create (name company net &optional addrs phones notes)
  \"Try to add a record to BBDB if it does not already exist.\"
  (condition-case err
      (progn
	(bbdb-create-internal name company net addrs phones notes)
	(message \"`%s' added.\" name)
	(sleep-for 1))    
    (error (ding)
	   (message \"`%s' skipped (%s).\" name (car (cdr err)))
	   (sleep-for 1))))\n\n")
  (normal-mode))

(defun bexp-buffer-insert-text-header()
  (insert ";;; ======= Start of Exported BBDB Records =======\n"))

(defun bexp-buffer-insert-text-trailer()
  (insert ";;; ======= End of Exported BBDB Records =======\n"))

(defun bexp-buffer-insert-elisp-trailer()
  (insert ")\n"))

(defun bexp-buffer-insert-record (name comp net addrs phones notes)
  (let ((begin (point))
	end)
    (message "Exporting %s" name)
    (insert (format "(bbdb-maybe-create %s %s '%s '%s '%s '%s)\n"
		    (prin1-to-string (concat name "--IMPORTED"))
		    (prin1-to-string comp)
		    (prin1-to-string net)
		    (prin1-to-string addrs)
		    (prin1-to-string phones)
		    (prin1-to-string notes)
		    ))
    (setq end (point))
    (if (not bexp-export-compactly) 
	(progn
	  ;; format region
	  (narrow-to-region begin end)
	  (goto-char begin)
	  (replace-string " '(" "\n'(")
	  (goto-char begin)
	  (replace-string "\" \"" "\"\n\"")
	  (goto-char begin)
	  (replace-string "((" "(\n(")
	  (goto-char begin)
	  (replace-string "))" ")\n)")
	  (goto-char begin)
	  (replace-string "([" "(\n[")
	  (goto-char begin)
	  (replace-string "])" "]\n)")
	  (goto-char begin)
	  (replace-string ") (" ")\n(")
	  (goto-char begin)
	  (replace-string "] [" "]\n[")
	  (goto-char (point-max))
	  (lisp-indent-region begin (point))
	  (widen)))
    ))

(defun bexp-summary4subject (names-list)
  (cond ((= (length names-list) 1)
	 (format "BBDB record for %s." (car names-list)))
	((> (length names-list) 1)
	 (format "%d BBDB records (for %s, %s, ...)."
		 (length names-list)
		 (car names-list)
		 (car (cdr names-list))))
	(t "BBDB export output.")))

(defun bexp-summary4text-plain (names-list)
  (cond ((= (length names-list) 1) "")
	(t (let ((header-string (format "
--%s
Content-Transfer-Encoding: 7bit
Content-Type: text/plain

Message contains BBDB records for:
---------------------------------"
					bexp-mime-boundary))
		 (result-string ""))

	     (mapcar '(lambda (record-name)
			(setq result-string
			      (concat result-string "\n" record-name)))
		     names-list)
	     (concat header-string result-string "\n")))))

(provide 'bbdb-export)
