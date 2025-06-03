(defun update-aidermacs () (package-vc-install
                            '(aidermacs :url "https://github.com/MatthewZMD/aidermacs.git")))

(use-package aidermacs
  :config
  (setq aidermacs-backend 'vterm)
  (setq aidermacs-args '("--model" "anthropic/claude-3-5-sonnet-20241022"))
  (global-set-key (kbd "C-c a") 'aidermacs-transient-menu))
