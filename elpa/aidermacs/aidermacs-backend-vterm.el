;;; aidermacs-backend-vterm.el --- VTerm backend for aidermacs.el -*- lexical-binding: t; -*-

;;; Commentary:
;; VTerm backend implementation for aidermacs.el

;;; Code:

(require 'vterm nil t)

(defun aidermacs-run-aidermacs-vterm (program args buffer-name)
  "Create a vterm-based buffer and run aidermacs PROGRAM with ARGS in BUFFER-NAME."
  (unless (require 'vterm nil t)
    (error "vterm package is not available"))
  (unless (get-buffer buffer-name)
    (let* ((mode (if (eq (frame-parameter nil 'background-mode) 'dark)
                     "--dark-mode"
                   "--light-mode"))
           (cmd (mapconcat 'identity (append (list program mode) args) " "))
           (vterm-buffer-name-orig vterm-buffer-name)
           (vterm-shell-orig vterm-shell))
      (setq vterm-buffer-name buffer-name)
      (setq vterm-shell cmd)
      (if (get-buffer buffer-name)
          (switch-to-buffer buffer-name)
        (with-current-buffer (vterm-other-window)
          (aidermacs-minor-mode 1)))
      (setq vterm-buffer-name vterm-buffer-name-orig)
      (setq vterm-shell vterm-shell-orig))))

(defun aidermacs--send-command-vterm (buffer command &optional switch-to-buffer)
  "Send COMMAND to the aidermacs vterm BUFFER.
If SWITCH-TO-BUFFER is non-nil, switch to the buffer after sending."
  (with-current-buffer buffer
    (vterm-send-string command)
    (vterm-send-return)))

(provide 'aidermacs-backend-vterm)

;;; aidermacs-backend-vterm.el ends here
