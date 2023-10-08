;;;  This file is part of the BBDB Filters Package. BBDB Filters Package is a
;;;  collection of input and output filters for BBDB.
;;;
;;;  Copyright (C) 1998 Twin Trees Company
;;; 	Prepared by Pean Lim <pean@twintrees.com>
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
;;; This is bbdb-palmpilot.el
;;;
;;;
;;; RCS: $Id: bbdb-palmpilot.el,v 1.1.1.1 2007/02/23 22:32:57 mohsen Exp $
;;;
;;; a copy-and-edit job on bbdb-schdplus.el


;;; To use this, add the following to your .emacs
;;; and strip ";;;XXX"
;;;

;;;XXX;; BBDB PALMPILOT Filter
;;;XXX(load "bbdb-palmpilot")

;;;XXX(setq bopp-filename
;;;XXX      (concat "/dos/u/" (user-login-name) "/bbdb-palmpilot.csv"))
;;;XXX;;; - to output the *BBDB* buffer in PALMPILOT comma-delimited-file (.CSV)
;;;XXX;;; format, invoke M-x bbdb-output-palmpilot

(defvar bopp-filename "~/bbdb-palmpilot.csv"
  "*Default file name for bbdb-output-palmpilot printouts of BBDB database.")


(defvar bopp-fields '(
		      ("Last name" nil nil)
		      ("First name" (bbdb-record-name record) nil)
		      ("Title" nil nil)
		      ("Company" (bbdb-record-company record) nil)
		      ("Contact 1" business-phone nil) ; default work
		      ("Contact 2" home-phone nil) ; default home
		      ("Contact 3" fax-phone nil) ; default fax
		      ("Contact 4" mobile-phone nil) ; default other
		      ("Contact 5" primary-net nil) ; default email
		      ("Address" (cond (business-address
					(concat (bbdb-address-street1 business-address)
						(bbdb-address-street2 business-address)))
				       (home-address
					(concat (bbdb-address-street1 home-address)
						(bbdb-address-street2 home-address)))
				       (t nil)) nil)					
		      ("City" (cond (business-address
				     (bbdb-address-city business-address))
				    (home-address
				     (bbdb-address-city home-address))
				    (t nil)) nil)
		      ("State" (cond (business-address
				      (bbdb-address-state business-address))
				     (home-address
				      (bbdb-address-state home-address))
				     (t nil)) nil)
		      ("Zip Code" (cond (business-address
					 (bbdb-address-zip-string business-address))
					(home-address
					 (bbdb-address-zip-string home-address))
					(t nil)) nil)
		      ("Country" nil nil)
		      ("Custom 1" nil nil)
		      ("Custom 2" nil nil)
		      ("Custom 3" nil nil)
		      ("Custom 4" nil nil)
		      ("Note" cooked-notes nil)
		      )
  "Fields for each record in a PalmPilot Address Book export file.
Form is (<field name> <field-sexpr> <field-width>)")

;;; ---------------------------------------------------------------------
;;; User Functions
;;; ---------------------------------------------------------------------

(defun bbdb-output-palmpilot (to-file)
  "Print the selected BBDB entries in 3COM PalmPilot Address Book
comma-delimited import/export file format."
  (interactive (list (read-file-name "Output To File: "
				     (expand-file-name (file-name-directory bopp-filename))
				     bopp-filename
				     nil
				     (file-name-nondirectory bopp-filename)
				     )))
  (setq bopp-filename (expand-file-name to-file))
  (let ((records (progn (set-buffer bbdb-buffer-name) bbdb-records)))
    (if records
	(let ((current-letter t)
	      bopp-output-buffer)
	  (setq bopp-output-buffer (find-file bopp-filename))
	  (delete-region (point-min) (point-max))
	  (bopp-do-prelude bopp-output-buffer)
	  (while records
	    (setq current-letter
		  (bopp-maybe-output-record (car (car records)) bopp-output-buffer current-letter))
	    (setq records (cdr records)))
	  (bopp-do-postlude bopp-output-buffer)
	  (goto-char (point-min))
	  (save-buffer)
	  (message "PalmPilot Address Book comma-delimited import/export file %s generated." bopp-filename))

      (ding)
      (message "No BBDB records selected."))))

;;; ---------------------------------------------------------------------
;;; major functions
;;; ---------------------------------------------------------------------

