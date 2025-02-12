;;; aidermacs-backends.el --- Backend implementations for aidermacs.el -*- lexical-binding: t; -*-

;;; Commentary:
;; Backend dispatcher for aidermacs.el

;;; Code:

(defgroup aidermacs-backends nil
  "Backend customization for aidermacs."
  :group 'aidermacs)

(defcustom aidermacs-backend 'comint
  "Backend to use for the aidermacs process.
Options are 'comint (the default) or 'vterm. When set to 'vterm, aidermacs will
launch a fully functional vterm buffer (with bracketed paste support) instead
of using a comint process."
  :type '(choice (const :tag "Comint" comint)
                 (const :tag "VTerm" vterm))
  :group 'aidermacs-backends)


(require 'aidermacs-backend-comint)
(when (require 'vterm nil t)
  (require 'aidermacs-backend-vterm))


;; Backend dispatcher functions
(defun aidermacs-run-aidermacs-backend (program args buffer-name)
  "Run aidermacs using the selected backend.
PROGRAM is the aidermacs executable path, ARGS are command line arguments,
and BUFFER-NAME is the name for the aidermacs buffer."
  (cond
   ((eq aidermacs-backend 'vterm)
    (aidermacs-run-aidermacs-vterm program args buffer-name))
   (t
    (aidermacs-run-aidermacs-comint program args buffer-name))))

(defun aidermacs--send-command-backend (buffer command &optional switch-to-buffer)
  "Send COMMAND to BUFFER using the appropriate backend.
If SWITCH-TO-BUFFER is non-nil, switch to the buffer after sending."
  (cond
   ((eq aidermacs-backend 'vterm)
    (aidermacs--send-command-vterm buffer command switch-to-buffer))
   (t
    (aidermacs--send-command-comint buffer command switch-to-buffer))))

(provide 'aidermacs-backends)

;;; aidermacs-backends.el ends here
