

(defvar bno-file-name "~/.netscape/address-book.bbdb.html"
  "Output file name for `bbdb-output-nsmail' command.")


(defun bbdb-output-nsmail (to-file)
  "Output the selected BBDB entries to TO-FILE."
  (interactive (list (setq bno-file-name (expand-file-name
					  (read-file-name "Output To File: "
							  (file-name-directory bno-file-name)
							  bno-file-name
							  nil
							  (file-name-nondirectory bno-file-name))))))
  (let ((current-letter "")
	(nsmail-count 0)
	(records (progn (set-buffer bbdb-buffer-name)
			bbdb-records)))
    
    ;;
    ;; prelude
    ;;

    ;; setup the output buffer
    (find-file bno-file-name)
    (delete-region (point-min) (point-max))
    
    ;; preamble
    (insert "<!DOCTYPE NETSCAPE-Addressbook-file-1>
<!-- This is an automatically generated file. It will be read and overwritten. Do Not Edit! -->
<TITLE>auto-generated BBDB->Netscape Mail Address book</TITLE>
<H1>BBDB->Netscape Mail Address book</H1>

<DL><p>
")

    ;;
    ;; process the bbdb-records
    ;; 
    (while records
      (setq current-letter (bno-nsmail-format-record (car (car records)) current-letter))
      (setq records (cdr records)))
    ;; no more records, so...
    (bno-finish-old-letter current-letter)

    ;;
    ;; postlude
    ;; 

    ;; postamble
    (goto-char (point-max))
    (insert "</DL><p>")
    (goto-char (point-min))
    (message "Done.  %d records processed." nsmail-count)

    ;; write out the file
    (save-buffer) 
    ))


;;; -------------------------------------------------------------------
;;; Helper functions
;;; -------------------------------------------------------------------

(defun bno-start-new-letter (new-letter)
  (message "Now processing \"%s\" entries..." new-letter))


(defun bno-finish-old-letter (old-letter)
  (cond ((string-equal old-letter "") nil) ; nothing to do 
	(t (message "Done processing \"%s\" entries..." current-letter))))


(defun bno-nsmail-format-record (record current-letter) 
  "Insert the bbdb RECORD in Netscape Mail address book format.
CURRENT-LETTER is the section we're in.  If the first letter of the
sortkey of the record differs from it, a new section heading will be
output.  The new current-letter is the return value of this function."

  (let* ((first-letter (upcase (substring (concat (bbdb-record-sortkey record) "?") 0 1)))
	 (name (bbdb-record-name record))
	 (net (bbdb-record-net record))
	 (net-addr (car net))
	 (phones (bbdb-record-phones record))
	 (addrs (bbdb-record-addresses record))
	 (raw-notes (bbdb-record-raw-notes record))
	 )

    (if (and name net)			; maybe process this record..
	(progn

	  (if (not (string-equal first-letter current-letter))
	      (progn 
		;;
		;; handle change of letter
		;; 
		(bno-finish-old-letter current-letter)
		(bno-start-new-letter first-letter)))

	  ;; 
	  ;; now process the record
	  ;; 
	  (setq nsmail-count (+ nsmail-count 1))
	  (insert (format "<DT><A HREF=\"mailto:%s\">%s</A>\n" net-addr name))
	  (insert (format "<DD>\n"))
	  (mapcar '(lambda (phone-rec)
		     (insert (format "Phone: %s\n" phone-rec)))
		  phones)
	  (mapcar '(lambda (addr-rec)
		     (insert (format "Address: %s\n" addr-rec)))
		  addrs)
	  (if (and raw-notes
		   (not (consp raw-notes)))
	      (setq raw-notes (list raw-notes)))
	  (mapcar '(lambda (note-rec)
		     (insert (format "Note: %s\n" note-rec)))
		  raw-notes)

	  (setq current-letter first-letter)
	  ))

    ;; return current letter
    current-letter))



(provide 'bbdb-nsmail)

