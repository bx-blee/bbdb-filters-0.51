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

;;; This is bbdb-vcard.el

;;; Names file are taken in as input or generated as output
;;; based on the current bbdb buffer.

;;;
;;; BBDB Names Output
;;;


(require 'bbdb-vcard-export)
(require 'bbdb-action-lib)


(setq bbdb-vcard-dirname (concat bbdb-a-public-dir-name "/Vcards/"))
(setq bbdb-vcard-new-filename (concat bbdb-vcard-dirname "new.vcf"))


(defun bbdb-a-vcardsOutGen (records) 
  ""
  (setq bbdb-vcard-dirname (concat bbdb-a-public-dir-name "/Vcards/"))
  (setq bbdb-vcard-new-filename (concat bbdb-vcard-dirname "new.vcf"))


  (if bbdb-action-isFirstRecord
      (let ((file-name
	     (expand-file-name
	      (read-file-name "Write To File: "
			      bbdb-vcard-new-filename)))
	    (completion-ignore-case t))
	(setq bbdb-a-vcardsGen-output-buffer (find-file file-name))
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
	  (firstname (bbdb-record-firstname (car records)))
	  (lastname (bbdb-record-lastname (car records)))

	  (net (bbdb-record-net (car records)))
	  (primary-net (car net))
	  )
     (save-excursion 
       (set-buffer bbdb-a-vcardsGen-output-buffer)
       (if (null primary-net)
	   (progn
	     (message "Skiped name"))
	 (progn
	   (bbdb-vcard-export-record-insert-vcard (car records)))
	   ))
     ))

(defun bbdb-vcard-export-record-insert-vcard (record)
  "Insert a vcard formatted version of RECORD into the current buffer"
  (let ((name (bbdb-record-name record))
	(first-name (bbdb-record-firstname record))
	(last-name (bbdb-record-lastname record))
	(aka (bbdb-record-aka record))
	(company (bbdb-record-company record))
	(notes (bbdb-record-notes record))
	(phones (bbdb-record-phones record))
	(addresses (bbdb-record-addresses record))
	(net (bbdb-record-net record))
	(categories (bbdb-record-getprop
		     record
		     bbdb-define-all-aliases-field)))
    (insert "begin:vcard\n"
	    "version:3.0\n")
    ;; Specify the formatted text corresponding to the name of the
    ;; object the vCard represents.  The property MUST be present in
    ;; the vCard object.
    (insert "fn:" (bbdb-vcard-export-escape name) "\n")
    ;; Family Name, Given Name, Additional Names, Honorific
    ;; Prefixes, and Honorific Suffixes
    (when (or last-name first-name)
      (insert "n:"
	      (bbdb-vcard-export-escape last-name) ";"  
	      (bbdb-vcard-export-escape first-name) ";;;\n"))
    ;; Nickname of the object the vCard represents.  One or more text
    ;; values separated by a COMMA character (ASCII decimal 44).
    (when aka
      (insert "nickname:" (bbdb-vcard-export-several aka) "\n"))
    ;; FIXME: use face attribute for this one.
    ;; PHOTO;ENCODING=b;TYPE=JPEG:MIICajCCAdOgAwIBAgICBEUwDQYJKoZIhvcN
    ;; AQEEBQAwdzELMAkGA1UEBhMCVVMxLDAqBgNVBAoTI05ldHNjYXBlIENvbW11bm
    ;; ljYXRpb25zIENvcnBvcmF0aW9uMRwwGgYDVQQLExNJbmZvcm1hdGlvbiBTeXN0

    ;; FIXME: use birthday attribute if there is one.
    ;; BDAY:1996-04-15
    ;; BDAY:1953-10-15T23:10:00Z
    ;; BDAY:1987-09-27T08:30:00-06:00

    ;; A single structured text value consisting of components
    ;; separated the SEMI-COLON character (ASCII decimal 59).  But
    ;; BBDB doesn't use this.  So there's just one level:
    (when company
      (insert "org:" (bbdb-vcard-export-escape company) "\n"))
    (when notes
      (insert "note:" (bbdb-vcard-export-escape notes) "\n"))
    (dolist (phone phones)
      (insert "tel;type=" (bbdb-vcard-export-escape (bbdb-phone-location phone)) ":"
	      (bbdb-vcard-export-escape (bbdb-phone-string phone)) "\n"))
    (dolist (address addresses)
      (insert (bbdb-vcard-export-address-string address) "\n"))
    (dolist (mail net)
      (insert "email;type=internet:" (bbdb-vcard-export-escape mail) "\n"))
    ;; Use CATEGORIES based on mail-alias.  One or more text values
    ;; separated by a COMMA character (ASCII decimal 44).
    (when categories
      (insert "categories:" 
	      (bbdb-join (mapcar 'bbdb-vcard-export-escape
				 (bbdb-split categories ",")) ",") "\n"))
    (insert "end:vcard\n")))



;; (setq bbdb-action-alist nil)

(setq bbdb-action-alist 
  (append 
   bbdb-action-alist
   '(("vcards-out-gen" 
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-vcardsOutGen)
      ;(setq bbdb-action-isFirstRecord t)
      ))))

