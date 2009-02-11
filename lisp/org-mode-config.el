(require 'org-install)

(setq org-hide-leading-stars t)

(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

(define-key mode-specific-map [?a] 'org-agenda)

