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
;;; This is bbdb-netscape6.el
;;;
;;;
;;; RCS: $Id: bbdb-netscape6.el,v 1.1.1.1 2007/02/23 22:32:57 mohsen Exp $
;;;
;;; a copy-and-edit job on bbdb-print.el


;;; To use this, add the following to your .emacs
;;; and strip ";;;XXX"
;;;

;;;XXX;; BBDB NETSCAPE6 Filter
;;;XXX(load "bbdb-netscape6")

;;;XXX(setq bon-filename
;;;XXX      (concat "/dos/u/" (user-login-name) "/bbdb-netscape6.csv"))
;;;XXX;;; - to output the *BBDB* buffer in NETSCAPE6 comma-delimited-file (.CSV)
;;;XXX;;; format, invoke M-x bbdb-output-netscape6

(defvar bon-filename "~/bbdb-netscape6.csv"
  "*Default file name for bbdb-output-netscape6 printouts of BBDB database.")


(defvar bon-fields '(
		     ("First Name" (bbdb-record-firstname record) nil)
		     ("Last Name" (bbdb-record-lastname record) nil)
		     ("Display Name" (concat (bbdb-record-firstname record) " " (bbdb-record-lastname record)))
		     ("Nickname Name" (bbdb-record-firstname record) nil)
		     ("E-mail" primary-net nil)
		     ("Secondary E-mail" nil nil)
		     ("Business Phone" business-phone nil)
		     ("Home Phone" home-phone nil)
		     ("Fax Phone" fax-phone nil)
		     ("Pager" nil nil)
		     ("Mobile Phone" mobile-phone nil)
		     ("Home Street 1" (if home-address (bbdb-address-street1 home-address)) nil)
		     ("Home Street 2" (if home-address (bbdb-address-street2 home-address)) nil)
		     ("Home City" (if home-address (bbdb-address-city home-address)) nil)
		     ("Home State" (if home-address (bbdb-address-state home-address)) nil)
		     ("Home Postal Code" (if home-address (bbdb-address-zip-string home-address)) nil)
		     ("Home Country" nil nil)
		     ; ("Anniversary" nil nil)
		     ; ("Assistant" nil nil)
		     ; ("Assistant Phone" nil nil)
		     ; ("Birthday" nil nil)
		     ("Business Street 1" (if business-address (bbdb-address-street1 business-address)) nil)
		     ("Business Street 2" (if business-address (bbdb-address-street2 business-address)) nil)
		     ("Business City" (if business-address (bbdb-address-city business-address)) nil)
		     ("Business State" (if business-address (bbdb-address-state business-address)) nil)
		     ("Business Postal Code" (if business-address (bbdb-address-zip-string business-address)) nil)
		     ("Business Country" nil nil)
		     ("Job Title" nil nil)
		     ("Department" nil nil)
		     ("Company" (bbdb-record-company record) nil)
		     ("Web Page 1" nil nil)
		     ("Web Page 2" nil nil)
		     ("Birth Year" nil nil)
		     ("Birth Month" nil nil)
		     ("Birth Day" nil nil)
		     ("User Field 1" nil nil)
		     ("User Field 2" nil nil)
		     ("User Field 3" nil nil)
		     ("User Field 4" nil nil)
		     ("Notes" cooked-notes nil)
		     )
  "Fields for each record in a netscape 6 export file.")

;;; ---------------------------------------------------------------------
;;; User Functions
;;; ---------------------------------------------------------------------

(defun bbdb-output-netscape6 (to-file)
  "Print the selected BBDB entries in Netscape 6 export file format."
  (interactive (list (read-file-name "Print To File: "
				     (file-name-directory bon-filename)
				     (file-name-nondirectory bon-filename)
				     nil
				     (file-name-nondirectory bon-filename)
				     )))
  (setq bon-filename (expand-file-name to-file))
  (let ((records (progn (set-buffer bbdb-buffer-name) bbdb-records)))
    (if records
	(let ((current-letter t)
	      bon-output-buffer)
	  (setq bon-output-buffer (find-file bon-filename))
	  (delete-region (point-min) (point-max))
	  (bon-do-prelude bon-output-buffer)
	  (while records
	    (setq current-letter
		  (bon-maybe-output-record (car (car records)) bon-output-buffer current-letter))
	    (setq records (cdr records)))
	  (bon-do-postlude bon-output-buffer)
	  (goto-char (point-min))
	  (save-buffer)
	  (message "Netscape 6 comma-delimited export file %s generated." bon-filename))
      
      (ding)
      (message "No BBDB records selected."))))

