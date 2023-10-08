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


(require 'bbdb-action-lib)


;;(shell-command "/usr/devenv/projs/colocation/Innovational/progressReport/envelopePrint-dave.sh")

(defun bbdb-a-bystarFactoryTest (records) 
  ""
   (let* (
	  (name (bbdb-record-name (car records)))
	  (firstname (bbdb-record-firstname (car records)))
	  (lastname (bbdb-record-lastname (car records)))

	  (net (bbdb-record-net (car records)))
	  (primary-net (car net))
	  )
     (save-excursion 
;       (if (null primary-net)
;	   (progn
;	     (message "Skiped name")))
	 (progn
	   (setq cmndLine (format
			   "sudo -u root /opt/public/osmt/bin/bystarBarcStart.sh -p serviceType=\"BYNAME\" -p supportType=\"TRIAL\"  -p FirstName=%s -p LastName=%s -p supportType=TRIAL -i startToFullFg\n"
			       firstname
			       lastname))

	   (ndmt-run-command cmndLine
			     (ndmt-host)
			     (ndmt-user)
			     (ndmt-password))

	   ;(shell-command cmndLine)
	   ))
     ))

;; (setq bbdb-action-alist nil)

(setq bbdb-action-alist 
  (append 
   bbdb-action-alist
   '(("bystar-factory-test" 
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'bbdb-a-bystarFactoryTest)
      ;(setq bbdb-action-isFirstRecord t)
      ))))

(provide 'bbdb-bystarFactory)



