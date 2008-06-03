;;;
;;;	David's .emacs file. This loads up lots of libraries ;).
;;;

;; Common lisp, yay!
(require 'cl)

;; Everything in ~/emacs!

(defvar emacs-root (if (or (eq system-type 'cygwin)
			   (eq system-type 'gnu/linux)
			   (eq system-type 'linux))
		       "/cygdrive/c/Documents and Settings/dmattli/" 		 
		     "c:/home/dmm/")
  "My home directory — the root of my personal emacs load-path.")

(defun add-path (p)
  (add-to-list 'load-path
	       (concat emacs-root p)))

(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((my-lisp-dir "~/emacs/site-lisp/") ; Change this to a more portable path
	   (default-directory my-lisp-dir))
      (setq load-path (cons my-lisp-dir load-path))
      (normal-top-level-add-subdirs-to-load-path)))

(add-path "emacs/site-lisp")
(add-path "emacs/lisp")

(load-library "efuncs")
(load-library "my-config")
(load-library "mail-config")
(load-library "slime-config")
(load-library "paredit-config")
;(load-library "w3m-config")
(load-library "gnus-config")
(load-library "irc-config")
(load-library "jde-config")
(load-library "pink-bliss")
(load-library "bbdb-config")
(load-library "js2-config")


;; load customizations
(load-file "~/.custom")


;(if-not-terminal "do do stuff")

;; load info manuals
(setq Info-default-directory-list
      (cons "~/books" Info-default-directory-list))

;; Start emacs server
(server-start)
;;misc
(global-font-lock-mode t)

;; yesssssss
(shell)

