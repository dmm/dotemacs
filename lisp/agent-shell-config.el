(defun my-agent-shell-buffer-setup ()
  (display-line-numbers-mode -1)
  (setq-local show-trailing-whitespace nil))

(use-package agent-shell
  :hook (agent-shell-mode . my-agent-shell-buffer-setup)
  :bind (:map agent-shell-mode-map
              ("RET" . newline)
              ("C-c RET" . shell-maker-submit)))
