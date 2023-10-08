;;;From: tromey@busco.lanl.gov (Tom Tromey)
;;;To: Emmett Hogan <hogan@radiomail.net>
;;;Cc: supercite@anthem.nlm.nih.gov, info-bbdb@cs.uiuc.edu
;;;Subject: Re: BBDB and SUPERCITE
;;;Date: Wed, 27 Jul 94 12:00:52 MDT
;;;Content-Type: text

;;;Here is the code I use to get supercite attributions from BBDB.  The
;;;BBDB field is called "attribution".

(setq sc-preferred-attribution-list '("sc-lastchoice" "x-attribution"
				      "bbdb-attribution" "firstname"
				      "initials" "lastname"))
(add-hook 'sc-attribs-preselect-hook 'bbdb/supercite)

(defun bbdb/supercite ()
  "Extract citing information from BBDB."
  (let ((from (sc-mail-field "from"))
	attr
	record)
    (if (or (null from)
	    (string-match (bbdb-user-mail-names)
			  ;; mail-strip-quoted-names is too broken!
			  ;;(mail-strip-quoted-names from)
			  (car (cdr (mail-extract-address-components
				     from)))))
	;; if logged in user sent this, use recipients.
	(setq from (or (sc-mail-field "to") from)))
    (if from
	(setq record (bbdb-annotate-message-sender from t nil nil)))
    (setq attr (and record
		    (bbdb-record-getprop record 'attribution)))
    (and attr
	 (setq sc-attributions
	       (cons (cons "bbdb-attribution" attr) sc-attributions)))))

;;;Tom
;;;---
;;;tromey@busco.lanl.gov             Member, League for Programming Freedom


