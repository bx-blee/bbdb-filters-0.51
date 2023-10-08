;;; This is bbdb-letter.el, version 0.96.
;;; It was partly derived from bbdb-print.el, version 2.3.
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
;;;
;;; This module is for creating formatted excerpts of BBDB databases.
;;; It can be used to create letter templates or address/phone lists
;;; with LaTeX/TeX. It might also be used to create, e.g., import
;;; files for a EXCEL(tm) database. 
;;;
;;; USE:  In the *BBDB* buffer, type l or *l to create a template of
;;;       the current bbdb-record or of all the currently displayed
;;;       records using the format (usually LaTeX/TeX) it will prompt
;;;       for. It will prompt you for a filename and for
;;;       a format (type of document).  Then run LaTeX/TeX (or an
;;;       appropriate processor) on that file and
;;;       print it out.
;;;
;;;       In order to use bbdb-letter for personal purposes, it is
;;;       very likely that you will need to define your own document
;;;       types/formats.
;;;
;;;       Please direct any comments, improvements, or bug reports to
;;;       jws@forwiss.uni-erlangen.de. I would also be happy to
;;;       integrate new document types/formats.
;;;
;;; INSTALLATION: Put this file somewhere on your load-path.
;;;       Put (require 'bbdb-letter) in your .emacs, or autoload it.
;;;       Put bbdb-print.tex (from bbdb-print) somewhere on your
;;;          TEXINPUTS path, or put its absolute pathname in
;;;          bbdb-print-format-file-name.
;;;
;;;       In order to use the "phone list" format, you will need the
;;;       supertab.sty LaTeX style. This can be obtained, e.g., by
;;;       mail from FILESERV@SHSU.edu (put the line "SENDME STY.SUPERTAB"
;;;       into the meassage) an put supertab.sty on your TEXINPUTS
;;;       path.
;;;
;;; DEFINITION OF DOCUMENT TYPES/FORMATS: New document types for
;;;       bbdb-letter are defined by extending or redefining the variable
;;;       bbdb-letter-alist.
;;;
;;;       Any pair of bbdb-letter-alist consists of a string denoting
;;;       the document type and a number of elisp expressions. The
;;;       elisp expressions should assign (setq ...) values to the
;;;       variables bbdb-print-prolog, bbdb-print-separator,
;;;       bbdb-print-record, bbdb-print-epilog, and
;;;       bbdb-print-address-default.
;;;
;;;       Customization usually extends bbdb-letter-alist as follows:
;;;       (setq bbdb-letter-alist
;;;             (append bbdb-letter-alist
;;;       	      '((\"myown letter\" 
;;;       		 ;;
;;;       		 (setq bbdb-letter-prolog
;;;       		       '(\"\\documentstyle ...
;;;       			 ... ))))))")
;;; VARIABLES:
;;;       bbdb-letter-prolog
;;;           A list of strings forming the beginning of the LaTeX/TeX
;;;           document.
;;;       bbdb-letter-separator
;;;           A string which is passed to format to produce a
;;;           separator, when the first character changes.
;;;           bbdb-letter-separator may also have the value nil.
;;;       bbdb-letter-epilog
;;;           A list of strings forming the end of the LaTeX/TeX.
;;;           document.
;;;       bbdb-letter-address-default
;;;           String denoting the default address location.
;;;       bbdb-letter-phone-default
;;;           String denoting the default phone location.
;;;       bbdb-letter-record
;;;           This is a list consisting of strings, bbdb-keywords,
;;;           lists, (bball ...) or (bbif ...) exprs.
;;;
;;;           NOTE: An expression (bbif condition ifbranch elsebranch)
;;;           or (bball ...) is NOT a regular elisp expression! It can
;;;           not be evaluated! It is simply a data structure or macro
;;;           which will be expanded later.
;;;
;;;           If an element of the list bbdb-letter-record is a
;;;           string: This string is copied to the output document
;;;                   (escape characters "\" for elisp strings are
;;;                   necessary)
;;;           bbdb-keyword: this is interpreted as a bbdb keyword. It
;;;                   is a symbol and it may be one out of
;;;                    ('name 'firstname 'lastname 'company 'aka 'net
;;;                     'notes 'addresses 'address-location 'address-street1
;;;                     'address-street2 'address-street3 'address-city
;;;                     'address-state 'address-zip-string 'phone-location
;;;                     'phone-string 'phones)
;;;                   or a user defined keyword of a bbdb record (see
;;;                   bbdb-propnames for user defined keywords).
;;;           bbif:   has the form
;;;                     (bbif 'bbdb-keyword if-part else-part)
;;;                   where if-part and else-part again is a string,
;;;                   bbdb-keyword, list, (bball ...) or (bbif ...) expr.
;;;           bball:  has the form
;;;                     (bball addresses-or-phones separator)
;;;                   where addresses-or-phones is one of
;;;                   ('addresses 'phones)
;;;                   and separator again is a string,
;;;                   bbdb-keyword, list, (bball ...) or (bbif ...) expr.
;;;           list:   This is only for grouping. Any element of the list
;;;                   is a string, bbdb-keyword, list, (bball ...) or
;;;                   (bbif ...) expr.
;;;
;;; EXAMPLE:
;;;  see also (defvar bbdb-letter-alist ...) below.
;;;
;;;  (setq bbdb-letter-alist
;;;        (append bbdb-letter-alist
;;;  	      '(("my own letter" 
;;;  		 ;;
;;;  		 (setq bbdb-letter-prolog
;;;  		       '("\\documentstyle[11pt]{myletter}\n"
;;;  			 "\\germanletter\n"
;;;  			 "\\dvips        % Driver-Selection\n"
;;;  			 "% --- Signature\n"
;;;  			 "\\name{\\vspace{2cm}(Steven Spielberg)}\n"
;;;  			 "\\aktzei{}\n"
;;;  			 "\\begin{document}\n\n"))
;;;  		 ;;
;;;  		 (setq bbdb-letter-separator "\\separator{%s}\n\n")
;;;  		 ;;
;;;  		 (setq bbdb-letter-record
;;;  		       '("\\begin{letter}{" 
;;;  			 (bbif title title "Mr") " "
;;;                      ;; well, this requires that you have a user defined
;;;                      ;; field called tex-name ...
;;;  			 (bbif tex-name tex-name (bbif name name)) " \\\\"
;;;  			 (bbif company (company " \\\\"))
;;;  			 (bbif address-street1 (address-street1 " \\\\"))
;;;  			 (bbif address-street2 (address-street2 " \\\\"))
;;;  			 (bbif address-street3 (address-street3 " \\\\"))
;;;  			 "[1ex]\n" "{\\bf "
;;;  			 address-zip-string " " address-city "}}\n"
;;;  			 "\\opening{Dear Mr.\ "
;;;  			 lastname ",}\n"
;;;  			 "\\sloppy\n"
;;;  			 "%****************** BEGIN TEXT ******************\n\n"
;;;  			 "%******************   END TEXT ******************\n"
;;;  			 "\\closing{Sincerely yours}\n"
;;;  			 "%\\cop{}\n"
;;;  			 "%\\encl{}\n"
;;;  			 "\\end{letter}\n\n"))
;;;  		 ;;
;;;  		 (setq bbdb-letter-epilog '("\\end{document}\n"))
;;;  		 ;;
;;;  		 (setq bbdb-letter-address-default "office"))
;;;  		)))
;;;
;;; This program was written by Josef Schneeberger
;;; <jws@forwiss.uni-erlangen.de>. The code is based on the bbdb-print
;;; (version 2.3) program of Boris Goldowsky
;;; <boris@psych.rochester.edu> and Dirk Grunwald
;;; <grunwald@cs.colorado.edu> using a TeX format from Luigi Semenzato
;;; <luigi@paris.cs.berkeley.edu>. Thanks to Boris Goldowsky
;;; <boris@psych.rochester.edu>, Tim Geisler
;;; <tmgeisle@faui80.informatik.uni-erlangen.de> and
;;; franz@neuro.informatik.uni-ulm.de (Franz Kurfess) for comments and
;;; bug reports.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; ToDo:
;;; 1. Documentation strings for all variables and function definition
;;; 2. insert quotation feature of bbdb-print.el. I think the best variant
;;;    would be to introduce a new keword "bbquote" (like "bball" or "bbif")
;;; 3. "<lastname>.tex" as default-filename
;;; 4. Default for Documenttype
;;; 5. texinfo file (integrated into the bbdb documentation)
;;;
;;;for debugging ...
;;;(insert (apply 'concat (bbdb-format myrecord mystringlist nil 'latex)))
;;;(bbdb-record-get-field-internal-2 (bbdb-current-record) 'name)
;;;(("project") ("title") ("alias") ("country") ("telex") ("tex-name"))
;;;(setq myrecord (bbdb-current-record))

(require 'bbdb)
(require 'bbdb-com)

(define-key bbdb-mode-map "l" 'bbdb-compose-letter)

;;;
;;; Variables
;;;

(defvar bbdb-letter-file-name "bbdb.tex"
  "*Default file name for printouts of BBDB database.")

(defvar bbdb-letter-directory-name "~/"
  "*Default directory for printouts of BBDB database.")

(defvar bbdb-letter-address-default nil
  "*String denoting the default address location.")

(defvar bbdb-letter-phone-default nil
  "*String denoting the default phone location.")

(defvar bbdb-letter-prolog nil
  "*A list of strings forming the beginning of the LaTeX/TeX document.")

(defvar bbdb-letter-separator nil
  "*A string which is passed to format to produce a separator, when
the first character changes.

bbdb-letter-separator may also have the value nil.")

(defvar bbdb-letter-record nil
  "*This is a list consisting of strings, bbdb-keywords, lists,
(bball ...) or (bbif ...) exprs.

See documentation for more details.")

(defvar bbdb-letter-epilog nil
  "*A list of strings forming the end of the LaTeX/TeX document.")

(defvar bbdb-letter-alist
      '(("LaTeX letter" 
	 ;;
	 (setq bbdb-letter-prolog 
	       '("\\documentstyle{letter}\n"
		"\\name{Dr. L. User}\n"
		"\\signature{Larry User}\n"
		"\\address{3245 Foo St.\\\\Gnu York}\n"
		"\\location{Room 374}\n"
		"\\telephone{(415)123-4567}\n"
		"% \\makelabels\n"
		"\\begin{document}\n\n"))
	 ;;
	 (setq bbdb-letter-separator "")
	 ;;
	 (setq bbdb-letter-record
	       '("\\begin{letter}{Mr. " 
		(bbif tex-name tex-name (bbif name name)) " \\\\"
		(bbif company (company " \\\\"))
		(bbif address-street1 (address-street1 " \\\\"))
		(bbif address-street2 (address-street2 " \\\\"))
		(bbif address-street3 (address-street3 " \\\\"))
		"[1ex]\n" "{\\bf "
		address-city ", " address-zip-string "}}\n"
		"\\opening{Dear "
		firstname ",}\n"
		"\\sloppy\n"
		"%****************** Start TEXT ******************\n\n"
		"%******************  End  TEXT ******************\n"
		"\\closing{ Yours truly,}\n"
		"%\\cop{}\n"
		"%\\encl{}\n"
		"\\end{letter}\n\n"))
	 ;;
	 (setq bbdb-letter-epilog '("\\end{document}\n"))
	 ;;
	 (setq bbdb-letter-address-default nil))   ; if nil, no default
	("A4 LaTeX letter" 
	 ;;
	 (setq bbdb-letter-prolog 
	       '("\\documentstyle{a4letter}\n"
		"\\name{Dr. L. User}\n"
		"\\signature{Larry User}\n"
		"\\address{3245 Foo St.\\\\Gnu York}\n"
		"\\location{Room 374}\n"
		"\\telephone{(415)123-4567}\n"
		"% \\makelabels\n"
		"\\begin{document}\n\n"))
	 ;;
	 (setq bbdb-letter-separator "")
	 ;;
	 (setq bbdb-letter-record
	       '("\\begin{letter}{Mr. " 
		(bbif tex-name tex-name (bbif name name)) " \\\\"
		(bbif company (company " \\\\"))
		(bbif address-street1 (address-street1 " \\\\"))
		(bbif address-street2 (address-street2 " \\\\"))
		(bbif address-street3 (address-street3 " \\\\"))
		"[1ex]\n" "{\\bf "
		address-city ", " address-zip-string "}}\n"
		"\\opening{Dear "
		firstname ",}\n"
		"\\sloppy\n"
		"%****************** Start TEXT ******************\n\n"
		"%******************  End  TEXT ******************\n"
		"\\closing{ Yours truly,}\n"
		"%\\cop{}\n"
		"%\\encl{}\n"
		"\\end{letter}\n\n"))
	 ;;
	 (setq bbdb-letter-epilog '("\\end{document}\n"))
	 ;;
	 (setq bbdb-letter-address-default nil))   ; if nil, no default
	("LaTeX multiple letter" 
	 ;;
	 (setq bbdb-letter-prolog 
	       '("\\documentstyle{letter}\n"
		 "\\name{Dr. L. User}\n"
		 "\\signature{Larry User}\n"
		 "\\address{3245 Foo St.\\\\Gnu York}\n"
		 "\\location{Room 374}\n"
		 "\\telephone{(415)123-4567}\n"
		 "% \\makelabels\n"
		 "\\newcommand{\\MYLETTER}[2]{"
		 "\\begin{letter}{#1}" 
		 "\\opening{#2}\n"
		 "  \\sloppy\n"
		 "  %****************** Start TEXT ******************\n\n"
		 "  %******************  End  TEXT ******************\n"
		 "  \\closing{ Yours truly,}\n"
		 "  %\\cop{}\n"
		 "  %\\encl{}\n"
		 "  \\end{letter}}\n\n"
		 "\\begin{document}\n\n"))
	 ;;
	 (setq bbdb-letter-separator nil)
	 ;;
	 (setq bbdb-letter-record
	       '("\\MYLETTER{Mr. "
		 (bbif tex-name tex-name (bbif name name)) " \\\\"
		 (bbif company (company " \\\\"))
		 (bbif address-street1 (address-street1 " \\\\"))
		 (bbif address-street2 (address-street2 " \\\\"))
		 (bbif address-street3 (address-street3 " \\\\"))
		 "[1ex] " "{\\bf "
		 address-city ", " address-zip-string
		 "}}{Dear " firstname ",}\n\n"))
	 ;;
	 (setq bbdb-letter-epilog '("\\end{document}\n"))
	 ;;
	 (setq bbdb-letter-address-default nil))   ; if nil, no default
	("phone list" 
	 ;;
	 (setq bbdb-letter-prolog '("\\documentstyle[supertab]{article}\n"
				   "\\begin{document}\n\n"
				   "\\begin{supertabular}{|ll|r|}\n"))
	 ;;
	 (setq bbdb-letter-separator
	       "\\hline\n\\multicolumn{3}{|c|}{\\bf %s}\\\\\n\\hline\n")
	 ;;
	 (setq bbdb-letter-record
	       '(lastname ", & " firstname " & " phone-string " \\\\\n"))
	 ;;
	 (setq bbdb-letter-epilog '("\\hline\n"
				   "\\end{supertabular}\n"
				   "\\end{document}\n"))
	 ;;
	 (setq bbdb-letter-address-default nil))
	("address booklet" 
	 ;;
	 (setq bbdb-letter-prolog '("\\documentstyle{article}\n"
				   "\\setlength{\\parindent}{0pt}\n"
				   "\\setlength{\\textheight}{16cm}\n"
				   "\\begin{document}\n"
				   "\\small\n"))
	 ;;
	 (setq bbdb-letter-separator "\\newpage\n")
	 ;;
	 (setq bbdb-letter-record
	       '("\\parbox[t]{6cm}{"
		 "\\underline{" firstname " " lastname "} \\\\"
		 (bbif company (company " \\\\[1ex]\n") "[1ex]\n")
		 "\\hspace*{2mm}\\begin{tabular}[t]{p{60mm}}\n"
		 (bball addresses
			("{\\it " address-location "}\\\\\n"
			 (bbif address-street1 (address-street1 " \\\\"))
			 (bbif address-street2 (address-street2 " \\\\"))
			 (bbif address-street3 (address-street3 " \\\\"))
			 " {\\bf " address-zip-string " " address-city
			 "}\\\\[1ex]"))
		 "  \\end{tabular}}\n"
		 "\\hspace{-2cm}\n"
		 "\\parbox[t]{5cm}{\\hfill\n"
		 "  \\begin{tabular}[t]{r}\n"
		 (bball phones
			(phone-location ": " phone-string " \\\\"))
		 "  \\end{tabular}}\\\\[2ex]\n"))
	 ;;
	 (setq bbdb-letter-epilog '("\\end{document}\n"))
	 ;;
	 (setq bbdb-letter-address-default nil)) ; if nil, no default
	("BBDB print list syle" 
	 ;;
	 (setq bbdb-letter-prolog
	       '("%%%% ====== Phone/Address list in -*-TeX-*- Format =====\n"
		 "%%%%        *LIKE* bbdb-print, version 3.0\n\n"
		 "\\input bbdb-print\n"
		 "\\input multicol\n\n"
		 "% See bbdb-print.tex with the following parameters\n"
		 "\\setsize{6}\n"
		 "\\setseparator{2}\n"
		 "\\threecol\n\n"))
	 ;;
	 (setq bbdb-letter-separator "\\separator{%s}\n\n")
	 (setq bbdb-letter-record
	       '("\\beginrecord\n"
		 "\\firstline{"
		 (bbif tex-name tex-name (firstname " " lastname))
		 "}{}\n"
		 (bbif company ("\\comp{" company "}\n"))
		 (bbif phones
		       (bball phones
			      ("\\phone{" phone-location ": " phone-string
			       "}\n")))
		 (bbif net ("\\email{" net "}\n"))
		 (bbif addresses
		       (bball addresses
			      ("\\address{"
			       (bbif address-street1 (address-street1 " \\\\"))
			       (bbif address-street2 (address-street2 " \\\\"))
			       (bbif address-street3 (address-street3 " \\\\"))
			       (bbif address-city (address-city))
			       (bbif address-state (", " address-state))
			       (bbif address-zip-string
				     (", " address-zip-string))
			       "}\n")))
		 (bbif notes ("\\notes{" notes "}\n"))
		 "\\endrecord\n\n"))
	 ;;
	 (setq bbdb-letter-epilog '("\\endaddresses\n\\bye\n"))
	 ;;
	 (setq bbdb-letter-address-default nil)) ; if nil, no default
	)
      "*Alist defining document types for bbdb-letter.

