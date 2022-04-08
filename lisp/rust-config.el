;(require 'rust-mode)
;(autoload 'rust-mode "rust-mode" nil t)


;(setq rust-format-on-save t)

;(with-eval-after-load 'rust-mode
;  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

;(add-hook 'rust-mode-hook 'cargo-minor-mode)

;; (use-package rustic
;;   :ensure t
;;   :bind (:map rustic-mode-map
;;               ("M-j" . lsp-ui-imenu)
;;               ("M-?" . lsp-find-references)
;;               ("C-c C-c l" . flycheck-list-errors)
;;               ("C-c C-c a" . lsp-execute-code-action)
;;               ("C-c C-c r" . lsp-rename)
;;               ("C-c C-c q" . lsp-workspace-restart)
;;               ("C-c C-c Q" . lsp-workspace-shutdown)
;;               ("C-c C-c s" . lsp-rust-analyzer-status))
;;   :config
;;   ;; uncomment for less flashiness
;;   ;; (setq lsp-eldoc-hook nil)
;;   ;; (setq lsp-enable-symbol-highlighting nil)
;;   ;; (setq lsp-signature-auto-activate nil)

;;   ;; comment to disable rustfmt on save
;;   (setq rustic-format-on-save t)
;;   (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook))

;; (defun rk/rustic-mode-hook ()
;;   ;; so that run C-c C-c C-r works without having to confirm
;;   (setq-local buffer-save-without-query t))

;; (use-package lsp-mode
;;   :ensure t
;;   :commands lsp
;;   :custom
;;   ;; what to use when checking on-save. "check" is default, I prefer clippy
;;   (lsp-rust-analyzer-cargo-watch-command "clippy")
;;   (lsp-eldoc-render-all t)
;;   (lsp-idle-delay 0.6)
;;   :config
;;   (add-hook 'lsp-mode-hook 'lsp-ui-mode))

;; (use-package lsp-ui
;;   :ensure t
;;   :commands lsp-ui-mode
;;   :custom
;;   (lsp-ui-peek-always-show t)
;;   (lsp-ui-sideline-show-hover t)
;;   (lsp-ui-doc-enable nil))

;(use-package flycheck :ensure)
;(with-eval-after-load 'rust-mode
;  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(use-package rustic)

(setq rustic-format-on-save t)
;(setq rustic-lsp-format nil)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rustic-mode))
;;; rust-config.el ends here

