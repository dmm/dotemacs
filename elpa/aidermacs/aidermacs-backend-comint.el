;;; aidermacs-backend-comint.el --- Comint backend for aidermacs.el -*- lexical-binding: t; -*-

;;; Commentary:
;; Comint backend implementation for aidermacs.el

;;; Code:

(require 'comint)

(defcustom aidermacs-comint-multiline-newline-key "S-<return>"
  "Key binding for `comint-accumulate' in Aidermacs buffers.
This allows for multi-line input without sending the command."
  :type 'string
  :group 'aidermacs)

(defun aidermacs-run-aidermacs-comint (program args buffer-name)
  "Create a comint-based buffer and run aidermacs PROGRAM with ARGS in BUFFER-NAME."
  (let ((comint-terminfo-terminal "dumb"))
    (unless (comint-check-proc buffer-name)
      (apply 'make-comint-in-buffer "aidermacs" buffer-name program nil args)
      (with-current-buffer buffer-name
        (comint-mode)
        (setq-local comint-input-sender 'aidermacs-input-sender)
        (setq aidermacs--font-lock-buffer
              (get-buffer-create (concat " *aidermacs-fontify" buffer-name)))
        (add-hook 'kill-buffer-hook #'aidermacs-kill-buffer nil t)
        (add-hook 'comint-output-filter-functions #'aidermacs-fontify-blocks 100 t)
        (let ((local-map (make-sparse-keymap)))
          (set-keymap-parent local-map comint-mode-map)
          (define-key local-map (kbd aidermacs-comint-multiline-newline-key) #'comint-accumulate)
          (use-local-map local-map))
        (font-lock-add-keywords nil aidermacs-font-lock-keywords t)))))

(defun aidermacs--send-command-comint (buffer command &optional switch-to-buffer)
  "Send COMMAND to the aidermacs comint BUFFER.
If SWITCH-TO-BUFFER is non-nil, switch to the buffer after sending."
  (with-current-buffer buffer
    (let ((process (get-buffer-process buffer))
          (inhibit-read-only t))
      (goto-char (process-mark process))
      (insert (propertize command
                          'face 'aidermacs-command-text
                          'font-lock-face 'aidermacs-command-text
                          'rear-nonsticky t))
      (set-marker (process-mark process) (point))
      (comint-send-string process (concat command "\n")))))

(provide 'aidermacs-backend-comint)

;;; aidermacs-backend-comint.el ends here