(defun bbdb-a-vcardsTmpGen (records) 
  ""

  (if bbdb-action-isFirstRecord
      (let ((file-name "/tmp/vcardsTmpGen.vcf"))
	(setq bbdb-a-vcardsGen-output-buffer (find-file file-name))
	(delete-region (point-min) (point-max))
	(message "Overwriting /tmp/vcardsTmpGen.vcf"))
	)


  (let* (
	  ;;(first-letter (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	  ;; raw fields
	  (name (bbdb-record-name (car records)))
	  (firstname (bbdb-record-firstname (car records)))
	  (lastname (bbdb-record-lastname (car records)))

	  (net (bbdb-record-net (car records)))
	  (primary-net (car net))
	  )
     (save-excursion 
       (set-buffer bbdb-a-vcardsGen-output-buffer)
       (if (null primary-net)
	   (progn
	     (message "Skiped name"))
	 (progn
	   (bbdb-vcard-export-record-insert-vcard (car records))
	   (save-buffer)
	   )
	 ))
     )

  (if (bbdb-action-isLastRecord records)
      (progn
	(save-buffer)
	(kill-buffer bbdb-a-vcardsGen-output-buffer)
	)
    )
  )

(setq bbdb-action-alist 
  (append 
   bbdb-action-alist
   '(("vcards-tmp-gen" 
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-vcardsTmpGen)
      ;(setq bbdb-action-isFirstRecord t)
      ))))


(defun bbdb-a-vcardsMiniOutGen (records) 
  ""
  (setq bbdb-vcard-dirname (concat bbdb-a-public-dir-name "/Vcards/"))
  (setq bbdb-vcard-new-filename (concat bbdb-vcard-dirname "new.vcf"))


  (if bbdb-action-isFirstRecord
      (let ((file-name
	     (expand-file-name
	      (read-file-name "Write To File: "
			      bbdb-vcard-new-filename)))
	    (completion-ignore-case t))
	(setq bbdb-a-vcardsGen-output-buffer (find-file file-name))
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
	  (firstname (bbdb-record-firstname (car records)))
	  (lastname (bbdb-record-lastname (car records)))

	  (net (bbdb-record-net (car records)))
	  (primary-net (car net))
	  )
     (save-excursion 
       (set-buffer bbdb-a-vcardsGen-output-buffer)
       (goto-char (point-max))
       (if (null primary-net)
	   (progn
	     (message "Skiped name"))
	 (progn
	   (insert "begin:vcard
version:3.0
")
	   (insert (format "fn:%s\n" name))
	   (insert (format "email;type=internet:%s\n" primary-net))
	   (insert "end:vcard")
	   )))
     ))


(setq bbdb-action-alist 
  (append 
   bbdb-action-alist
   '(("vcards-mini-out-gen" 
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-vcardsMiniOutGen)
      ))))

(defun bbdb-a-vcardsOutAppend (records) 
  ""
  ;(interactive (list (if (bbdb-do-all-records-p)
  ;			 (mapcar 'car bbdb-records)
  ;		       (bbdb-current-record))))

  ;;(ding)

  (setq bbdb-vcard-dirname (concat bbdb-a-public-dir-name "/Vcards/"))
  (setq bbdb-vcard-new-filename (concat bbdb-vcard-dirname "new.vcf"))

  (if bbdb-action-isFirstRecord
      (let ((file-name
	     (expand-file-name
	      (read-file-name "Write To File: "
			      bbdb-vcard-new-filename			    
			      )))
	    (completion-ignore-case t))
	(setq bbdb-a-vcardsGen-output-buffer (find-file file-name))
	))

   (let* (
	  ;;(first-letter (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	  ;; raw fields
	  (name (bbdb-record-name (car records)))
	  (net (bbdb-record-net (car records)))
	  (primary-net (car net))
	  )
     (save-excursion 
       (set-buffer bbdb-a-vcardsGen-output-buffer)
       (if (null primary-net)
	   (progn
	     (message "Skiped name"))
	 (progn
	   (bbdb-vcard-export-record-insert-vcard (car records)))
	   ))
       (save-buffer)
       (kill-buffer bbdb-a-vcardsGen-output-buffer))
     )


;; (setq bbdb-action-alist nil)

(setq bbdb-action-alist 
  (append 
   bbdb-action-alist
   '(("vcards-out-append" 
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-vcardsOutAppend)
      ;(setq bbdb-action-isFirstRecord t)
      ))))

(defun bbdb-a-vcardsMiniOutAppend (records) 
  ""
  ;(interactive (list (if (bbdb-do-all-records-p)
  ;			 (mapcar 'car bbdb-records)
  ;		       (bbdb-current-record))))

  ;;(ding)

  (setq bbdb-vcard-dirname (concat bbdb-a-public-dir-name "/Vcards/"))
  (setq bbdb-vcard-new-filename (concat bbdb-vcard-dirname "new.vcf"))

  (if bbdb-action-isFirstRecord
      (let ((file-name
	     (expand-file-name
	      (read-file-name "Write To File: "
			      bbdb-vcard-new-filename			    
			      )))
	    (completion-ignore-case t))
	(setq bbdb-a-vcardsGen-output-buffer (find-file file-name))
	))

   (let* (
	  ;;(first-letter (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	  ;; raw fields
	  (name (bbdb-record-name (car records)))
	  (net (bbdb-record-net (car records)))
	  (primary-net (car net))
	  )
     (save-excursion 
       (set-buffer bbdb-a-vcardsGen-output-buffer)
       (goto-char (point-max))
       (if (null primary-net)
	   (progn
	     (message "Skiped name"))
	 (progn
	   (insert "begin:vcard
version:3.0
")
	   (insert (format "fn:%s\n" name))
	   (insert (format "email;type=internet:%s\n" primary-net))
	   (insert "end:vcard")
	   ))
       (save-buffer)
       (kill-buffer bbdb-a-vcardsGen-output-buffer))
     ))


;; (setq bbdb-action-alist nil)

(setq bbdb-action-alist 
  (append 
   bbdb-action-alist
   '(("vcards-mini-out-append" 
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-vcardsMiniOutAppend)
      ))))

(provide 'bbdb-vcard)


