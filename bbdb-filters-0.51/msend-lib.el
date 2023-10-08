;;;
;;;  (setq debug-on-error t)
;;;  (setq debug-on-error nil)
;;; (setq bbdb-action-alist nil)

;;; NOTYET, module localized defvars
;;msend-originator-envelope-addr
;;msend-originator-from-line
;;msend-originator-submit-ua-type -- one of "qmail", "sendmail", "smtpmail"

;;;
;;; Typical Machine Generated use of msend-attach
;;;
;
;(defun minc-@contentCategory@-@contentName@-@contentForm@ ()
;  "Send the @contentName@ in @contentForm@ format"
;  (interactive)
;
;  (msend-attach "@contentName@"
;                 "@contentForm@"
;                  (concat msend-contentBaseDir "/@contentCategory@/@contentName@/@contentFamily@/Src/@contentName@.@contentForm@"))
;

(setq msend-originator-from-line "unsetFromLine")

(defun msend-attach (contentName contentForm filePath)
  "msend-attach  "
  ;;(interactive)
  (let* (
	 (mimeContentType)
	 (formatName)
	 )
    (cond
     ((string-equal (downcase contentForm) "pdf")
      (setq mimeContentType "application/pdf")
      (setq formatName "pdf")
      )
     ((string-equal (downcase contentForm) "tty")
      (setq mimeContentType "application/octet-stream")
      (setq formatName "plain text")
      )
     ((string-equal (downcase contentForm) "html")
      (setq mimeContentType "text/html")
      (setq formatName "html")
      )
     (t
      (message "OOPS"))
     )

    (setq mm-content-transfer-encoding-defaults
      '(("text/x-patch" 8bit)
	("text/.*" qp-or-base64)
	("message/rfc822" 8bit)
	("application/emacs-lisp" 8bit)
	("application/x-patch" 8bit)
	("application/pdf" base64)
	(".*" qp-or-base64)))

  ;(mime-editor/insert-fpath filePath)
  (mml-attach-file filePath
		   mimeContentType
		   (format
		    "%s.%s attached as a %s file"
		    contentName contentForm formatName))
    ))

;;(msend-attach "WapTrap" "pdf" (concat msend-contentBaseDir "/Manifesto/WapTrap/doc/Src/WapTrap.pdf"))


;;; For Backwards Compatibility
;;;

