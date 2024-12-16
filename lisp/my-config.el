;;; on-off twiddles

(require 'minibuffer-complete-cycle)
(set-variable 'minibuffer-complete-cycle t)

(require 'fill-column-indicator)

;Make the y or n suffice for a yes or no question
(fset 'yes-or-no-p 'y-or-n-p)

; Show clock
(setq display-time-24hr-format t)
(display-time)

(winner-mode 1)

(global-set-key (kbd "<Forward>") 'winner-redo)
(global-set-key (kbd "<Back>") 'winner-undo)

(global-set-key [XF86Back] 'winner-undo)
(global-set-key [XF86Forward] 'winner-redo)

(global-set-key (kbd "<f6>") 'winner-undo)
(global-set-key (kbd "<f7>") 'winner-redo)

; make vterm ignore f6 and f7
(require 'vterm)
(define-key vterm-mode-map (kbd "<f6>") nil)
(define-key vterm-mode-map (kbd "<f7>") nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Interface enhancements/defaults
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mode line information
(setq line-number-mode t)                        ; Show current line in modeline
(setq column-number-mode t)                      ; Show column as well

(setq x-underline-at-descent-line nil)           ; Prettier underlines
(setq switch-to-buffer-obey-display-actions t)   ; Make switching buffers more consistent

(setq-default show-trailing-whitespace t)      ; By default, underline trailing spaces
(setq-default indicate-buffer-boundaries 'left)  ; Show buffer top and bottom in the margin

;; Enable horizontal scrolling
(setq mouse-wheel-tilt-scroll t)
(setq mouse-wheel-flip-direction t)

;; We won't set these, but they're good to know about
;;
;; (setq-default indent-tabs-mode nil)
;; (setq-default tab-width 4)

(dolist (mode '(org-mode-hook
                term-mode-hook
                vterm-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eat-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda() (display-line-numbers-mode 0))))
;; Display line numbers in programming mode
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setq-default display-line-numbers-width 3)           ; Set a minimum width

;; Nice line wrapping when working with text
(add-hook 'text-mode-hook 'visual-line-mode)

(set-language-environment "UTF-8")

(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)   ;crap

;; Automatically reread from disk if the underlying file changes
(setq auto-revert-interval 1)
(setq auto-revert-check-vc-info t)
(global-auto-revert-mode)

;; save minibuffer history
(savehist-mode)

;; Fix archaic defaults
(setq sentence-end-double-space nil)
(setq enable-recursive-minibuffers nil)

;; Make right-click do something sensible
(when (display-graphic-p)
  (context-menu-mode))

(global-font-lock-mode 1)

(setq font-lock-maximum-decoration t)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(electric-indent-mode -1)

(setq lock-file-name-transforms
      '(("\\`/.*/\\([^/]+\\)\\'" "~/.emacs.d/lock-files/\\1" t)))

