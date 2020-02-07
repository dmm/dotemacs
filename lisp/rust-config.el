(require 'rust-mode)
(autoload 'rust-mode "rust-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

(setq rust-format-on-save t)

(with-eval-after-load 'rust-mode
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(add-hook 'rust-mode-hook 'cargo-minor-mode)
