;;; aidermacs.el --- aidermacs package for interactive conversation with aidermacs -*- lexical-binding: t; -*-a

;; Author: Mingde (Matthew) Zeng <matthewzmd@posteo.net>
;; Original Author: Kang Tu <tninja@gmail.com>
;; Version: 0.2.0
;; Package-Requires: ((emacs "26.1") (transient "0.3.0"))
;; Keywords: convenience, tools
;; URL: https://github.com/MatthewZMD/aidermacs.el

;;; Commentary:
;; This package provides an interactive interface to communicate with https://github.com/paul-gauthier/aidermacs.

;;; Code:

(require 'comint)
(require 'dired)
(require 'transient)
(require 'vc-git)
(require 'which-func)
(require 'ansi-color)


(require 'aidermacs-backends)
(require 'aidermacs-models)
(when (featurep 'doom)
  (require 'aidermacs-doom))

(defgroup aidermacs nil
  "Customization group for the aidermacs package."
  :prefix "aidermacs-"
  :group 'convenience)

(defcustom aidermacs-program "aider"
  "The name or path of the aidermacs program."
  :type 'string
  :group 'aidermacs)

(defcustom aidermacs-args '("--model" "anthropic/claude-3-5-sonnet-20241022")
  "Arguments to pass to the aidermacs command."
  :type '(repeat string)
  :group 'aidermacs)

(defcustom aidermacs--switch-to-buffer-other-frame nil
  "When non-nil, open aidermacs buffer in a new frame using `switch-to-buffer-other-frame'.
When nil, use standard `display-buffer' behavior."
  :type 'boolean
  :group 'aidermacs)


(defcustom aidermacs-language-name-map '(("elisp" . "emacs-lisp")
                                         ("bash" . "sh")
                                         ("objective-c" . "objc")
                                         ("objectivec" . "objc")
                                         ("cpp" . "c++"))
  "Map external language names to Emacs names."
  :type '(alist :key-type (string :tag "Language Name/Alias")
                :value-type (string :tag "Mode Name (without -mode)"))
  :group 'aidermacs)

(defcustom aidermacs-prompt-file-name ".aider.prompt.org"
  "File name that will automatically enable aidermacs-minor-mode when opened.
This is the file name without path."
  :type 'string
  :group 'aidermacs)

(defvar aidermacs-read-string-history nil
  "History list for aidermacs read string inputs.")
(if (bound-and-true-p savehist-loaded)
    (add-to-list 'savehist-additional-variables 'aidermacs-read-string-history)
  (add-hook 'savehist-mode-hook
            (lambda ()
              (add-to-list 'savehist-additional-variables 'aidermacs-read-string-history))))

(defface aidermacs-command-separator
  '((((type graphic)) :strike-through t :extend t)
    (((type tty)) :inherit font-lock-comment-face :underline t :extend t))
  "Face for command separator in aidermacs."
  :group 'aidermacs)

(defface aidermacs-command-text
  '((t :inherit bold))
  "Face for commands sent to aidermacs buffer."
  :group 'aidermacs)

(defface aidermacs-search-replace-block
  '((t :inherit 'diff-refine-added :bold t))
  "Face for search/replace block content."
  :group 'aidermacs)

(defvar aidermacs-font-lock-keywords
  '(("^\x2500+\n?" 0 '(face aidermacs-command-separator) t)
    ("^\x2500+" 0 '(face nil display (space :width 2)))
    ("^\\([0-9]+\\). " 0 font-lock-constant-face)
    ("^>>>>>>> REPLACE" 0 'aidermacs-search-replace-block t)
    ("^<<<<<<< SEARCH" 0 'aidermacs-search-replace-block t)
    ("^\\(```\\)\\([^[:space:]]*\\)" (1 'shadow t) (2 font-lock-builtin-face t))
    ("^=======$" 0 'aidermacs-search-replace-block t))
  "Font lock keywords for aidermacs buffer.")

;;;###autoload
(defun aidermacs-plain-read-string (prompt &optional initial-input)
  "Read a string from the user with PROMPT and optional INITIAL-INPUT.
This function can be customized or redefined by the user."
  (read-string prompt initial-input 'aidermacs-read-string-history))

;;;###autoload
(defalias 'aidermacs-read-string 'aidermacs-plain-read-string)

(eval-and-compile
  ;; Ensure the alias is always available in both compiled and interpreted modes.
  (defalias 'aidermacs-read-string 'aidermacs-plain-read-string))

(defvar aidermacs--add-file-read-only nil
  "Set model parameters from `aidermacs-menu' buffer-locally.
Affects the system message too.")

(defun aidermacs--get-add-command-prefix ()
  "Return the appropriate command prefix based on aidermacs--add-file-read-only."
  (if aidermacs--add-file-read-only "/read-only" "/add"))

(defclass aidermacs--add-file-type (transient-lisp-variable)
  ((variable :initform 'aidermacs--add-file-read-only)
   (format :initform "%k %d %v")
   (reader :initform #'transient-lisp-variable--read-value))
  "Class for toggling aidermacs--add-file-read-only.")

(defclass aidermacs--switch-to-buffer-type (transient-lisp-variable)
  ((variable :initform 'aidermacs--switch-to-buffer-other-frame)
   (format :initform "%k %d %v")
   (reader :initform #'transient-lisp-variable--read-value))
  "Class for toggling aidermacs--switch-to-buffer-other-frame.")

(transient-define-infix aidermacs--infix-add-file-read-only ()
  "Toggle aidermacs--add-file-read-only between nil and t."
  :class 'aidermacs--add-file-type
  :key "@"
  :description "Read-only mode"
  :reader (lambda (_prompt _initial-input _history)
            (not aidermacs--add-file-read-only)))

(transient-define-infix aidermacs--infix-switch-to-buffer-other-frame ()
  "Toggle aidermacs--switch-to-buffer-other-frame between nil and t."
  :class 'aidermacs--switch-to-buffer-type
  :key "^"
  :description "Open in new frame"
  :reader (lambda (_prompt _initial-input _history)
            (not aidermacs--switch-to-buffer-other-frame)))

;; Transient menu for aidermacs commands
;; The instruction in the autoload comment is needed, see
;; https://github.com/magit/transient/issues/280.
;;;###autoload (autoload 'aidermacs-transient-menu "aidermacs" "Transient menu for aidermacs commands." t)
(transient-define-prefix aidermacs-transient-menu ()
  "Transient menu for aidermacs commands."
  ["aidermacs: AI Pair Programming"
   ["aidermacs Process"
    (aidermacs--infix-switch-to-buffer-other-frame)
    ("a" "Run aidermacs"              aidermacs-run-aidermacs)
    ("z" "Switch to aidermacs Buffer" aidermacs-switch-to-buffer)
    ("o" "Select Model"                aidermacs-change-model)
    ("l" "Clear aidermacs"              aidermacs-clear)
    ("s" "Reset aidermacs"              aidermacs-reset)
    ("x" "Exit aidermacs"               aidermacs-exit)
    ]
   ["Add File to aidermacs"
    (aidermacs--infix-add-file-read-only)
    ("f" "Add Current File"           aidermacs-add-current-file)
    ("R" "Add Current File Read-Only" aidermacs-current-file-read-only)
    ("w" "Add All Files in Current Window" aidermacs-add-files-in-current-window)
    ("d" "Add Same Type Files under dir" aidermacs-add-same-type-files-under-dir)
    ("b" "Batch Add Dired Marked Files"  aidermacs-batch-add-dired-marked-files)
    ]
   ["Code Change"
    ("t" "Architect Discuss and Change" aidermacs-architect-discussion)
    ("c" "Code Change"                  aidermacs-code-change)
    ("r" "Refactor Function or Region"  aidermacs-function-or-region-refactor)
    ("i" "Implement Requirement in-place" aidermacs-implement-todo)
    ("U" "Write Unit Test"              aidermacs-write-unit-test)
    ("T" "Fix Failing Test Under Cursor" aidermacs-fix-failing-test-under-cursor)
    ("m" "Show Last Commit with Magit"  aidermacs-magit-show-last-commit)
    ("u" "Undo Last Change"             aidermacs-undo-last-change)
    ]
   ["Discussion"
    ("q" "Ask Question given Context" aidermacs-ask-question)
    ("y" "Go Ahead"                     aidermacs-go-ahead)
    ("e" "Explain Function or Region"   aidermacs-function-or-region-explain)
    ("p" "Explain Symbol Under Point"   aidermacs-explain-symbol-under-point)
    ("D" "Debug Exception"            aidermacs-debug-exception)
    ]
   ["Other"
    ("g" "General Command"            aidermacs-general-command)
    ("Q" "Ask General Question"         aidermacs-general-question)
    ("p" "Open Prompt File"           aidermacs-open-prompt-file)
    ("h" "Help"                       aidermacs-help)
    ]
   ])

(defun aidermacs-buffer-name ()
  "Generate the aidermacs buffer name based on the git repo or current buffer file path.
If not in a git repository and no buffer file exists, an error is raised."
  (let ((git-repo-path (vc-git-root default-directory))
        (current-file (buffer-file-name)))
    (cond
     ;; Case 1: Valid git repo path
     (git-repo-path
      (format "*aidermacs:%s*" (file-truename git-repo-path)))
     ;; Case 2: Has buffer file
     (current-file
      (format "*aidermacs:%s*"
              (file-truename (file-name-directory current-file))))
     ;; Case 3: No git repo and no buffer file
     (t
      (error "Not in a git repository and current buffer is not associated with a file.  Please open a file or start aidermacs from within a git repository.")))))

;;;###autoload
(defun aidermacs-run-aidermacs (&optional edit-args)
  "Run aidermacs process using the selected backend.
With the universal argument, prompt to edit aidermacs-args before running."
  (interactive "P")
  (let* ((buffer-name (aidermacs-buffer-name))
         (current-args (if edit-args
                           (split-string (read-string "Edit aidermacs arguments: "
                                                      (mapconcat 'identity aidermacs-args " ")))
                         aidermacs-args)))
    (aidermacs-run-aidermacs-backend aidermacs-program current-args buffer-name)
    (aidermacs-switch-to-buffer)))

(defun aidermacs--send-command (command &optional switch-to-buffer)
  "Send COMMAND to the corresponding aidermacs process after performing necessary checks.
Dispatches to the appropriate backend."
  (if-let ((aidermacs-buffer (get-buffer (aidermacs-buffer-name))))
      (let ((processed-command (aidermacs--process-message-if-multi-line command)))
        (aidermacs-reset-font-lock-state)
        (aidermacs--send-command-backend aidermacs-buffer processed-command switch-to-buffer)
        (when switch-to-buffer
          (aidermacs-switch-to-buffer))
        (sleep-for 0.2))
    (message "Buffer %s does not exist. Please start aidermacs with 'M-x aidermacs-run-aidermacs'." aidermacs-buffer-name)))

(defun aidermacs-kill-buffer ()
  "Clean-up fontify buffer."
  (when (bufferp aidermacs--font-lock-buffer)
    (kill-buffer aidermacs--font-lock-buffer)))

(defun aidermacs-input-sender (proc string)
  "Reset font-lock state before executing a command."
  (aidermacs-reset-font-lock-state)
  (comint-simple-send proc (aidermacs--process-message-if-multi-line string)))

;; Buffer-local variables for block processing state
(defvar-local aidermacs--block-end-marker nil
  "The end marker for the current block being processed.")

(defvar-local aidermacs--block-start nil
  "The starting position of the current block being processed.")

(defvar-local aidermacs--block-end nil
  "The end position of the current block being processed.")

(defvar-local aidermacs--last-output-start nil
  "an alternative to `comint-last-output-start' used in aidermacs.")

(defvar-local aidermacs--block-mode nil
  "The major mode for the current block being processed.")

(defvar-local aidermacs--font-lock-buffer nil
  "Temporary buffer for fontification.")

(defconst aidermacs-search-marker "<<<<<<< SEARCH")
(defconst aidermacs-diff-marker "=======")
(defconst aidermacs-replace-marker ">>>>>>> REPLACE")
(defconst aidermacs-fence-marker "```")
(defvar aidermacs-block-re
  (format "^\\(?:\\(?1:%s\\|%s\\)\\|\\(?1:%s\\).+\\)$" aidermacs-search-marker aidermacs-diff-marker aidermacs-fence-marker))

(defun aidermacs-reset-font-lock-state ()
  "Reset font lock state to default for processing another a new src block."
  (unless (equal aidermacs--block-end-marker aidermacs-diff-marker)
    ;; if we are processing the other half of a SEARCH/REPLACE block, we need to
    ;; keep the mode
    (setq aidermacs--block-mode nil))
  (setq aidermacs--block-end-marker nil
        aidermacs--last-output-start nil
        aidermacs--block-start nil
        aidermacs--block-end nil))

(defun aidermacs-fontify-blocks (_output)
  "fontify search/replace blocks in comint output."
  (save-excursion
    (goto-char (or aidermacs--last-output-start
                   comint-last-output-start))
    (beginning-of-line)

    ;; Continue processing existing block if we're in one
    (when aidermacs--block-start
      (aidermacs--fontify-block))

    (setq aidermacs--last-output-start nil)
    ;; Look for new blocks if we're not in one
    (while (and (null aidermacs--block-start)
                (null aidermacs--last-output-start)
                (re-search-forward aidermacs-block-re nil t))

      ;; If it is code fence marker, we need to check if there is a SEARCH marker
      ;; directly after it
      (when (equal (match-string 1) aidermacs-fence-marker)
        (let* ((next-line (min (point-max) (1+ (line-end-position))))
               (line-text (buffer-substring
                           next-line
                           (min (point-max) (+ next-line (length aidermacs-search-marker))))))
          (cond ((equal line-text aidermacs-search-marker)
                 ;; Next line is a SEARCH marker. use that instead of the fence marker
                 (re-search-forward (format "^\\(%s\\)" aidermacs-search-marker) nil t))
                ((string-prefix-p line-text aidermacs-search-marker)
                 ;; Next line *might* be a SEARCH marker. Don't process more of
                 ;; the buffer until we know for sure
                 (setq aidermacs--last-output-start comint-last-output-start)))))

      (unless aidermacs--last-output-start
        ;; Set up new block state
        (setq aidermacs--block-end-marker
              (pcase (match-string 1)
                ((pred (equal aidermacs-search-marker)) aidermacs-diff-marker)
                ((pred (equal aidermacs-diff-marker)) aidermacs-replace-marker)
                ((pred (equal aidermacs-fence-marker)) aidermacs-fence-marker))
              aidermacs--block-start (line-end-position)
              aidermacs--block-end (line-end-position)
              aidermacs--block-mode (aidermacs--guess-major-mode))

        ;; Set the major-mode of the font lock buffer
        (let ((mode aidermacs--block-mode))
          (with-current-buffer aidermacs--font-lock-buffer
            (erase-buffer)
            (unless (eq mode major-mode)
              (condition-case e
                  (let ((inhibit-message t))
                    (funcall mode))
                (error "aidermacs: failed to init major-mode `%s' for font-locking: %s" mode e)))))

        ;; Process initial content
        (aidermacs--fontify-block)))))

(defun aidermacs--fontify-block ()
  "Fontify as much of the current source block as possible."
  (let* ((last-bol (save-excursion
                     (goto-char (point-max))
                     (line-beginning-position)))
         (last-output-start aidermacs--block-end)
         end-of-block-p)

    (setq aidermacs--block-end
          (cond ((re-search-forward (concat "^" aidermacs--block-end-marker "$") nil t)
                 ;; Found the end of the block
                 (setq end-of-block-p t)
                 (line-beginning-position))
                ((string-prefix-p (buffer-substring last-bol (point-max)) aidermacs--block-end-marker)
                 ;; The end of the text *might* be the end marker. back up to
                 ;; make sure we don't process it until we know for sure
                 last-bol)
                ;; We can process till the end of the text
                (t (point-max))))

    ;; Append new content to temp buffer and fontify
    (let ((new-content (buffer-substring-no-properties
                        last-output-start
                        aidermacs--block-end))
          (pos aidermacs--block-start)
          (font-pos 0)
          fontified)

      ;; Insert the new text and get the fontified result
      (with-current-buffer aidermacs--font-lock-buffer
        (goto-char (point-max))
        (insert new-content)
        (with-demoted-errors "aidermacs block font lock error: %s"
          (let ((inhibit-message t))
            (font-lock-ensure)))
        (setq fontified (buffer-string)))

      ;; Apply the faces to the buffer
      (remove-overlays aidermacs--block-start aidermacs--block-end)
      (while (< pos aidermacs--block-end)
        (let* ((next-font-pos (or (next-property-change font-pos fontified) (length fontified)))
               (next-pos (+ aidermacs--block-start next-font-pos))
               (face (get-text-property font-pos 'face fontified)))
          (ansi-color-apply-overlay-face pos next-pos face)
          (setq pos next-pos
                font-pos next-font-pos))))

    ;; If we found the end marker, finalize the block
    (when end-of-block-p
      (when (equal aidermacs--block-end-marker aidermacs-diff-marker)
        ;; we will need to process the other half of the SEARCH/REPLACE block.
        ;; Backup so it will get matched
        (beginning-of-line))
      (aidermacs-reset-font-lock-state))))

(defun aidermacs--guess-major-mode ()
  "Extract the major mode from fence markers or filename."
  (save-excursion
    (beginning-of-line)
    (or
     ;; check if the block has a language id
     (when (let ((re "^```\\([^[:space:]]+\\)"))
             (or (looking-at re)
                 (save-excursion
                   (forward-line -1)
                   ;; check the previous line since this might be a SEARCH block
                   (looking-at re))))
       (let* ((lang (downcase (match-string 1)))
              (mode (map-elt aidermacs-language-name-map lang lang)))
         (intern-soft (concat mode "-mode"))))
     ;; check the file extension in auto-mode-alist
     (when (re-search-backward "^\\([^[:space:]]+\\)" (line-beginning-position -3) t)
       (let ((file (match-string 1)))
         (cdr (cl-assoc-if (lambda (re) (string-match re file)) auto-mode-alist))))
     aidermacs--block-mode
     'fundamental-mode)))

;; Function to switch to the aidermacs buffer
;;;###autoload
(defun aidermacs-switch-to-buffer ()
  "Switch to the aidermacs buffer.
When `aidermacs--switch-to-buffer-other-frame' is non-nil, open in a new frame.
If the current buffer is already the aidermacs buffer, do nothing."
  (interactive)
  (if (string= (buffer-name) (aidermacs-buffer-name))
      (message "Already in aidermacs buffer")
    (if-let ((buffer (get-buffer (aidermacs-buffer-name))))
        (if aidermacs--switch-to-buffer-other-frame
            (switch-to-buffer-other-frame buffer)
          (pop-to-buffer buffer))
      (message "Buffer '%s' does not exist." (aidermacs-buffer-name)))))

;; Function to reset the aidermacs buffer
;;;###autoload
(defun aidermacs-clear ()
  "Send the command \"/clear\" to the aidermacs buffer."
  (interactive)
  (aidermacs--send-command "/clear"))

;;;###autoload
(defun aidermacs-reset ()
  "Send the command \"/reset\" to the aidermacs buffer."
  (interactive)
  (aidermacs--send-command "/reset"))

;;;###autoload
(defun aidermacs-exit ()
  "Send the command \"/exit\" to the aidermacs buffer."
  (interactive)
  (aidermacs--send-command "/exit"))

(defun aidermacs--comint-send-string-syntax-highlight (buffer text)
  "Send TEXT to the comint BUFFER with syntax highlighting.
This function ensures proper syntax highlighting by inheriting face properties
from the source buffer and maintaining proper process markers."
  (with-current-buffer buffer
    (let ((process (get-buffer-process buffer))
          (inhibit-read-only t))
      (goto-char (process-mark process))
      ;; Insert text with proper face properties
      (insert (propertize text
                          'face 'aidermacs-command-text
                          'font-lock-face 'aidermacs-command-text
                          'rear-nonsticky t))
      ;; Update process mark and send text
      (set-marker (process-mark process) (point))
      (comint-send-string process text))))

(defun aidermacs--process-message-if-multi-line (str)
  "Entering multi-line chat messages
https://aidermacs.chat/docs/usage/commands.html#entering-multi-line-chat-messages
If STR contains newlines and isn't already wrapped in {aidermacs...aidermacs},
wrap it in {aidermacs\nstr\naidermacs}. Otherwise return STR unchanged."
  (if (and (string-match-p "\n" str)
           (not (string-match-p "^{aidermacs\n.*\naidermacs}$" str)))
      (format "{aidermacs\n%s\naidermacs}" str)
    str))

;;;###autoload
(defun aidermacs-add-or-read-current-file (command-prefix)
  "Send the command \"COMMAND-PREFIX <current buffer file full path>\" to the corresponding aidermacs comint buffer."
  ;; Ensure the current buffer is associated with a file
  (if (not buffer-file-name)
      (message "Current buffer is not associated with a file.")
    (let* ((file-path (buffer-file-name))
           ;; Use buffer-file-name directly
           (formatted-path (if (string-match-p " " file-path)
                               (format "\"%s\"" file-path)
                             file-path))
           (command (format "%s %s" command-prefix formatted-path)))
      ;; Use the shared helper function to send the command
      (aidermacs--send-command command))))

;; Function to send "/add <current buffer file full path>" to corresponding aidermacs buffer
;;;###autoload
(defun aidermacs-add-current-file ()
  "Send the command \"/add <current buffer file full path>\" to the corresponding aidermacs comint buffer."
  (interactive)
  (aidermacs-add-or-read-current-file (aidermacs--get-add-command-prefix)))

;;;###autoload
(defun aidermacs-current-file-read-only ()
  "Send the command \"/read-only <current buffer file full path>\" to the corresponding aidermacs comint buffer."
  (interactive)
  (aidermacs-add-or-read-current-file "/read-only"))

;; New function to add files in all buffers in current emacs window
;;;###autoload
(defun aidermacs-add-files-in-current-window ()
  "Add files in all buffers in the current Emacs window to the aidermacs buffer."
  (interactive)
  (let ((files (mapcar (lambda (buffer)
                         (with-current-buffer buffer
                           (when buffer-file-name
                             (expand-file-name buffer-file-name))))
                       (mapcar 'window-buffer (window-list)))))
    (setq files (delq nil files))
    (if files
        (let ((command (concat (aidermacs--get-add-command-prefix) " " (mapconcat 'identity files " "))))
          (aidermacs--send-command command nil))
      (message "No files found in the current window."))))

;; Function to send a custom command to corresponding aidermacs buffer
;;;###autoload
(defun aidermacs-general-command ()
  "Prompt the user to input COMMAND and send it to the corresponding aidermacs comint buffer."
  (interactive)
  (let ((command (aidermacs-read-string "Enter command to send to aidermacs: ")))
    ;; Use the shared helper function to send the command
    (aidermacs--send-command command t)))

;; New function to get command from user and send it prefixed with "/code "
;;;###autoload
(defun aidermacs-code-change ()
  "Prompt the user for a command and send it to the corresponding aidermacs comint buffer prefixed with \"/code \"."
  (interactive)
  (let ((command (aidermacs-read-string "Enter code change requirement: ")))
    (aidermacs-send-command-with-prefix "/code " command)))

;; New function to get command from user and send it prefixed with "/ask "
;;;###autoload
(defun aidermacs-ask-question ()
  "Prompt the user for a command and send it to the corresponding aidermacs comint buffer prefixed with \"/ask \".
If a region is active, append the region text to the question.
If cursor is inside a function, include the function name as context."
  (interactive)
  ;; Dispatch to general question if in aidermacs buffer
  (when (string= (buffer-name) (aidermacs-buffer-name))
    (call-interactively 'aidermacs-general-question)
    (cl-return-from aidermacs-ask-question))

  (let* ((function-name (which-function))
         (initial-input (when function-name
                          (format "About function '%s': " function-name)))
         (question (aidermacs-read-string "Enter question to ask: " initial-input))
         (region-text (and (region-active-p)
                           (buffer-substring-no-properties (region-beginning) (region-end))))
         (command (if region-text
                      (format "/ask %s: %s" question region-text)
                    (format "/ask %s" question))))
    (aidermacs-add-current-file)
    (aidermacs--send-command command t)))

;;;###autoload
(defun aidermacs-general-question ()
  "Prompt the user for a general question and send it to the corresponding aidermacs comint buffer prefixed with \"/ask \"."
  (interactive)
  (let ((question (aidermacs-read-string "Enter general question to ask: ")))
    (let ((command (format "/ask %s" question)))
      (aidermacs--send-command command t))))

;; New function to get command from user and send it prefixed with "/help "
;;;###autoload
(defun aidermacs-help ()
  "Prompt the user for a command and send it to the corresponding aidermacs comint buffer prefixed with \"/help \"."
  (interactive)
  (let ((command (aidermacs-read-string "Enter help question: ")))
    (aidermacs-send-command-with-prefix "/help " command)))

;; New function to get command from user and send it prefixed with "/architect "
;;;###autoload
(defun aidermacs-architect-discussion ()
  "Prompt the user for a command and send it to the corresponding aidermacs comint buffer prefixed with \"/architect \"."
  (interactive)
  (let ((command (aidermacs-read-string "Enter architect discussion question: ")))
    (aidermacs-send-command-with-prefix "/architect " command)))

;; New function to get command from user and send it prefixed with "/ask ", might be tough for AI at this moment
;;;###autoload
(defun aidermacs-debug-exception ()
  "Prompt the user for a command and send it to the corresponding aidermacs comint buffer prefixed with \"/debug \",
replacing all newline characters except for the one at the end."
  (interactive)
  (let ((command (aidermacs-plain-read-string "Enter exception, can be multiple lines: ")))
    (aidermacs--send-command (concat "/ask Investigate the following exception, with current added files as context: " command) t)))

;;;###autoload
(defun aidermacs-go-ahead ()
  "Send the command \"go ahead\" to the corresponding aidermacs comint buffer."
  (interactive)
  (aidermacs--send-command "go ahead" t))

;; New function to show the last commit using magit
;;;###autoload
(defun aidermacs-magit-show-last-commit ()
  "Show the last commit message using Magit.
If Magit is not installed, report that it is required."
  (interactive)
  (if (require 'magit nil 'noerror)
      (magit-show-commit "HEAD")
    (message "Magit is required to show the last commit.")))

;; Modified function to get command from user and send it based on selected region
;;;###autoload
(defun aidermacs-undo-last-change ()
  "Undo the last change made by aidermacs."
  (interactive)
  (aidermacs--send-command "/undo"))

;;;###autoload
(defun aidermacs-function-or-region-refactor ()
  "Refactor code at point or region.
If region is active, refactor that region.
If point is in a function, refactor that function."
  (interactive)
  (if (use-region-p)
      (let* ((region-text (buffer-substring-no-properties (region-beginning) (region-end)))
             (function-name (which-function))
             (user-command (aidermacs-read-string "Enter refactor instruction: "))
             (command (if function-name
                          (format "/architect \"in function %s, for the following code block, %s: %s\"\n"
                                  function-name user-command region-text)
                        (format "/architect \"for the following code block, %s: %s\"\n"
                                user-command region-text))))
        (aidermacs-add-current-file)
        (aidermacs--send-command command t))
    (if-let ((function-name (which-function)))
        (let* ((initial-input (format "refactor %s: " function-name))
               (user-command (aidermacs-read-string "Enter refactor instruction: " initial-input))
               (command (format "/architect %s" user-command)))
          (aidermacs-add-current-file)
          (aidermacs--send-command command t))
      (message "No region selected and no function found at point."))))

;; New function to explain the code in the selected region
;;;###autoload
(defun aidermacs-region-explain ()
  "Get a command from the user and send it to the corresponding aidermacs comint buffer based on the selected region.
The command will be formatted as \"/ask \" followed by the text from the selected region."
  (interactive)
  (if (use-region-p)
      (let* ((region-text (buffer-substring-no-properties (region-beginning) (region-end)))
             (function-name (which-function))
             (processed-region-text region-text)
             (command (if function-name
                          (format "/ask in function %s, explain the following code block: %s"
                                  function-name
                                  processed-region-text)
                        (format "/ask explain the following code block: %s"
                                processed-region-text))))
        (aidermacs-add-current-file)
        (aidermacs--send-command command t))
    (message "No region selected.")))

;; New function to ask aidermacs to explain the function under the cursor
;;;###autoload
(defun aidermacs-function-explain ()
  "Ask aidermacs to explain the function under the cursor.
Prompts user for specific questions about the function."
  (interactive)
  (if-let ((function-name (which-function)))
      (let* ((initial-input (format "explain %s: " function-name))
             (user-question (aidermacs-read-string "Enter your question about the function: " initial-input))
             (command (format "/ask %s" user-question)))
        (aidermacs-add-current-file)
        (aidermacs--send-command command t))
    (message "No function found at cursor position.")))

;;;###autoload
(defun aidermacs-function-or-region-explain ()
  "Call aidermacs-function-explain when no region is selected, otherwise call aidermacs-region-explain."
  (interactive)
  (if (region-active-p)
      (aidermacs-region-explain)
    (aidermacs-function-explain)))

;; New function to explain the symbol at line
;;;###autoload
(defun aidermacs-explain-symbol-under-point ()
  "Ask aidermacs to explain symbol under point, given the code line as background info."
  (interactive)
  (let* ((symbol (thing-at-point 'symbol))
         (line (buffer-substring-no-properties
                (line-beginning-position)
                (line-end-position)))
         (prompt (format "/ask Please explain what '%s' means in the context of this code line: %s"
                         symbol line)))
    (aidermacs-add-current-file)
    (aidermacs--send-command prompt t)))

(defun aidermacs-send-command-with-prefix (prefix command)
  "Send COMMAND to the aidermacs buffer prefixed with PREFIX."
  (aidermacs-add-current-file)
  (aidermacs--send-command (concat prefix command) t))

;;; functions for dired related

;; New function to add multiple Dired marked files to aidermacs buffer
;;;###autoload
(defun aidermacs-batch-add-dired-marked-files ()
  "Add multiple Dired marked files to the aidermacs buffer with the \"/add\" command."
  (interactive)
  (let ((files (dired-get-marked-files)))
    (if files
        (let ((command (concat (aidermacs--get-add-command-prefix) " " (mapconcat 'expand-file-name files " "))))
          (aidermacs--send-command command t))
      (message "No files marked in Dired."))))

;; New function to add all files with same suffix as current file under current directory
;;;###autoload
(defun aidermacs-add-same-type-files-under-dir ()
  "Add all files with same suffix as current file under current directory to aidermacs.
If there are more than 40 files, refuse to add and show warning message."
  (interactive)
  (if (not buffer-file-name)
      (message "Current buffer is not visiting a file")
    (let* ((current-suffix (file-name-extension buffer-file-name))
           (dir (file-name-directory buffer-file-name))
           (max-files 40)
           (files (directory-files dir t
                                   (concat "\\." current-suffix "$")
                                   t))) ; t means don't include . and ..
      (if (> (length files) max-files)
          (message "Too many files (%d, > %d) found with suffix .%s. Aborting."
                   (length files) max-files current-suffix)
        (let ((command (concat (aidermacs--get-add-command-prefix) " " (mapconcat 'identity files " "))))
          (aidermacs--send-command command t))
        (message "Added %d files with suffix .%s"
                 (length files) current-suffix)))))

;;; functions for test fixing

;;;###autoload
(defun aidermacs-write-unit-test ()
  "Generate unit test code for current buffer.
Do nothing if current buffer is not visiting a file.
If current buffer filename contains 'test':
  - If cursor is inside a test function, implement that test
  - Otherwise show message asking to place cursor inside a test function
Otherwise:
  - If cursor is on a function, generate unit test for that function
  - Otherwise generate unit tests for the entire file"
  (interactive)
  (if (not buffer-file-name)
      (message "Current buffer is not visiting a file.")
    (let ((is-test-file (string-match-p "test" (file-name-nondirectory buffer-file-name)))
          (function-name (which-function)))
      (cond
       ;; Test file case
       (is-test-file
        (if function-name
            (if (string-match-p "test" function-name)
                (let* ((initial-input
                        (format "Please implement test function '%s'. Follow standard unit testing practices and make it a meaningful test. Do not use Mock if possible."
                                function-name))
                       (user-command (aidermacs-read-string "Test implementation instruction: " initial-input))
                       (command (format "/architect %s" user-command)))
                  (aidermacs-add-current-file)
                  (aidermacs--send-command command t))
              (message "Current function '%s' does not appear to be a test function." function-name))
          (message "Please place cursor inside a test function to implement.")))
       ;; Non-test file case
       (t
        (let* ((common-instructions "Keep existing tests if there are. Follow standard unit testing practices. Do not use Mock if possible.")
               (initial-input
                (if function-name
                    (format "Please write unit test code for function '%s'. %s"
                            function-name common-instructions)
                  (format "Please write unit test code for file '%s'. For each function %s"
                          (file-name-nondirectory buffer-file-name) common-instructions)))
               (user-command (aidermacs-read-string "Unit test generation instruction: " initial-input))
               (command (format "/architect %s" user-command)))
          (aidermacs-add-current-file)
          (aidermacs--send-command command t)))))))

;;;###autoload
(defun aidermacs-fix-failing-test-under-cursor ()
  "Report the current test failure to aidermacs and ask it to fix the code.
This function assumes the cursor is on or inside a test function."
  (interactive)
  (if-let ((test-function-name (which-function)))
      (let* ((initial-input (format "The test '%s' is failing. Please analyze and fix the code to make the test pass. Don't break any other test"
                                    test-function-name))
             (test-output (aidermacs-read-string "Architect question: " initial-input))
             (command (format "/architect %s" test-output)))
        (aidermacs-add-current-file)
        (aidermacs--send-command command t))
    (message "No test function found at cursor position.")))

(defun aidermacs--is-comment-line (line)
  "Check if LINE is a comment line based on current buffer's comment syntax.
Returns non-nil if LINE starts with one or more comment characters,
ignoring leading whitespace."
  (when comment-start
    (let ((comment-str (string-trim-right comment-start)))
      (string-match-p (concat "^[ \t]*"
                              (regexp-quote comment-str)
                              "+")
                      (string-trim-left line)))))

;;;###autoload
(defun aidermacs-implement-todo ()
  "Implement TODO comments in current context.
If region is selected, implement that specific region.
If cursor is on a comment line, implement that specific comment.
If cursor is inside a function, implement TODOs for that function.
Otherwise implement TODOs for the entire current file."
  (interactive)
  (if (not buffer-file-name)
      (message "Current buffer is not visiting a file.")
    (let* ((current-line (string-trim (thing-at-point 'line t)))
           (is-comment (aidermacs--is-comment-line current-line))
           (function-name (which-function))
           (region-text (when (region-active-p)
                          (buffer-substring-no-properties
                           (region-beginning)
                           (region-end))))
           (initial-input
            (cond
             (region-text
              (format "Please implement this code block: '%s'. It is already inside current code. Please do in-place implementation. Keep the existing code structure and implement just this specific block."
                      region-text))
             (is-comment
              (format "Please implement this comment: '%s'. It is already inside current code. Please do in-place implementation. Keep the existing code structure and implement just this specific comment."
                      current-line))
             (function-name
              (format "Please implement the TODO items in function '%s'. Keep the existing code structure and only implement the TODOs in comments."
                      function-name))
             (t
              (format "Please implement all TODO items in file '%s'. Keep the existing code structure and only implement the TODOs in comments."
                      (file-name-nondirectory buffer-file-name)))))
           (user-command (aidermacs-read-string "TODO implementation instruction: " initial-input))
           (command (format "/architect %s" user-command)))
      (aidermacs-add-current-file)
      (aidermacs--send-command command t))))


;;; functions for sending text blocks

;; New function to send "<line under cursor>" or region line by line to the aidermacs buffer
;;;###autoload
(defun aidermacs-send-line-or-region ()
  "Send text to the aidermacs buffer.
If region is active, send the selected region line by line.
Otherwise, send the line under cursor."
  (interactive)
  (if (region-active-p)
      (aidermacs-send-region-by-line)
    (let ((line (thing-at-point 'line t)))
      (aidermacs--send-command (string-trim line) t))))

;;; New function to send the current selected region line by line to the aidermacs buffer
;;;###autoload
(defun aidermacs-send-region-by-line ()
  "Get the text of the current selected region, split them into lines,
strip the newline character from each line,
for each non-empty line, send it to aidermacs session.
If no region is selected, show a message."
  (interactive)
  (if (region-active-p)
      (let ((region-text (buffer-substring-no-properties
                          (region-beginning)
                          (region-end))))
        (mapc (lambda (line)
                (unless (string-empty-p line)
                  (aidermacs--send-command line t)))
              (split-string region-text "\n" t)))
    (message "No region selected.")))

;;;###autoload
(defun aidermacs-send-block-or-region ()
  "Send the current active region text or, if no region is active, send the current paragraph content to the aidermacs session.
When sending paragraph content, preserve cursor position and deactivate mark afterwards."
  (interactive)
  (if (region-active-p)
      (let ((region-text (buffer-substring-no-properties (region-beginning) (region-end))))
        (unless (string-empty-p region-text)
          (aidermacs--send-command region-text t)))
    (save-excursion  ; preserve cursor position
      (let ((region-text
             (progn
               (mark-paragraph)  ; mark paragraph
               (buffer-substring-no-properties (region-beginning) (region-end)))))
        (unless (string-empty-p region-text)
          (aidermacs--send-command region-text t))
        (deactivate-mark)))))  ; deactivate mark after sending

;;;###autoload
(defun aidermacs-open-prompt-file ()
  "Open aidermacs prompt file under git repo root.
If file doesn't exist, create it with command binding help and sample prompt."
  (interactive)
  (let* ((git-root (vc-git-root default-directory))
         (prompt-file (when git-root
                        (expand-file-name aidermacs-prompt-file-name git-root))))
    (if prompt-file
        (progn
          (find-file-other-window prompt-file)
          (unless (file-exists-p prompt-file)
            ;; Insert initial content for new file
            (insert "# aidermacs Prompt File - Command Reference:\n")
            (insert "# C-c C-n or C-<return>: Send current line or selected region line by line\n")
            (insert "# C-c C-c: Send current block or selected region as a whole\n")
            (insert "# C-c C-z: Switch to aidermacs buffer\n\n")
            (insert "* Sample task:\n\n")
            (insert "/ask what this repo is about?\n")
            (save-buffer)))
      (message "Not in a git repository"))))

;; Define the keymap for aidermacs Minor Mode
(defvar aidermacs-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-n") 'aidermacs-send-line-or-region)
    (define-key map (kbd "C-<return>") 'aidermacs-send-line-or-region)
    (define-key map (kbd "C-c C-c") 'aidermacs-send-block-or-region)
    (define-key map (kbd "C-c C-z") 'aidermacs-switch-to-buffer)
    map)
  "Keymap for aidermacs Minor Mode.")

;; Define the aidermacs Minor Mode
;;;###autoload
(define-minor-mode aidermacs-minor-mode
  "Minor mode for aidermacs with keybindings."
  :lighter " aidermacs"
  :keymap aidermacs-minor-mode-map
  :override t)

;; Auto-enable aidermacs-minor-mode for specific files
(defcustom aidermacs-auto-mode-files
  (list
   aidermacs-prompt-file-name    ; Default prompt file
   ".aider.chat.md"
   ".aider.chat.history.md"
   ".aider.input.history")
  "List of filenames that should automatically enable `aidermacs-minor-mode'.
These are exact filename matches (including the dot prefix)."
  :type '(repeat string)
  :group 'aidermacs)

(defun aidermacs--should-enable-minor-mode-p (filename)
  "Determine if aidermacs-minor-mode should be enabled for FILENAME.
Returns t if the file matches any of the patterns in `aidermacs-auto-mode-files'."
  (when filename
    (let ((base-name (file-name-nondirectory filename)))
      (member base-name aidermacs-auto-mode-files))))

(add-hook 'find-file-hook
          (lambda ()
            (when (and buffer-file-name
                       (aidermacs--should-enable-minor-mode-p buffer-file-name))
              (aidermacs-minor-mode 1))))

(provide 'aidermacs)

;;; aidermacs.el ends here
