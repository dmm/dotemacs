(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq js2-basic-offset 2)