;;; ---------------------------------------------------------------------
;;; major functions
;;; ---------------------------------------------------------------------

(defun bon-do-prelude (output-buffer)
  (set-buffer output-buffer)
  (goto-char (point-min))
  (mapcar '(lambda (field-info)
	     (insert (format "\"%s\"," (car field-info))))
	  bon-fields)
  ;; take out the last comma
  (search-backward ",")
  (delete-char 1)
  (bon-insert-dos-eol))


(defun bon-maybe-output-record (record output-buffer &optional current-letter brief)
  "Insert the bbdb RECORD in Netscape 6 export format.
Optional CURRENT-LETTER is the section we're in -- if this is non-nil and
the first letter of the sortkey of the record differs from it, a new section
heading will be output \(an arg of t will always produce a heading).
The new current-letter is the return value of this function.
Someday, optional third arg BRIEF will produce one-line format."
  (bbdb-debug (if (bbdb-record-deleted-p record)
		  (error "plus ungood: formatting deleted record")))

  ;; (message "Processing new record") (sleep-for 1)
  (let* ((first-letter (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	 ;; raw fields
	 (name (bbdb-record-name record))
	 (net (bbdb-record-net record))
	 (phones (bbdb-record-phones record))
	 (addresses (bbdb-record-addresses record))
	 (notes (bbdb-record-raw-notes record))
	 saved-case-fold
	 ;; "cooked" phones
	 (business-phone nil)
	 (home-phone nil)
	 (fax-phone nil)
	 (mobile-phone nil)
	 (more-phones nil)
	 ;; "cooked" mail addresses
	 (business-address nil)
	 (home-address nil)
	 (more-addresses nil)
	 ;; "cooked" email addresses
	 (primary-net (car net))
	 (more-net (cdr net))
	 ;; "cooked" notes
	 cooked-notes)

    ;;
    ;; First do some BBDB record "cooking"
    ;; 

    ;; cook the phone entries for this BBDB record
    (unwind-protect 
	;; body form
	(let (place number)
	  (setq saved-case-fold case-fold-search)
	  (setq case-fold-search t)
	  (while phones
	    (setq place (bbdb-phone-location (car phones)))
	    (setq number (bbdb-phone-string (car phones)))
	    (cond ((or (string-match place "office")
		       (string-match place "work")
		       (string-match place "office phone")
		       (string-match place "work phone"))
		   (if (null business-phone)
		       (setq business-phone number)
		     (setq more-phones (cons (list place number) more-phones))))
		  ((string-match place "home")
		   (if (null home-phone)
		       (setq home-phone number)
		     (setq more-phones (cons (list place number) more-phones))))
		  ((or (string-match place "fax")
		       (string-match place "facsimile")
		       (string-match place "work fax")
		       (string-match place "home fax")
		       (string-match place "office fax"))
		   (if (null fax-phone)
		       (setq fax-phone number)
		     (setq more-phones (cons (list place number) more-phones))))
		  ((or (string-match place "mobile")
		       (string-match place "cell"))
		   (if (null mobile-phone)
		       (setq mobile-phone number)
		     (setq more-phones (cons (list place number) more-phones))))
		  (t
		   (setq more-phones (cons (list place number) more-phones))))
	    (setq phones (cdr phones))))
      ;; unwind forms
      (setq case-fold-search saved-case-fold))


    ;; Cook the addresses entries for this BBDB record
    (unwind-protect
	;; body form
	(let (place address)
	  (setq saved-case-fold case-fold-search)
	  (setq case-fold-search t)
	  (while addresses
	    (setq address (car addresses))
	    (setq place (bbdb-address-location address))
	    (cond ((or (string-match place "office")
		       (string-match place "work"))
		   (cond ((null business-address)
			  (setq business-address address))
			 (t (setq more-addresses (cons address more-addresses)))))
		  ((string-match place "home")
		   (cond ((null home-address)
			  (setq home-address address))
			 (t (setq more-addresses (cons address more-addresses)))))
		  (t
		   (setq more-addresses (cons address more-addresses))))
	    ;; goto next address
	    (setq addresses (cdr addresses))))
      ;; unwind forms
      (setq case-fold-search saved-case-fold))


    ;; Cook the notes for this BBDB record
    (save-excursion
      (set-buffer (get-buffer-create " *bon-scratch*"))
      (kill-region (point-min) (point-max))

      ;; put other phones in the cooked-notes
      (if more-phones (insert "More phones: "))
      (while more-phones
	(insert (format "%s: %s\t"
			(car (car more-phones)) ; the tag
			(car (cdr (car more-phones)))) ; the number
		)
	(setq more-phones (cdr more-phones)))

      ;; put other email addresses in the cooked notes
      (if more-net (insert "More email addresses: "))
      (while more-net
	(insert (format "%s\t" (car more-net)))
	(setq more-net (cdr more-net)))

      ;; put other snail mail addresses in the cooked notes
      (if more-addresses (insert "More mail addresses: "))
      (while more-addresses
	(insert (format "%s: [%s|%s|%s|%s|%s]\t"
			(bbdb-address-location (car more-addresses))
			(bbdb-address-street1 (car more-addresses))
			(bbdb-address-street2 (car more-addresses))
			(bbdb-address-city (car more-addresses))
			(bbdb-address-state (car more-addresses))
			(bbdb-address-zip-string (car more-addresses))))
	(setq more-addresses (cdr more-addresses)))

      ;; now the BBDB notes proper
      (if (stringp notes)
	  (setq notes (list (cons 'notes notes))))
      (while notes
	(let ((thisnote (car notes)))
	  (if (bbdb-field-shown-p (car thisnote))
	      (progn
		(if (eq 'notes (car thisnote))
		    (insert (format "[notes] %s\t" (bon-mangle-if-multi-line (cdr thisnote))))
		  (insert (format "[%s] %s\t"
				  (symbol-name (car thisnote))
				  (bon-mangle-if-multi-line (cdr thisnote))))))))
	(setq notes (cdr notes)))
      (setq cooked-notes (buffer-string)))

    ;;
    ;; test for letter transitions
    ;;

    (if (and current-letter (not (string-equal first-letter current-letter)))
	(message "Now processing \"%s\" entries..." (upcase first-letter)))

    ;;
    ;; Now output the BBDB record in Netscape 6 format...
    ;; 

    (progn
      (mapcar '(lambda (field-info)
		 (let (netscape6-field-name field-handler raw-string
					   (cooked-string ""))
		   (setq netscape6-field-name (nth 0 field-info))
		   (setq field-sexpr (nth 1 field-info))
		   (setq field-width (nth 2 field-info))

		   ;; generate output for the netscape 6 field
		   (cond ((stringp (setq raw-string (eval field-sexpr)))
			  (setq cooked-string
				(format "\"%s\""
					(cond (field-width (bon-maybe-truncate raw-string field-width))
					      (t raw-string))))
			  (insert cooked-string)
			  ))

		   ;; done with field output
		   (insert ",")))
	      bon-fields)
      ;; remove trailing "," and end line
      (search-backward ",")
      (delete-char 1)
      (bon-insert-dos-eol)))

  ;; return current letter
  current-letter)


(defun bon-do-postlude (output-buffer)
  ;; noop
  )

;;; ---------------------------------------------------------------------
;;; support functions
;;; ---------------------------------------------------------------------

(defun bon-insert-dos-eol()
  (insert "\n"))


(defun bon-maybe-truncate (string maxlen)
  "If STRING is longer than MAXLEN, returns a truncated version."
  (if (> (length string) maxlen)
      (substring string 0 maxlen)
    string))


(defun bon-mangle-if-multi-line (string)
  "If STRING is has multiple lines, mangle it for output to NETSCAPE6"
  (if (string-match "\n" string)
      (string-replace-regexp string "\n" "\t") ; tabs are used to denote new lines in the .csv file
  string))

;;; ---------------------------------------------------------------------
(provide 'bbdb-netscape6)
