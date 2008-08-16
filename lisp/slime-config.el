;;; SLIME Configuration
(require 'slime)
(setq inferior-lisp-program "sbcl") ; My lisp system
(slime-setup)

;;; Redshank configuration

(autoload 'redshank-mode "redshank"
  "Minor mode for editing and refactoring (Common) Lisp code."
  t)
   (autoload 'turn-on-redshank-mode "redshank"
     "Turn on Redshank mode.  Please see function `redshank-mode'."
     t)
   (add-hook '...-mode-hook 'turn-on-redshank-mode)
