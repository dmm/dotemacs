;;; on-off twiddles

(require 'color-theme)
(color-theme-initialize)

(require 'minibuffer-complete-cycle)
(set-variable 'minibuffer-complete-cycle t)

;Make the y or n suffice for a yes or no question
(fset 'yes-or-no-p 'y-or-n-p)

; Show clock
(setq display-time-24hr-format t)
(display-time)


(line-number-mode t)		  ; show line numbers in the mode-line
(column-number-mode t)          ; show column numbers in the mode-line
(winner-mode 1)

(set-language-environment "UTF-8")

(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)   ;crap

(global-font-lock-mode 1)

(setq font-lock-maximum-decoration t)

(setq c-default-style '(("c++-mode" "stroustrup")))

(setq tramp-default-method "scpc")