(defun msend-headers-setup (from-line &optional envelop-addr)
  "msend- Set Up Headers"
  ;;(interactive)

  (let* (
	 (orig-from)
	 (orig-ua mail-user-agent)
	 (orig-default-headers message-default-headers)
	 (orig-send-mail-function message-send-mail-function)
	 (orig-qmail-inject-program message-qmail-inject-program)
	 (orig-qmail-inject-args message-qmail-inject-args)
	 )


    ;; For VM
    ;;(setq orig-from vm-mail-header-from)
    ;;(setq orig-fcc mail-archive-file-name)
    ;; For GNUS
    ;;(setq user-mail-address "mohsenGNus@neda.com")
    ;;(setq user-full-name "Mohsen GNUSBanan")


    (if (stringp envelop-addr)
	(progn
	  (setq message-send-mail-function 'message-send-mail-with-qmail)
	  (setq message-qmail-inject-program "/bin/env")
	  (setq message-qmail-inject-args
		(list
		 "-"
		 "QMAILINJECT=i"
		 "/var/qmail/bin/qmail-inject"
		 "-f"
		 ;;"office@mohsen.banan.1.byname.net"
		 (format "%s" envelop-addr)
		 ))
	  ))

    (setq message-default-headers
	  (format "From: %s\n" from-line))
    (setq message-default-headers (concat message-default-headers
					  (format "X-Envelope: %s\n" envelop-addr)))
    ;; (setq message-default-headers "Reply-To: Mohsen Banan <mohsen@neda.com>\n")

    (setq mail-user-agent 'message-user-agent)

    (compose-mail)

    ;;;
    ;;; After compose-mail ends restore everything back
    ;;; to what it was before
    ;;;

    ;;(setq mail-user-agent orig-ua)
    ;;(setq message-default-headers orig-default-headers)
    ;;(setq message-send-mail-function orig-send-mail-function)
    ;;(setq message-qmail-inject-program orig-qmail-inject-program)
    ;;(setq message-qmail-inject-args orig-qmail-inject-args)
    ))


;;(msend-originator-submit-ua-select "message-auto")
(defun msend-originator-submit-ua-select (submit-ua-desc)
  "Given a Submit User Agent Descriptor, select amongst available options
Descriptor has two components -- 1) emacs user agent, 2) OS inject program
Because it is a sparse matrix, we don't break it into the
two components and onlu alow selection of legit combinations.
Legit choices are:
   message-auto  (auto select - based on environment)
   message-sendmail
   message-qmail
   message-smtp  (for win environments?)
   vm-sendmail"
  ;;
  ;;(interactive)
  ;;
  (let* (
	 (qmail-inject-program "/var/qmail/bin/qmail-inject")
	 (env-program "/usr/bin/env")
	 )
    (cond
     ((string-equal (downcase submit-ua-desc) "message-auto")
      ;;
      ;; Policy: 
      ;;    1) In non unix environments, do not use native submission tools
      ;;       instead use elisp smtp implementation.
      ;;    2) In unix environments: qmail trumps sendmail
      ;; 
      
      (setq mail-user-agent 'message-user-agent)
		
      (cond
       ((eq system-type 'windows-nt)
	;; NOTYET, has not been tested
	(eoe-require 'smtpmail)

	;;(setq smtpmail-smtp-server "mail.bllvu1.wa.home.com")
	(setq smtpmail-default-smtp-server "mail.bllvu1.wa.home.com")
	(load-library "smtpmail")
	(load-library "message")

	;; For sending mail
	(setq message-send-mail-function 'smtpmail-send-it)
	)
       
       ((or (eq system-type 'usg-unix-v) (eq system-type 'linux))
	(if (file-exists-p qmail-inject-program)
	    (progn
	      ;; Goodie, This is the destination, rest is compromise
	      (setq message-send-mail-function 'message-send-mail-with-qmail)

	      ;; So that we can set env params for qmail-inject
	      (setq message-qmail-inject-program env-program)
	      
	      ;; no envelope addr explicitly specified 
	      ;; at this point
	      (setq message-qmail-inject-args
		    (list
		     "-"
		     "QMAILINJECT=i"
		     "/var/qmail/bin/qmail-inject"
		     ))
  	      )
	  (progn
	    (setq message-send-mail-function 'message-send-mail-with-sendmail)
	    ;; Hope that gnus defaults for sendmail options are good enough
	    )
	  )
	)
       (t
	(message "Unknown message-send-mail-function")
	(sleep-for 1)
	)
       )
      )
       
     ((string-equal (downcase submit-ua-desc) "message-qmail")
      (message "For now message-auto is as good as message-qmail")
      (sleep-for 1)
      )

     ((string-equal (downcase submit-ua-desc) "message-sendmail")
      (message "For now message-auto is as good as message-sendmail")
      (sleep-for 1)
      )
     (t
      (message "OOPS"))
     )
    )
  )


;;(msend-originator-envelope-addr "mohsen@neda.com")
(defun msend-originator-envelope-addr (envelope-addr)
  "Specify the originator address"
  ;;(interactive)
  ;; NOTYET, perhaps store for a later restore
  (if (stringp envelope-addr)
      (progn
	(setq msend-originator-envelope-addr envelope-addr)
	)
    (progn
      (message "Bad enevelope-addr")
      (ding)
      )))


;;(msend-originator-from-line "mohsen@neda.com")
;;(msend-originator-from-line 1)   -- bad test
(defun msend-originator-from-line (from-line)
  "Specify the From line"
  ;;(interactive)
  ;;(interactive)
  (if (stringp from-line)
      (progn
	(setq msend-originator-from-line from-line)
	)
    (progn
      (message "Bad from-line")
      (ding)
      )))


(defun msend-compose-setup ()
  "msend- Set Up Headers"
  ;;(interactive)

  ;; NOTYET, verify that submit ua was already set.
  ;;

  ;;(setq message-default-headers "")
	      
  (cond
   ((eq  message-send-mail-function 'message-send-mail-with-qmail)
    ;; Envelope Address Settings
    ;;
    (setq message-qmail-inject-args
	  (list
	   "-"
	   "QMAILINJECT=i"
	   "/var/qmail/bin/qmail-inject"
	   "-f"
	   (format "%s" msend-originator-envelope-addr)
	   ))

    (setq message-default-headers
	  (concat message-default-headers
		  (format "X-Envelope: %s\n" msend-originator-envelope-addr)))

    )

   ((eq  message-send-mail-function 'message-send-mail-with-sendmail)
    (message "Envelope Address Setting Not Supported with sendmail")
    (sleep-for 1)
    )
   (t
    (message "OOPS")
     )
   )

  (setq message-default-headers
	(concat message-default-headers
		(format "From: %s\n" msend-originator-from-line)))

  )




(defun msend-mail-and-exit ()
  "msend- Set Up Headers"
  ;;(interactive)

  (let* (
	 (orig-kill-buffer-on-exit message-kill-buffer-on-exit)
	 )
    (setq message-kill-buffer-on-exit (not nil))
    (message-send-and-exit)

    ;; Here is where the restore functions should be called

    (setq message-kill-buffer-on-exit orig-kill-buffer-on-exit)

    ))


(provide 'msend-lib)

