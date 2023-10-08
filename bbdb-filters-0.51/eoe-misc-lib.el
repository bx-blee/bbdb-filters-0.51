;;;
;;;  (setq debug-on-error t)
;;;  (setq debug-on-error nil)
;;; (setq bbdb-action-alist nil)

(defun read-from-file (file-name)
  "Backwards compat to eoe-read-from-file"
  eoe-read-from-file (file-name))

(defun eoe-read-from-file (file-name)
  "RETURNS content of the file as a string"
  (let* (
      (this-buffer)
      (this-string)
      )
    (save-excursion 
      (setq this-buffer (find-file file-name))
      (setq this-string (buffer-substring (point)
					  (progn (end-of-line) (point))))
      (kill-buffer this-buffer))
    this-string))

(defun eoe-read-from-file (file-name)
  "RETURNS content of the file as a string"
  (let* (
      (this-buffer)
      (this-string)
      )
    (save-excursion 
      (setq this-buffer (find-file file-name))
      (setq this-string (buffer-substring (point)
					  (progn (end-of-line) (point))))
      (kill-buffer this-buffer))
    this-string))


;(message (read-from-file "/usr/devenv/doc/nedaComRecs/Content/TEST/Inserts/this/this-announce.form"))

  
(provide 'eoe-misc-lib)


