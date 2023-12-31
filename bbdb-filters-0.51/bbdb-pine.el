;;;  This file is part of the BBDB Filters Package. BBDB Filters Package is a
;;;  collection of input and output filters for BBDB.
;;; 
;;;  Copyright (C) 1996 Neda Communications, Inc.
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
;;; This is bbdb-pine.el
;;;
;;; 
;;; RCS: $Id: bbdb-pine.el,v 1.1.1.1 2007/02/23 22:32:57 mohsen Exp $
;;;
;;; a copy-and-edit job on bbdb-print.el

;;; To use this, add the following to your .emacs
;;; and strip ";;;XXX"
;;;
;;; 

;;;XXX;; BBDB -> PINE Output Filter
;;;XXX(load "bbdb-pine")

;;;XXX(setq bbdb-pine-filename "~/.addressbook")
;;;XXX;;; And then
;;;XXX;;; (bbdb-output-pine)

;;; TODO
;;; Make the alias names be "first.last" instead of "nic-%d"
;;;

(require 'bbdb-print)

(defvar bbdb-pine-filename "~/.addressbook"
  "*Default file name for bbdb-output-pine printouts of BBDB database.")

(defun bbdb-output-pine (to-file)
  "Print the selected BBDB entries"
  (interactive (list (read-file-name "Print To File: " bbdb-pine-filename)))
  (setq bbdb-pine-filename (expand-file-name to-file))
  (let ((current-letter t)
	(records (progn (set-buffer bbdb-buffer-name)
			bbdb-records)))
    (find-file bbdb-pine-filename)
    (delete-region (point-min) (point-max))
    (let* ((pine-count 0))
      (while records
	(setq current-letter 
	      (boe-pine-format-record (car (car records))
					current-letter))
	(setq records (cdr records)))
      ;;(goto-char (point-min))
      ;;(insert (format "[smtpgate]\nEntryCount=%d\n" pine-count))
      (goto-char (point-min)))))

(defun boe-pine-output-this-record-p (name net)
  "Examine NAME COMP NET PHONES ADDRS NOTES and return t if 
the current record is to be output by bbdb-output-pine."
  ;; if name is non-nil, output it
  (cond ((and name net) t)
	(t nil))
  )


(defun boe-pine-format-record (record &optional current-letter brief)
  "Insert the bbdb RECORD in Pine format.
Optional CURRENT-LETTER is the section we're in -- if this is non-nil and
the first letter of the sortkey of the record differs from it, a new section
heading will be output \(an arg of t will always produce a heading).
The new current-letter is the return value of this function.
Someday, optional third arg BRIEF will produce one-line format."
  (bbdb-debug (if (bbdb-record-deleted-p record)
		  (error "plus ungood: tex formatting deleted record")))
  
  (let* ((bbdb-elided-display bbdb-print-elide)
	 (first-letter 
	  (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	 (name   (and (bbdb-field-shown-p 'name)
		      (or (bbdb-record-getprop record 'tex-name)
			  (bbdb-print-tex-quote
			   (bbdb-record-name record)))))
	 (net    (and (bbdb-field-shown-p 'net)
		      (bbdb-record-net record)))
	 (begin (point))
	 )

    (if (and current-letter
	     (not (string-equal first-letter current-letter)))
	(message "Now processing \"%s\" entries..." (upcase first-letter)))
    
    (if (boe-pine-output-this-record-p name net)
	(progn 

	  ;; Email address -- just use their first address.
	  (if net
	      (let ((net-addr (car net))
		    (start 0))
		(setq pine-count (+ pine-count 1))
		(insert (format "%s\t%s\t%s\n"
				(normalize-name-for-bbdb-pine name)
				name net-addr))))
	  (setq current-letter first-letter))
      )

    ;; return current letter
    current-letter))

(defun normalize-name-for-bbdb-pine (name)
  "Take a bbdb name string and normalize it as all lower-case first.last"
  (let ((n-name nil))
    (mapcar '(lambda (chunk)
	       (cond 
		((string-equal chunk "") nil)
		(t (setq n-name (if (null n-name) chunk
				  (concat n-name "." chunk))))))
	    (chop-string name "\\\( \\\|\\.\\\)"))
    (downcase n-name)))

;;; for cutting up a string into a list of strings based on a regexp separator
(defun chop-string (string separator-regexp &optional reversed-ok-p)
  "chop STRING using SEPARATOR-REGEXP.  Result is reversed if REVERSED-OK-P is not nil"
  (chop-string-internal string separator-regexp 0 '() reversed-ok-p))

(defun chop-string-internal (string separator-regexp start-index result-list reversed-ok-p)
  (cond ((string-match separator-regexp string start-index)
	 (chop-string-internal string separator-regexp (match-end 0)
			       (cons (substring string start-index (match-beginning 0))
				     result-list)
			       reversed-ok-p))
	(t (if reversed-ok-p
	       (cons (substring string start-index) result-list)
	     (reverse (cons (substring string start-index) result-list))))))
