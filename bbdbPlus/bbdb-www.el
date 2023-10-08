;;;From: boris@cs.rochester.edu
;;;To: Jon Konrath <jkonrath@bronze.ucs.indiana.edu>
;;;Cc: BBDB mailing list <info-bbdb@cs.uiuc.edu>
;;;Subject: re: bbdb-w3.el?
;;;Date: Wed, 31 Aug 1994 09:17:43 -0400
;;;Content-Type: text


;;;Jon Konrath asks:
;;;JK: Has anyone hacked a bbdb-w3.el yet?

;;;There's no such package that I know of, but the beginnings are there.
;;;Here's some code to play with:
;;;[I'm sure I don't have it all correctly attributed.  I'll just say
;;;that I wrote only some of the following.]

(add-hook 'w3-mode-hooks
	  '(lambda () (define-key w3-mode-map ":" 'bbdb-grab-www-homepage)))
(add-hook 'bbdb-load-hook 
	   '(lambda () (define-key bbdb-mode-map "W" 'bbdb-www)))

(defun bbdb-www (all)
  "Visit URL's stored in `www' fields of the current record.
\\[bbdb-apply-next-command-to-all-records]\\[bbdb-www] \
means to try all records currently visible.
Non-interactively, do all records if arg is nonnil."
  (interactive (list (bbdb-do-all-records-p)))
  (let ((urls (mapcar '(lambda (r) (bbdb-record-getprop r 'www))
		      (if all 
			  (mapcar 'car bbdb-records)
			(list (bbdb-current-record)))))
	(got-one nil))
    (while urls
      (if (car urls)
	  (w3-fetch (setq got-one (car urls))))
      (setq urls (cdr urls)))
    (if (not got-one)
	(error "No WWW field!"))))

(defun bbdb-grab-www-homepage (record)
  "Grab the current URL and store it in the bbdb database"
  (interactive (list (bbdb-completing-read-record "Add WWW homepage for: ")))
  (cond ((null record)
	 (setq record (bbdb-read-new-record))
	 (bbdb-invoke-hook 'bbdb-create-hook record))
	(t nil))
  (bbdb-record-putprop record 'www (w3-view-url t))
  (bbdb-change-record record t)
  (bbdb-display-records (list record)))

;;; From Fran Litterio <franl@centerline.com>
(defun fetch-url (url)
  "Causes a running Mosaic 2.x process to fetch the document at the URL (which
is the contents of the region for interactive invocations)."
  (interactive (list (buffer-substring (region-beginning) (region-end))))
  (let ((pid ""))
    (string-match "[ \t\n]*\\(.*[^ \t\n]\\)[ \t\n]*$" url)
    (setq url (substring url (match-beginning 1) (match-end 1)))
    (save-excursion
      (set-buffer (get-buffer-create " *Mosaic Control*"))
      (if (string= (buffer-name) " *Mosaic Control*")	; Paranoia!
	  (erase-buffer))
      (insert-file-contents "~/.mosaicpid")
      (setq pid (buffer-substring (point-min) (1- (point-max))))
      (erase-buffer)
      (insert (concat "newwin\n" url "\n"))
      (write-region (point-min) (point-max) (concat "/tmp/Mosaic." pid)
		    nil nil))
    (signal-process (string-to-number pid)
		    (cond
		     ((eq system-type 'hpux)
		      16)	; SIGUSR1 under HP-UX
		     ((eq system-type 'berkeley-unix)
		      30)))	; SIGUSR1 under SunOS 4.x
    (message (format "Told Mosaic to fetch \"%s\"" url))))



