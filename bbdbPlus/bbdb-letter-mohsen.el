
;;;
;;; Variables
;;;

(setq bbdb-letter-file-name "bbdb.tex")

(setq bbdb-letter-directory-name "~/")

(setq bbdb-letter-address-default nil)

(setq bbdb-letter-phone-default nil)

(setq bbdb-letter-prolog nil)

(setq bbdb-letter-separator nil)

(setq bbdb-letter-record nil)

(setq bbdb-letter-epilog nil)

(setq bbdb-letter-alist
      '(("LaTeX letter" 
	 ;;
	 (setq bbdb-letter-prolog 
	       '("\\documentstyle{letter}\n"
		"\\name{Mohsen Banan}\n"
		"\\signature{Mohsen Banan}\n"
		"\\address{17005 SE 31st Place\\\\Bellevue, WA 98008}\n"
		"\\telephone{(206)644-8026}\n"
		"% \\makelabels\n"
		"\\begin{document}\n\n"))
	 ;;
	 (setq bbdb-letter-separator "")
	 ;;
	 (setq bbdb-letter-record
	       '("\\begin{letter}{Mr. " 
		(bbif name name) " \\\\"
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
	))
