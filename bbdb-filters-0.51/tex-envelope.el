;;;(setq lisp-indent-offset 2)
;;;
;;; Time-stamp: "010318224609"
;;;  (setq debug-on-error nil)
;;; (setq debug-on-error t)
;;; Variables
;;;

;;; tex-envelope.el
;;; 
;;; This code will produce a LaTeX file for the letter.
;;; The originator's letter head
;;; are set in the originator-prefs.el.
;;; This function is intended to be used with bbdb.
;;; The recipient's information will automatically 
;;; inserted from the bbdb record.

(require 'bbdb-action-lib)

(defun a-tex-envelope-common ()
""
       (insert "\\def\\setaddress#1{\\gdef\\Xaddress{#1}}\n")
       (insert "\\setaddress{\\hbox{\\bf * ADDRESS *}}\n\n")
       (insert "\\def\\address{\\par{\\vskip\\parskip\\parskip=0pt\\def\\\\{\\par}\\frenchspacing\\Xaddress}\\par\\let\\address\\relax}\n\n")
       (insert "\\def\\attn#1{\\gdef\\Xattn{Attn: #1}}\n")
       (insert "\\let\\Xattn=\\relax\n")
       (insert "\\let\\zipbar=\\relax\n\n")
       (insert "% Sender's address\n")
       (insert "\\leftline{   }\n")
       (insert "\\leftline{   }\n")
       (insert (concat "\\leftline{          " originator-full-name "}\n"))
       (insert (concat "\\leftline{          " originator-street-address1 "}\n"))
       (if (not (eq originator-street-address2 nil))
	   (insert (concat "\\leftline{          " originator-street-address2 "}\n")))
       (insert (concat "\\leftline{          " originator-city-address ", " originator-state-address " " originator-zipcode-address "}\n\n"))
       (insert "% Recipient's address\n")
       (insert "\\setaddress")
       (insert (concat "{" name "\\\\\n"))
       (if (not (eq company nil))
	   (insert (concat company "\\\\\n")))
       (bbdb-tex-memo-address-withZipBar records)
       (insert "}\n\n")

       (insert "%\\attn{John Doe}\n\n")

       (insert "% ============================\n")
       (insert "% DO NOT TOUCH BELOW THIS LINE\n")
       (insert "% ============================\n\n")
       (insert "\\catcode`@=11\n\n")

       (insert "\\newdimen\\b@rwidth \\newdimen\\b@rlong \\newdimen\\b@rshort \\newdimen\\b@rsep\n")
       (insert "\\b@rwidth=0.02true in \\b@rlong=0.125true in \\b@rshort=0.05true in\n")
       (insert "\\b@rsep=0.0275true in\n")
       (insert "\\def\\sb@r{\\vrule height\\b@rshort width\\b@rwidth depth0pt \\kern\\b@rsep}\n")
       (insert "\\def\\lb@r{\\vrule height\\b@rlong width\\b@rwidth depth0pt \\kern\\b@rsep}\n\n")

       (insert "\\def\\zerob@r{\\lb@r\\lb@r\\sb@r\\sb@r\\sb@r}\n")
       (insert "\\def\\oneb@r{\\sb@r\\sb@r\\sb@r\\lb@r\\lb@r}\n")
       (insert "\\def\\twob@r{\\sb@r\\sb@r\\lb@r\\sb@r\\lb@r}\n")
       (insert "\\def\\threeb@r{\\sb@r\\sb@r\\lb@r\\lb@r\\sb@r}\n")
       (insert "\\def\\fourb@r{\\sb@r\\lb@r\\sb@r\\sb@r\\lb@r}\n")
       (insert "\\def\\fiveb@r{\\sb@r\\lb@r\\sb@r\\lb@r\\sb@r}\n")
       (insert "\\def\\sixb@r{\\sb@r\\lb@r\\lb@r\\sb@r\\sb@r}\n")
       (insert "\\def\\sevenb@r{\\lb@r\\sb@r\\sb@r\\sb@r\\lb@r}\n")
       (insert "\\def\\eightb@r{\\lb@r\\sb@r\\sb@r\\lb@r\\sb@r}\n")
       (insert "\\def\\nineb@r{\\lb@r\\sb@r\\lb@r\\sb@r\\sb@r}\n\n")

       (insert "\\newcount\\zipb@rm\n")
       (insert "\\newcount\\zipb@rn\n")
       (insert "\\chardef\\ten=10\n\n")

       (insert "\\def\\zipb@r@@@#1#2{\\expandafter\\def\\csname zipb@r@@#1\\endcsname%\n")
       (insert "{#2\\advance\\zipb@rn#1\\relax}}\n\n")

       (insert "\\newbox\\zipbarcode\n")
       (insert "\\zipb@r@@@0{\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\zerob@r}}\n")
       (insert "\\zipb@r@@@1{\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\oneb@r}}\n")
       (insert "\\zipb@r@@@2{\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\twob@r}}\n")
       (insert "\\zipb@r@@@3{\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\threeb@r}}\n")
       (insert "\\zipb@r@@@4{\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\fourb@r}}\n")
       (insert "\\zipb@r@@@5{\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\fiveb@r}}\n")
       (insert "\\zipb@r@@@6{\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\sixb@r}}\n")
       (insert "\\zipb@r@@@7{\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\sevenb@r}}\n")
       (insert "\\zipb@r@@@8{\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\eightb@r}}\n")
       (insert "\\zipb@r@@@9{\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\nineb@r}}\n")

       (insert "\\def\\zipb@r@@#1{\\csname zipb@r@@#1\\endcsname}\n\n")

       (insert "\\def\\zipb@r@#1{\\ifx#1\\null\n")
       (insert "\\let\\next\\relax\n")
       (insert "\\else\n")
       (insert "\\zipb@r@@{#1}#1%\n")
       (insert "\\let\\next\\zipb@r@\n")
       (insert "\\fi\n")
       (insert "\\next}\n\n")

       (insert "\\def\\zipbar#1{\\setbox\\zipbarcode=\\null\n")
       (insert "\\hbox{ % put numbers in an \\hbox\n")
       (insert "\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\lb@r} % start with long bar\n")
       (insert "\\zipb@rn\\z@\\zipb@r@#1\\null\n")
       (insert "\\zipb@rm\\zipb@rn \\divide\\zipb@rm\\ten \\multiply\\zipb@rm\\ten\n")
       (insert "\\advance\\zipb@rm-\\zipb@rn\n")
       (insert "\\ifnum\\zipb@rm<0\n")
       (insert "\\advance\\zipb@rm\\ten\n")
       (insert "\\fi\n")
       (insert "\\zipb@r@@{\\the\\zipb@rm} % last digit, so that the sum is divisible by ten\n")
       (insert "\\global\\setbox\\zipbarcode\\hbox{\\box\\zipbarcode\\lb@r}% end with a long bar\n")
       (insert "} % end of \\hbox\n")
       (insert "}\n\n")

       (insert "\\catcode`@=12  % disable private sequences\n\n")

       (insert "\\special{landscape}   % envelopes are printed in landscape mode\n\n")

       (insert "\\font\\envfont=cmss10 at 10.95true pt  % cmss10 is smaller than 10pt Helvetica\n")
       (insert "\\baselineskip=14true pt\n\n")

       (insert "\\catcode`.=9 \\catcode`,=9    % 9 = ignored character\n\n")

       (insert "\\catcode`\\.=12 \\catcode`\\,=12\n\n")

       (insert "\\def\\next#1\\endname{\\uppercase{\\def\\Xaddress{#1}}}\n")
       (insert "\\expandafter\\next\\Xaddress\\endname\n\n")
       (insert "\\ \\vfil % fill up with blank space\n")
       (insert "\\vbox to 2.25true in{\n")
       (insert "\\vbox to 1.625true in{\\envfont\\leftskip=4.5true in \n")
       (insert "\\fontdimen6\\envfont=10true pt\n")
       (insert "\\fontdimen2\\envfont=10true pt\n")
       (insert "\\fontdimen3\\envfont=1true pt\n")
       (insert "\\fontdimen4\\envfont=1true pt\n")
       (insert "\\fontdimen7\\envfont=0pt\n")
       (insert "\\address\\vfil}\n\n")
       (insert "\\vfil\n")
       (insert "\\rightline{\\hbox to 4true in{\\box\\zipbarcode\\hfil}}\n\n")
       (insert "\\vbox to 0.25true in{\\vfil\\leftline{\\envfont\\enspace\\Xattn}\\vskip0.1true in}\n")
       (insert "}\n")
       (insert "\\eject\\end\n")
)

(defun a-tex-envelope-legal (records)
  ""

  (bbdb-a-get-file-name records)

   (let* (
	  (name (bbdb-record-name (car records)))
	  (lastname (bbdb-record-lastname (car records)))
	  (net (bbdb-record-net (car records)))
	  (company (bbdb-record-company (car records)))
	  (primary-net (car net))
	  nsl ns
	  )

     (save-excursion
       (set-buffer bbdb-a-output-buffer)
;;
;; Start the TeX format
;;
(insert "% This is a machine-generated file through tex-envelope.el.\n")
(insert "% Do not make any changes to this file.\n")
(insert "% ===========================================================\n\n\n")
(insert "% Envelope Size\n")
(insert "\\hsize=9.5true in\\hoffset=0.5true in\n")
(insert "\\vsize=4.125true in\\voffset=1.1875true in\n\n")

(a-tex-envelope-common)

 )))

(defun a-tex-envelope-7x5 (records)
  ""

  (bbdb-a-get-file-name records)

   (let* (
	  (name (bbdb-record-name (car records)))
	  (lastname (bbdb-record-lastname (car records)))
	  (net (bbdb-record-net (car records)))
	  (company (bbdb-record-company (car records)))
	  (primary-net (car net))
	  nsl ns
	  )

     (save-excursion
       (set-buffer bbdb-a-output-buffer)
;;
;; Start the TeX format
;;
(insert "% This is a machine-generated file through tex-envelope.el.\n")
(insert "% Do not make any changes to this file.\n")
(insert "% ===========================================================\n\n\n")
(insert "% Envelope Size\n")
(insert "\\hsize=7.125true in\\hoffset=2.5true in\n")
(insert "\\vsize=4.75true in\\voffset=0.5true in\n\n")

(a-tex-envelope-common)

 )))

;;(setq bbdb-action-alist nil)

(setq bbdb-action-alist
  (append
   bbdb-action-alist
   '(("tex-envelope-legal"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-tex-envelope-legal)
      (add-hook 'bbdb-action-hook 'bbdb-a-tex-envelope-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      ))
   '(("tex-envelope-7x5"
      ;;
      (setq bbdb-action-hook nil)
      (add-hook 'bbdb-action-hook 'a-tex-envelope-7x5)
      (add-hook 'bbdb-action-hook 'bbdb-a-tex-envelope-file-hook)
      (add-hook 'bbdb-action-hook 'bbdb-a-lastname-date-file-hook)
      ))
))

(provide 'tex-envelope)



