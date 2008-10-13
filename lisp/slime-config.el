;;; SLIME Configuration
(require 'slime)
(setq inferior-lisp-program "sbcl") ; My lisp system
(setq slime-net-coding-system 'utf-8-unix)
(slime-setup)

;;; Redshank configuration

(autoload 'redshank-mode "redshank"
  "Minor mode for editing and refactoring (Common) Lisp code."
  t)
   (autoload 'turn-on-redshank-mode "redshank"
     "Turn on Redshank mode.  Please see function `redshank-mode'."
     t)
   (add-hook 'lisp-mode-hook 'turn-on-redshank-mode)
