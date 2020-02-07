;;; on-off twiddles

(require 'minibuffer-complete-cycle)
(set-variable 'minibuffer-complete-cycle t)

(require 'fill-column-indicator)

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

(setq c-default-style '(("c++-mode" "google")))


(defun my-setup-indent (n)
  ;; java/c/c++
  (setq-local c-basic-offset n)
  ;; web development
  (setq-local coffee-tab-width n) ; coffeescript
  (setq-local javascript-indent-level n) ; javascript-mode
  (setq-local js-indent-level n) ; js-mode
  (setq-local js2-basic-offset n) ; js2-mode, in latest js2-mode, it's alias of js-indent-level
  (setq-local web-mode-markup-indent-offset n) ; web-mode, html tag in html file
  (setq-local web-mode-css-indent-offset n) ; web-mode, css in html file
  (setq-local web-mode-code-indent-offset n) ; web-mode, js code in html file
  (setq-local css-indent-offset n) ; css-mode
  )
(defun my-personal-code-style ()
  (interactive)
  (message "My personal code style!")
  ;; use space instead of tab
  (setq indent-tabs-mode nil)
  ;; indent 2 spaces width
  (my-setup-indent 2))

(add-hook 'css-mode-hook 'my-personal-code-style)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
