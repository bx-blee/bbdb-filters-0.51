;;; This file is part of the BBDB Filters Package. BBDB Filters Package is a
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

;;; This is bbdb-group.el

;;; This file is a bbdb filter.  It converts passwd files to the
;;; canonical bbdb input filter format (i.e., a file of
;;; bif-create-record expressions


;;;(setq bbdb-a-public-dir-name "/usr/devenv/doc/nedaComRecs")

(setq bbdb-log-dir-name (concat bbdb-a-public-dir-name "/Logs/"))


(defun bbdb-log-msend (records content-name &optional content-specific-name from-addr) 
  ""

  ;;; NOTYET, Verify that directory path to file exists 
  (setq bbdb-log-filename (concat bbdb-log-dir-name "bbdb-msend.sent"))
  (setq bbdb-log-output-buffer (find-file bbdb-log-filename))
       

   (let* (
	  ;;(first-letter (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	  ;; raw fields
	  (name (bbdb-record-name (car records)))
	  (net (bbdb-record-net (car records)))
	  (primary-net (car net))
	  )
     (save-excursion 
       (set-buffer bbdb-log-output-buffer)
       (setq buffer-read-only nil)
       (goto-char (point-max))
       (setq time-stamp-format "%02y%02m%02d%02H%02M%02S")
       (if (null primary-net)
	   (progn
	     (insert (format "#"))
	     (message "Skiped name")))
       (insert (format "%s:%s:%s:%s:%s:%s:%s:%s\n" content-name name primary-net (time-stamp-string) content-specific-name from-addr (user-login-name) (system-name)))
	
       (save-buffer)
       (kill-buffer bbdb-log-output-buffer)
       )
     ))


(provide 'bbdb-log)


