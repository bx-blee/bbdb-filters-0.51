;;;(setq lisp-indent-offset 2)
;;;
;;; Time-stamp: "November 08, 2000"
;;;  (setq debug-on-error nil)
;;; (setq debug-on-error t)
;;; Variables
;;;

(defun bbdb-tex-memo-address (records)
  ""
   (let ( ns )

     (setq bbdb-current-address nil)
       (setq ns (bbdb-record-get-addressfield-string (car records) 'address-location))
       ;;(insert (format "%s\n" ns))

       (setq ns (bbdb-record-get-addressfield-string (car records) 'address-street1))
       (if ns (insert (format "%s\\\\\n" ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-street2))
      (if ns (insert (format "%s\\\\\n" ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-city))
      (if ns (insert (format "%s, " ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-state))
      (if ns (insert (format "%s   " ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-zip-string))
      (if ns (insert (format "%s\\\\\n" ns)))
      ))

(defun bbdb-tex-memo-address-withZipBar (records)
  ""
   (let ( ns )

     (setq bbdb-current-address nil)
       (setq ns (bbdb-record-get-addressfield-string (car records) 'address-location))
       ;;(insert (format "%s\n" ns))

       (setq ns (bbdb-record-get-addressfield-string (car records) 'address-street1))
       (if ns (insert (format "%s\\\\\n" ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-street2))
      (if ns (insert (format "%s\\\\\n" ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-city))
      (if ns (insert (format "%s, " ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-state))
      (if ns (insert (format "%s   " ns)))

      (setq ns (bbdb-record-get-addressfield-string (car records) 'address-zip-string))
      (if ns (insert (format "\\zipbar{%s}" ns)))

      ))

(defun bbdb-tex-memo-phone (records)
  ""
   (let ( ns )

     (setq bbdb-current-phone nil)

     (setq ns (bbdb-record-get-phonefield-string (car records) 'phone-location))
     ;;(insert (format "%s\n" ns))

     (setq ns (bbdb-record-get-phonefield-string (car records) 'phone-string))
     ;;(if ns (insert (format "%s\n" ns)))
     (if ns (insert (format "%s" ns)))
     (format "%s" ns)
     ))


(defun bbdb-record-get-addressfield-string (record field)
  (funcall
   ;; do not return the empty string !
   (function (lambda (string) (if (and (stringp string) (string= string ""))
				  nil
				string)))
  (let* ((addrs (bbdb-record-addresses record))
	 (addrs-alist (mapcar (function (lambda (a)
					  (cons (bbdb-address-location a) a)))
			      addrs))
	 (completion-ignore-case t))
    (if (not addrs)
	;; return nil if there is no address
	nil
      (cond (bbdb-current-address nil)
	    ;; ... else
	    ;; if there is only one address ... grab it
	    ((= (length addrs) 1)
	     (setq bbdb-current-address (car addrs)))
	    ;; ... else
	    ;; try to find bbdb-letter-address-default address
	    ((and bbdb-letter-address-default
		  (assoc bbdb-letter-address-default addrs-alist))
	     (while addrs
	       (cond ((equal bbdb-letter-address-default 
			     (bbdb-address-location (car addrs)))
		      (setq bbdb-current-address (car addrs))
		      (setq addrs nil))
		     (t (setq addrs (cdr addrs))))))
	    ;; ... else
	    ;; if nothing was found, ask user
	    (t (setq bbdb-current-address
		     (cdr (assoc (completing-read
				  (format "Which Address of %s: "
					  (bbdb-record-name record))
				  addrs-alist nil t)
				 addrs-alist)))) )
      ;; ... now, return the field info ...
      (cond ((eq field 'address-location)
	     (bbdb-address-location bbdb-current-address))
	    ((eq field 'address-street1)
	     ;;(bbdb-address-street1 bbdb-current-address))
	     ;; NOTYET, this gives you just one line , not all the lines
	     (car (bbdb-address-streets bbdb-current-address)))
;	    ((eq field 'address-street2)
;	     (bbdb-address-street2 bbdb-current-address))
;	    ((eq field 'address-street3)
;	     (bbdb-address-street3 bbdb-current-address))
	    ((eq field 'address-city)
	     (bbdb-address-city bbdb-current-address))
	    ((eq field 'address-state)
	     (bbdb-address-state bbdb-current-address))
	    ((eq field 'address-zip-string)
	     (bbdb-address-zip-string bbdb-current-address))))
    )))

(defun bbdb-record-get-phonefield-string (record field)
  (funcall
   ;; do not return the empty string !
   (function (lambda (string) (if (and (stringp string) (string= string ""))
				  nil
				string)))
  (let* ((phones (bbdb-record-phones record))
	 (phns-alist (mapcar (function (lambda (p)
					 (cons (bbdb-phone-location p) p)))
			     phones))
	 (completion-ignore-case t))
    (if (not phones)
	;; return nil if there is no phones
	nil
      (cond (bbdb-current-phone nil)
	    ;; ... else
	    ;; if there is only one phone ... grab it
	    ((= (length phones) 1)
	     (setq bbdb-current-phone (car phones)))
	    ;; ... else
	    ;; try to find bbdb-letter-phone-default phone
	    ((and bbdb-letter-phone-default
		  (assoc bbdb-letter-phone-default phns-alist))
	     (while phones
	       (cond ((equal bbdb-letter-phone-default 
			     (bbdb-phone-location (car phones)))
		      (setq bbdb-current-phone (car phones))
		      (setq phones nil))
		     (t (setq phones (cdr phones))))))
	    ;; ... else
	    ;; if nothing was found, ask user
	    (t (setq bbdb-current-phone
		     (cdr (assoc (completing-read
				  (format "Which Phone/Fax of %s: "
					  (bbdb-record-name record))
				  phns-alist nil t)
				 phns-alist)))) )
      ;; ... now, return the field info ...
      (cond ((eq field 'phone-location)
	     (bbdb-phone-location bbdb-current-phone))
	    ((eq field 'phone-string)
	     (bbdb-phone-string bbdb-current-phone))))
    )))
  