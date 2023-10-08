;;;From: Sridhar Anandakrishnan <sak@essc.psu.edu>
;;;To: bbdb mailing list <info-bbdb@lucid.com>
;;;Subject: appending new entries to existing ones...
;;;Date: Fri, 20 May 94 12:02:03 EDT
;;;Content-Type: text


;;;Thanks to the following for their quick reply to my question:

;;;Alastair Burt <burt@dfki.uni-kl.de>, Rick Busdiecker <rfb@lehman.com>

;;;I asked:
;;; > WHen I want to send mail to a lot of people, I would like to use BBDB to
;;; > get them all into the *BBDB* buffer, then say "*m" to mail to all.  But
;;; > if I search for a new name, the one already there goes away.

;;; > How do I "build up a list" of people in bbdb?

;;;And here is the answer (add to .emacs):

(setq bbdb-mode-hook
      '(lambda ()
	 (define-key bbdb-mode-map "c" 'bbdb-create)
	 (define-key bbdb-mode-map "b" 'bbdb)
	 (define-key bbdb-mode-map "a" 'bbdb-append)))

(defun bbdb-append (string elidep)
  "Append all entries in the BBDB matching the regexp STRING 
 in either the name(s), company, network address, or notes."
  (interactive "sRegular Expression: \nP")
  (let ((bbdb-elided-display (bbdb-grovel-elide-arg elidep))
	(notes (cons '* string))
	(bbdb-append t))
    (bbdb-display-records-1
     (bbdb-search (bbdb-records) string string string notes nil) bbdb-append)))

(defun bbdb-append-name (string elidep)
  "Append all entries in the BBDB matching the regexp STRING in the name
\(or ``alternate'' names\)."
  (interactive "sRegular Expression: \nP")
  ;(let ((bbdb-elided-display (bbdb-grovel-elide-arg elidep)))
  ; (bbdb-display-records (bbdb-search (bbdb-records) string))))
 
 (let ((bbdb-elided-display (bbdb-grovel-elide-arg elidep))
	(notes (cons '* string))
	(bbdb-append t))
    (bbdb-display-records-1
     (bbdb-search (bbdb-records) string) bbdb-append)))



;;;Cheers, Sridhar.
