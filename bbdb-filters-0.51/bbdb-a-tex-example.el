;;;(setq lisp-indent-offset 2)
;;;
;;; Time-stamp: "November 08, 2000"
;;;  (setq debug-on-error nil)
;;; (setq debug-on-error t)
;;; Variables
;;;


(require 'bbdb-action-lib)

;;;
;;; a-tex-letter-filtersAnnounce-neda-prolog:
;;; creates a header.
;;;

(defun a-tex-letter-filtersAnnounce-neda-prolog ()
  "Generalized neda-memo-prolog to be re-used."
    (insert "\\documentstyle [contract,10pt]{article}

\\begin{document}

\\vspace*{-0.5in}

\\begin{flushleft}
{\\Huge{\\bf Neda Communications, Inc.}}
\\end{flushleft}

\\vspace*{-.35in}
\\makebox[6.5in]{\\hrulefill}
\\vspace*{-.35in}

\\begin{flushright}
{\\small Fax: +1 425-562-9591}\\\\
{\\small E-mail: info@neda.com}
\\end{flushright}

\\vspace*{-.5in}

"))

;;; a-tex-letter-filtersAnnounce-neda creates a
;;; filename for this announcement with a .tex
;;; extension and save it to the directory specified
;;; by the bbdb-a-directory-name (in this example, the
;;; file will be save in /tmp/ directory.)
;;;

(defun a-tex-letter-filtersAnnounce-neda (records)
  ""
  (bbdb-a-get-file-name records)

   (let* (
	  ;;(first-letter (substring (concat (bbdb-record-sortkey record) "?") 0 1))
	  ;; raw fields
	  (name (bbdb-record-name (car records)))
	  (lastname (bbdb-record-lastname (car records)))
	  (net (bbdb-record-net (car records)))
	  (primary-net (car net))
	  nsl ns
	  )
     (save-excursion
       (set-buffer bbdb-a-output-buffer)

       (a-tex-letter-filtersAnnounce-neda-prolog)
       
       (bbdb-tex-memo-address records)

       (bbdb-tex-memo-phone records)

      (insert "\\vspace{0.2in}\n")

       (setq time-stamp-format "%b %02d, %y")
       (insert (time-stamp-string))

      (insert "\n\n")

      (insert (concat "Mr." lastname ",\n"))

      (insert "
This is Release 0.4 of bbdb-filters package.

BBDB is a rolodex-like database program for GNU Emacs.
BBDB stands for Insidious Big Brother Database. BBDB is written by:
Jamie Zawinski <jwz@netscape.com>.  My current version is 1.50.

We have prepared a family of filters for BBDB. Currently the output
filters include:

\\begin{verbatim}
     - bbdb --> emacs lisp exporting (for exchanging business cards)
     - bbdb --> HP100/200 LX Phone Book
     - bbdb --> PC Eudora Nicknames
     - bbdb --> CC Mail Nicknames 
     - bbdb --> PH/QI
\\end{verbatim}

There is presently only one input filter:

\\begin{verbatim}
     - bbdb <-- UNIX passwd files
\\end{verbatim}

We hope that over time a variety of other input and output filters
will be added to this collection.

bbdb-export in particular, can be very useful over the net.
It provides a convenient way for exchanging business cards.

This is a preliminary release. This stuff has not been tested much
outside of our office. We do use most of these filters on an going
basis and they work fine for us.

To install, just edit the makefile and run \"make install\".

To run them, read the comments on top of each filter file.

There is very skimpy documentation in latexinfo format. It is just
meant to be a starting point.

In addition to the attached shar file,
you can also ftp this package from:
\\begin{verbatim}
   //anonymous@ftp.neda.com:/pub/eoe/bbdbPlus/bbdb-filters-0.4.tar 
   URL =  ftp://ftp.neda.com/pub/eoe/bbdbPlus/bbdb-filters-0.4.tar 
\\end{verbatim}

Many of the filters require bbdb-tex-print package by:
Boris Goldowsky <boris@prodigal.psych.rochester.edu>.

The one that we use can be found in:
\\begin{verbatim}
  //anonymous@ftp.neda.com:/pub/eoe/bbdbPlus/bbdb-tex-3.0.tar 
  URL =  ftp://ftp.neda.com/pub/eoe/bbdbPlus/bbdb-tex-3.0.tar 
\\end{verbatim}

You can checkout the overview of this package by 
browsing the manual (latex/info/html) at:

\\begin{verbatim}
  URL = http://www.mailmeanywhere.org/emacs/doc/bbdb-filters/index.html
\\end{verbatim}

Send  bug-reports, comments and suggestions to:
		  Mohsen Banan-neda <mohsen@neda.com>
and refer to:
\\begin{verbatim}
	bbdb-filters RCS: $Id: bbdb-a-tex-example.el,v 1.1.1.1 2007/02/23 22:32:57 mohsen Exp $
\\end{verbatim}

Hope you find this helpful.

\\vspace{0.2in}
Sincerely,\\\\
Mohsen Banan

\\end{document}


"))))



;;(setq bbdb-action-alist nil)

(setq bbdb-action-alist
  (append
   bbdb-action-alist
   '(("tex-letter-filtersAnnounce-neda"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-tex-letter-filtersAnnounce-neda)
      (add-hook 'bbdb-action-hook 'bbdb-a-tex-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      (setq bbdb-a-directory-name "/tmp/")
      )
      )))

;;(provide 'bbdb-a-tex-example)

