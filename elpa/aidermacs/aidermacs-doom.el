;;; aidermacs-doom.el --- Description -*- lexical-binding: t; no-byte-compile: t -*-
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Doom integration for aidermacs
;;
;;; Code:

(defun aidermacs-doom-setup-keys ()
  "Setup aidermacs keybindings if the current buffer is in a git repository."
  (when (and (featurep 'doom-keybinds)
             (vc-backend (or (buffer-file-name) default-directory)))
    (map! :leader
          (:prefix ("A" . "aidermacs")
                   (:prefix ("a" . "Add")
                            :desc "Current file" "c" #'aidermacs-add-current-file
                            :desc "File read-only" "f" #'aidermacs-current-file-read-only
                            :desc "Files in window" "w" #'aidermacs-add-files-in-current-window
                            :desc "Add Same Type Files under dir" "d" #'aidermacs-add-same-type-files-under-dir
                            :desc "Batch direct marked files" "b" #'aidermacs-batch-add-dired-marked-files
                            )

                   (:prefix ("b" . "Buffer")
                            :desc "Switch to aidermacs" "b" #'aidermacs-switch-to-buffer
                            :desc "Clear aidermacs" "c" #'aidermacs-clear
                            )

                   (:prefix ("s" . "Send")
                            :desc "Line at cursor" "l" #'aidermacs-send-line-under-cursor
                            :desc "Paragraph at cursor, line by line" "p" #'aidermacs-send-region-by-line
                            :desc "Region as block" "r" #'aidermacs-send-region
                            )

                   (:prefix ("c" . "Code")
                            :desc "Architecture" "d" #'aidermacs-architect-discussion
                            :desc "Change" "c" #'aidermacs-code-change
                            :desc "Refactor Function or Region" "r" #'aidermacs-function-or-region-refactor
                            :desc "Implement Requirement in-place" "i" #'aidermacs-implement-todo
                            :desc "Undo change" "u" #'aidermacs-undo-last-change
                            :desc "Show last commit" "g" #'aidermacs-magit-show-last-commit
                            )

                   (:prefix ("d" . "Discuss")
                            :desc "Ask question" "a" #'aidermacs-ask-question
                            :desc "Explain Function or Region" "r" #'aidermacs-function-or-region-explain
                            :desc "Exception debugging" "e" #'aidermacs-debug-exception
                            )

                   (:prefix ("t" . "Test")
                            :desc "Write Unit Test" "w" #'aidermacs-write-unit-test
                            :desc "Fix Failed Test" "f" #'aidermacs-fix-failing-test-under-cursor
                            )

                   (:prefix ("z" . "Other")
                            :desc "General command" "c" #'aidermacs-general-command
                            :desc "Help" "h" #'aidermacs-help
                            )

                   :desc "Open aidermacs" "o" #'aidermacs-run-aidermacs
                   :desc "Reset aidermacs" "r" #'aidermacs-reset
                   :desc "Exit aidermacs" "x" #'aidermacs-exit
                   ))))

;; Add the setup function to appropriate hooks
(add-hook 'find-file-hook #'aidermacs-doom-setup-keys)
(add-hook 'dired-mode-hook #'aidermacs-doom-setup-keys)
(add-hook 'after-change-major-mode-hook #'aidermacs-doom-setup-keys)

(provide 'aidermacs-doom)
;;; aidermacs-doom.el ends here