Any pair of bbdb-letter-alist consists of a string denoting the
document type and a number of elisp expressions. The elisp expressions
should assign (setq ...) values to the variables bbdb-letter-prolog,
bbdb-letter-separator, bbdb-letter-record, bbdb-letter-epilog, and
bbdb-letter-address-default.

Customization usually extends bbdb-letter-alist as follows:
(setq bbdb-letter-alist
      (append bbdb-letter-alist
	      '((\"myown letter\" 
		 ;;
		 (setq bbdb-letter-prolog
		       '(\"\\documentstyle ...
			 ... ))))))")

(defvar current-char nil)
(defvar bbdb-current-address nil)
(defvar bbdb-current-phone nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun bbdb-compose-letter (bbdb-record)
  "Compose a letter out from the selected BBDB entries.
The first (most-recently-added) address is used if there are more than one.
\\<bbdb-mode-map>
If \"\\[bbdb-apply-next-command-to-all-records]\\[bbdb-compose-letter]\" is \
used instead of simply \"\\[bbdb-compose-letter]\", then letters are created \
to all of the
folks listed in the *BBDB* buffer instead of just the person at point."
  (interactive (list (if (bbdb-do-all-records-p)
			 (mapcar 'car bbdb-records)
		       (bbdb-current-record))))
  (let ((file-name
	 (expand-file-name
	  (read-file-name "Print To File: "
			  (concat bbdb-letter-directory-name
				  bbdb-letter-file-name))))
	(completion-ignore-case t))
    (find-file file-name)
    (if (if (> (buffer-size) 0)
	    (not (yes-or-no-p "File is not empty; delete contents "))
	  nil)
	nil
      (delete-region (point-min) (point-max))
      (mapcar 'eval
	      (cdr (assoc (completing-read "Type of document: "
					   bbdb-letter-alist
					   nil t)
			  bbdb-letter-alist)))
      (if (consp bbdb-record)
	  (bbdb-compose-letter-many bbdb-record)
	(bbdb-compose-letter-1 bbdb-record)))))

(defun bbdb-compose-letter-1 (bbdb-record)    
  (if bbdb-inside-electric-display
      (bbdb-electric-throw-to-execute
	(list 'bbdb-compose-letter bbdb-record)))
  ;; else...

  (cond ((null bbdb-record) (error "record unexists"))
;	((null (bbdb-record-addresses bbdb-record))
;	 (error "Current record unhas addresses."))
	(t (insert (apply 'concat (bbdb-format bbdb-record bbdb-letter-record)))
	   (goto-char (point-max)) (insert (apply 'concat bbdb-letter-epilog))
	   (goto-char (point-min)) (insert (apply 'concat bbdb-letter-prolog))
	   )))

(defun bbdb-compose-letter-many (bbdb-records)
  (if bbdb-inside-electric-display
      (bbdb-electric-throw-to-execute
	(list 'bbdb-compose-letter-many (list 'quote bbdb-records))))
  ;; else...

  (let (first-char)
    (insert (apply 'concat bbdb-letter-prolog))
    (while bbdb-records
      ;;
      ;; Section header, if neccessary.
      ;;
      (setq first-char (substring (concat (bbdb-record-sortkey
					   (car bbdb-records)) "?") 0 1))
      (if (and current-char
	       (string-equal first-char current-char))
	  nil
	(if bbdb-letter-separator
	    (insert (format bbdb-letter-separator (upcase first-char))))
	(setq current-char first-char))
      ;;
      ;; the record itself
      ;;
      (insert (apply 'concat
		     (bbdb-format (car bbdb-records) bbdb-letter-record)))
      (setq bbdb-records (cdr bbdb-records)))
    (insert (apply 'concat bbdb-letter-epilog)))
  (if (re-search-backward "^Subject: $" nil t) (end-of-line)))

(defun bbdb-format (record stringlist &optional  quotation)
  ;;
  ;; This expands the description of a list of strings and the
  ;; corresponding substructures. The resulting list is concatenated
  ;; an inserted into the buffer.
  ;;
  (setq bbdb-current-address nil)
  (setq bbdb-current-phone nil)
  (let (nsl ns)
    (while stringlist
      (setq ns (bbdb-format-1 record (car stringlist)  quotation))
      (if (listp ns)
	  (setq nsl (append nsl ns))
	(setq nsl (append nsl (list ns))))
      (setq stringlist (cdr stringlist)))
    nsl))

(defun bbdb-format-1 (record string &optional quotation)
  ;;
  ;; Subfunction of bbdb-format to expand a single item on the
  ;; stringlist passed to bbdb-format. If the item is a list,
  ;; bbdb-format-1 is called recursively. Lists may be one of bbif,
  ;; bball or simply a list for blocking.
  ;;
  (cond ((stringp string) string)
	((symbolp string)
	 ;; be shure to return nil if there is an empty string.
	 (bbdb-record-get-field-string record string quotation))
	((listp string)
	 (cond ((eq (car string) 'bbif)
		(if (bbdb-record-get-field-string record (nth 1 string)
						  quotation)
		    (bbdb-format-1 record (nth 2 string)  quotation)
		  (if (> (length string) 3)
		      (bbdb-format-1 record (nthcdr 3 string)  quotation))))
	       ((and (eq (car string) 'bball)
		     (eq (nth 1 string) 'addresses))
		(mapcar (function (lambda (a)
				    (setq bbdb-current-address a)
				    (bbdb-format-1 record (nth 2 string)
						   quotation)))
			(bbdb-record-addresses record)))
	       ((and (eq (car string) 'bball)
		     (eq (nth 1 string) 'phones))
		(mapcar (function (lambda (p)
				    (setq bbdb-current-phone p)
				    (bbdb-format-1 record (nth 2 string)
						   quotation)))
			(bbdb-record-phones record)))
	       (t (let (nsl ns)
		    (while string
		      (setq ns (bbdb-format-1 record (car string) quotation))
		      (if (listp ns)
			  (setq nsl (append nsl ns))
			(setq nsl (append nsl (list ns))))
		      (setq string (cdr string)))
		    (apply 'concat nsl)))))))


(defun bbdb-record-get-field-string (record field quotation)
  ;;
  ;; returns the database entry for a symbol.
  ;; We have to distinguish between standard fields and user defined
  ;; fields.
  ;;
  (funcall
   ;; do not return the empty string !
   (function (lambda (string) (if (and (stringp string) (string= string ""))
				  nil
				string)))
   (cond ((eq field 'name)		(bbdb-record-name record))
	 ((eq field 'net)		(bbdb-record-net record))
	 ((eq field 'aka)		(bbdb-record-aka record))
	 ((eq field 'firstname)		(bbdb-record-firstname record))
	 ((eq field 'lastname)		(bbdb-record-lastname record))
	 ((eq field 'company)		(bbdb-record-company record))
	 ((eq field 'notes)		(bbdb-record-notes record))
	 ((eq field 'phones)		(bbdb-record-phones record))
	 ((eq field 'addresses)		(bbdb-record-addresses record))
	 ((memq field '(address-location address-street1 address-street2
			address-street3 address-city address-state
			address-zip-string))
	  (bbdb-record-get-addressfield-string record field))
	 ((memq field '(phone-location phone-string))
	  (bbdb-record-get-phonefield-string record field))
	 ((and (listp (bbdb-record-raw-notes record))
	       (assq field (bbdb-record-raw-notes record)))
	  (cdr (assq field (bbdb-record-raw-notes record))))
	 ((assoc (symbol-name field) (bbdb-propnames))
	  nil)				; field is defined, but the current
					; record has no such entry.
					; Therfore nil
	 (t (error "doubleplus ungood: unknown field type %s\n
You probably did not define field type %s in your BBDB database." field)))))

(defun bbdb-record-get-addressfield-string (record field)
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
	     (bbdb-address-street1 bbdb-current-address))
	    ((eq field 'address-street2)
	     (bbdb-address-street2 bbdb-current-address))
	    ((eq field 'address-street3)
	     (bbdb-address-street3 bbdb-current-address))
	    ((eq field 'address-city)
	     (bbdb-address-city bbdb-current-address))
	    ((eq field 'address-state)
	     (bbdb-address-state bbdb-current-address))
	    ((eq field 'address-zip-string)
	     (bbdb-address-zip-string bbdb-current-address))))
    ))

(defun bbdb-record-get-phonefield-string (record field)
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
    ))

;;
;; ... this was stolen from bbdb-print
;; but not yet used ...
;;
(defun bbdb-print-tex-quote (string)
  "Quote any unquoted TeX special characters that appear in STRING.
In other words, # alone will be replaced by \#, but \^ will be left for 
TeX to process as an accent."
  (if string
      (save-excursion
	(set-buffer (get-buffer-create " bbdb-print-tex-quote"))
	(delete-region (point-min) (point-max))
	(insert string)
	(goto-char (point-min))
	(while (not (eobp))
	  (cond ((looking-at "[<>=]+") 
		 (replace-match "$\\&$"))
		((and (looking-at "[#$%&~_]")
		      (not (eq ?\\ (char-after (1- (point))))))
		 (replace-match "\\\\\\&"))
		((and (looking-at "[{}]")
		      (not (eq ?\\ (char-after (1- (point))))))
		 (replace-match "$\\\\\\&$"))
		((and (looking-at "\\^")
		      (not (eq ?\\ (char-after (1- (point))))))
		 (replace-match "\\\\^{ }"))
		(t (forward-char 1))))
	(buffer-string))))

(provide 'bbdb-letter)
