;;;
;;;	David's .emacs file. This loads up lots of libraries ;).
;;;

;; Common lisp, yay!
(require 'cl)

;; Some helpful functions 

(defun files-in-below-directory (directory)
  "List the .el files in DIRECTORY and in its sub-directories."
  ;; Although the function will be used non-interactively,
  ;; it will be easier to test if we make it interactive.
  ;; The directory will have a name such as
  ;;  "/usr/local/share/emacs/21.0.100/lisp/"
  (interactive "DDirectory name: ")
  (let (el-files-list
	(current-directory-list
	 (directory-files-and-attributes directory t)))
    ;; while we are in the current directory
    (while current-directory-list
      (cond
       ;; check to see whether filename ends in `.el'
       ;; and if so, append its name to a list.
       ((equal ".el" (substring (car (car current-directory-list)) -3))
	(setq el-files-list
	      (cons (car (car current-directory-list)) el-files-list)))
       ;; check whether filename is that of a directory
       ((eq t (car (cdr (car current-directory-list))))
	;; decide whether to skip or recurse
	(if
	    (equal "."
		   (substring (car (car current-directory-list)) -1))
	    ;; then do nothing since filename is that of
	    ;;   current directory or parent, "." or ".."
	    ()
	  ;; else descend into the directory and repeat the process
	  (setq el-files-list
		(append
		 (files-in-below-directory
		  (car (car current-directory-list)))
		 el-files-list)))))
      ;; move to the next filename in the list; this also
      ;; shortens the list so the while loop eventually comes to an end
      (setq current-directory-list (cdr current-directory-list)))
    ;; return the filenames
    el-files-list))


(defun fill-load-path (path)
  (dolist (file (files-in-below-directory path))
    (if file
	(add-to-list 'load-path
		     (file-name-directory file)))))

(defun load-tree (path)
  (dolist (fl (files-in-below-directory path))
    (if fl
	(load-file fl))))




;; Fill load-path
(fill-load-path "~/emacs/site-lisp/")
(fill-load-path "~/emacs/lisp/")

;; Load configuration
(load-tree "~/emacs/lisp/")


;; load customizations
(load-file "~/.custom")


;; load info manuals
(setq Info-default-directory-list
      (cons "~/books" Info-default-directory-list))

;; Start emacs server
(server-start)
;;misc
(global-font-lock-mode t)

;; yesssssss
(shell)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(jde-jdk (quote ("1.6.0")))
 '(jde-jdk-registry (quote (("1.5.0" . "/usr/local/jdk-1.5.0") ("1.6.0" . "/usr/local/jdk-1.6.0")))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
