;;; This is bbdb-action-extension.el.
;;;
;;; The Insidious Big Brother Database is free software; you can redistribute
;;; it and/or modify it under the terms of the GNU General Public License as
;;; published by the Free Software Foundation; either version 1, or (at your
;;; option) any later version.
;;;
;;; BBDB is distributed in the hope that it will be useful, but WITHOUT ANY
;;; WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
;;; FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
;;; details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;;;
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; ToDo:
;;;
;;;for debugging ...
;;;(insert (apply 'concat (bbdb-format myrecord mystringlist nil 'latex)))
;;;(bbdb-record-get-field-internal-2 (bbdb-current-record) 'name)
;;;(("project") ("title") ("alias") ("country") ("telex") ("tex-name"))
;;;(setq myrecord (bbdb-current-record))

(require 'bbdb)
(require 'bbdb-com)

(define-key bbdb-mode-map "x" 'bbdb-action-extension)


;;;
;;; Variables
;;;

(setq bbdb-action-isFirstRecord t)

(defvar bbdb-action-hook nil
  "*Hook or hooks invoked (with no arguments) when the name of 
   the letter-file is needed")


(defvar bbdb-action-alist
      '(("some action" 
	 ;;
	 (setq bbdb-action-hook nil)
	 (add-hook 'bbdb-action-hook 'a-example-output)
	))
      "*Alist defining action types for bbdb-letter.

Any pair of bbdb-action-alist consists of a string denoting the
action type and a number of elisp expressions. 

Customization usually extends bbdb-action-alist as follows:
(setq bbdb-action-alist
      (append bbdb-action-alist
	      '((\"myown action\" 
		 ;;
		 (setq bbdb-a-param
		       '(\"\\something ...
			 ... ))))))")



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun bbdb-action-extension (bbdb-record)
  "Apply an action to selected BBDB entries.
The first (most-recently-added) address is used if there are more than one.
\\<bbdb-mode-map>
If \"\\[bbdb-apply-next-command-to-all-records]\", then letters are created \
to all of the
folks listed in the *BBDB* buffer instead of just the person at point."
  (interactive (list (if (bbdb-do-all-records-p)
			 (mapcar 'car bbdb-records)
		       (bbdb-current-record))))
  (progn 
    (mapcar 'eval
	    (cdr (assoc (completing-read "Action To Apply: "
					 bbdb-action-alist
					 nil t)
			bbdb-action-alist)))

      (if (consp bbdb-record)
	  (bbdb-action-many bbdb-record)
	(bbdb-action-one bbdb-record))))



(defun bbdb-action-one (bbdb-record)    

  (cond ((null bbdb-record) (error "record unexists"))
;	((null (bbdb-record-addresses bbdb-record))
;	 (error "Current record unhas addresses."))
	
	;(t (run-hook-with-args 'bbdb-action-hook bbdb-record))))
	(t
	 (setq bbdb-action-isFirstRecord t)
	 (setq bbdb-action-lastRecord bbdb-record)
	     
	 (run-hook-with-args 'bbdb-action-hook (list bbdb-record)))))

	  

(defun bbdb-action-many (bbdb-records)

    ;;(message (format "%d" (length bbdb-records)))
    ;;(sleep-for 2)

    (setq bbdb-action-isFirstRecord t)

    (setq bbdb-action-lastRecord (nth (- (length bbdb-records) 1) bbdb-records))

    (let (
	  (records bbdb-records)
	  )

      (while records
	(save-excursion 
	  (run-hook-with-args 'bbdb-action-hook records)
	  )

	(if bbdb-action-isFirstRecord
	    (setq bbdb-action-isFirstRecord nil))

	(setq records (cdr records))
	)
      )
    )


(defun bbdb-action-isLastRecord (records) 
  ""
  (if (equal bbdb-action-lastRecord  (car records))
      (not nil)
    nil))


(provide 'bbdb-action)


