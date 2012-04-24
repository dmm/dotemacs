;;; SLIME Configuration

(require 'slime)
(setq inferior-lisp-program "sbcl")
(slime-setup '(slime-fancy))

(require 'paredit)

(define-key slime-mode-map [(?\()] 'paredit-open-list)
(define-key slime-mode-map [(?\))] 'paredit-close-list)
(define-key slime-mode-map [(return)] 'paredit-newline)

(define-key slime-mode-map [(control ?\=)] (lambda () (interactive) (insert "(")))
(define-key slime-mode-map [(control ?\\)] (lambda () (interactive) (insert ")")))

(autoload 'paredit-mode "paredit"
     "Minor mode for pseudo-structurally editing Lisp code."
     t)
(add-hook 'slime-mode-hook (lambda () (paredit-mode +1)))

(define-key paredit-mode-map (kbd "RET") nil)
(define-key lisp-mode-shared-map (kbd "RET") 'paredit-newline)