(defun bopp-do-prelude (output-buffer)
  ;; noop
  )


(defun bopp-maybe-output-record (record output-buffer &optional current-letter brief)
  "Insert the bbdb RECORD in MS PalmPilot Address Book import/export export format.
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
	    (cond ((or (string-match place "work")
		       (string-match place "office")
		       (string-match place "direct")
		       (string-match place "did")
		       (string-match place "main")
		       (string-match place "business"))
		   (if (null business-phone)
		       (setq business-phone number)
		     (setq more-phones (cons (list place number) more-phones))))
		  ((or (string-match place "home")
		       (string-match place "residence"))
		   (if (null home-phone)
		       (setq home-phone number)
		     (setq more-phones (cons (list place number) more-phones))))
		  ((or (string-match place "fax")
		       (string-match place "facsimile"))
		   (if (null fax-phone)
		       (setq fax-phone number)
		     (setq more-phones (cons (list place number) more-phones))))
		  ((or (string-match place "mobile")
		       (string-match place "cell")
		       (string-match place "handphone")
		       (string-match place "h/p"))
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
      (set-buffer (get-buffer-create " *bopp-scratch*"))
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
		    (insert (format "[notes] %s\t" (bopp-mangle-if-multi-line (cdr thisnote))))
		  (insert (format "[%s] %s\t"
				  (symbol-name (car thisnote))
				  (bopp-mangle-if-multi-line (cdr thisnote))))))))
	(setq notes (cdr notes)))
      (setq cooked-notes (buffer-string)))

    ;;
    ;; test for letter transitions
    ;;

    (if (and current-letter (not (string-equal first-letter current-letter)))
	(progn
	  (message "Now processing \"%s\" entries..." (upcase first-letter))
	  (sleep-for 1))
      )

    ;;
    ;; Now output the BBDB record in PalmPilot Address Book import/export format...
    ;;

    (progn
      (mapcar '(lambda (field-info)
		 (let (palmpilot-field-name field-handler raw-result raw-string
					   (cooked-string ""))
		   (setq palmpilot-field-name (nth 0 field-info))
		   (setq field-sexpr (nth 1 field-info))
		   (setq field-width (nth 2 field-info))

		   ;; generate output for the field
		   (cond ((setq raw-result (eval field-sexpr))
			  (setq raw-string (format "%s" raw-result))
			  (setq cooked-string (bopp-cook-string raw-string field-width))
			  (insert cooked-string)
			  )
			 ((or (null raw-string)
			      (string-equal cooked-string ""))
			  (insert "\"\"")))

		   ;; done with field output
		   (insert ",")))
	      bopp-fields)
      ;; mark end of record with a "0"
      (bopp-insert-eor)))

  ;; return current letter
  current-letter)


(defun bopp-do-postlude (output-buffer)
  ;; noop
  )

;;; ---------------------------------------------------------------------
;;; support functions
;;; ---------------------------------------------------------------------

(defun bopp-insert-eor()
  (insert "\"0\"\n"))


(defun bopp-maybe-truncate (string field-width)
  "If STRING is longer than FIELD-WIDTH, returns a truncated version."
)


(defun bopp-cook-string (raw-string field-width)
  (let (cooked-string non-whitespace-pos)
    ;;
    ;; strip leading whitespace
    ;;
    (setq cooked-string
	  (cond ((setq non-whitespace-pos (string-match "\\S " raw-string))
		 (substring raw-string non-whitespace-pos))
		(t "")))
    ;;
    ;; take care of special characters
    ;;
    (setq cooked-string (string-replace-regexp raw-string "\"" "''"))
    ;;
    ;; test for field-width
    ;; 
    (setq cooked-string (cond (field-width
			       (if (> (length cooked-string) field-width)
				   (substring cooked-string 0 field-width)
				 cooked-string))
			      (t cooked-string)))
    ;;
    ;; return within quotes
    ;;
    (format "\"%s\"" cooked-string)))
  

(defun bopp-mangle-if-multi-line (string)
  "If STRING is has multiple lines, mangle it for output to palmpilot"
  (if (string-match "\n" string)
      (string-replace-regexp string "\n" "\t") ; tabs are used to denote new lines in the .csv file
  string))

;;; ---------------------------------------------------------------------
(provide 'bbdb-palmpilot)
