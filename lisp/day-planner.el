;;; day-planner.el --- Wiegley-style org day planner  -*- lexical-binding: t; -*-

;; Port of https://newartisans.com/2007/08/using-org-mode-as-a-day-planner/
;; to modern Org, with an Orgzly-fed mobile capture inbox.
;;
;; Requires Emacs 29+ for `keymap-global-set'.

(require 'org)
(require 'org-agenda)
(require 'org-capture)
(require 'seq)


;;;; Paths

(defvar dp-org-directory "~/share/org/"
  "Directory holding the planner files.  Synced by Syncthing.")

(defvar dp-todo-file (expand-file-name "todo.org" dp-org-directory))
(defvar dp-notes-file (expand-file-name "notes.org" dp-org-directory))

(defvar dp-mobile-inbox-file (expand-file-name "mobile-inbox.org" dp-org-directory)
  "Append-only capture file.  Orgzly is its ONLY writer.  Emacs reads it.")

(defvar dp-inbox-heading "Tasks"
  "Top-level heading in `dp-todo-file' that drained entries land under.")

(defvar dp-drain-state-file (locate-user-emacs-file "mobile-drain-state.eld")
  "Record of already-drained entries.  Must live OUTSIDE the synced directory.")


;;;; Base configuration

;; Note: `dp-mobile-inbox-file' is deliberately absent.  Drained entries remain
;; in it forever, so including it would double-count every task.
(setq org-agenda-files (list dp-todo-file dp-notes-file)
      org-default-notes-file dp-notes-file

      ;; Modern equivalent of Wiegley's `org-todo-state-map'.  Everything
      ;; after `|' is a terminal state and is reviewed before archiving.
      org-todo-keywords
      '((sequence "TODO(t)" "DOING(s)" "WAIT(w)" "TASK(l)"
                  "|" "DONE(d)" "DEFER(f)" "CANCELLED(x)"))

      org-agenda-span 7                    ; was org-agenda-ndays
      org-agenda-start-on-weekday nil      ; always start today
      org-deadline-warning-days 14
      org-agenda-show-all-dates t          ; makes free days visible
      org-agenda-skip-deadline-if-done t
      org-agenda-skip-scheduled-if-done t

      org-fast-tag-selection-single-key 'expert
      org-log-into-drawer t                ; state notes into :LOGBOOK:
      org-archive-location "archive.org::* From %s"

      ;; Replaces his cut-and-paste filing step.
      org-refile-targets '((nil :level . 1))
      org-refile-target-verify-function #'dp-refile-verify
      org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil)

;; The fast-access letters above give you `C-c C-t s' directly, and plain `t'
;; followed by the letter in the agenda.  Likewise `org-agenda-keymap' no
;; longer exists, so his C-n/C-p rebinds only need org-agenda-mode-map.
(with-eval-after-load 'org-agenda
  (keymap-set org-agenda-mode-map "C-n" #'next-line)
  (keymap-set org-agenda-mode-map "C-p" #'previous-line))


;;;; Capture

;; `:prepend t' replaces the global `org-reverse-note-order'.
;; `org-remember-store-without-prompt' has no successor -- capture templates
;; always name their target, so the behaviour is now unconditional.
(setq org-capture-templates
      `(("t" "Task" entry
         (file+headline ,dp-todo-file ,dp-inbox-heading)
         "* TODO %?\n%u"
         :prepend t)
        ("n" "Note" entry
         (file+headline ,dp-notes-file "Notes")
         "* %u %?"
         :prepend t)))


;;;; Agenda views
;;
;; His five separate reports (d/c/w/W/A/u) collapse into two block commands.

(setq org-agenda-custom-commands
      '(("r" "Nightly review"
         ((alltodo ""
                   ((org-agenda-overriding-header "Unfiled / unscheduled")
                    (org-agenda-skip-function
                     '(org-agenda-skip-entry-if 'scheduled 'deadline 'timestamp))))
          (todo "DONE|DEFER|CANCELLED"
                ((org-agenda-overriding-header "Ready to archive")))
          (todo "WAIT"
                ((org-agenda-overriding-header "Waiting on something")))
          (agenda ""
                  ((org-agenda-span 7)
                   (org-agenda-overriding-header "Next seven days")))))

        ("d" "Today"
         ((agenda ""
                  ((org-agenda-span 1)
                   (org-agenda-overriding-header "Today's #A tasks")
                   (org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'notregexp "\\[#A\\]"))))
          (agenda ""
                  ((org-agenda-span 1)
                   (org-agenda-overriding-header "Everything else today")
                   (org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'regexp "\\[#A\\]"))))))

        ("W" "Next three weeks" agenda ""
         ((org-agenda-span 21)))))


;;;; Mobile inbox drain
;;
;; Non-destructive by design.  Emacs never writes to `dp-mobile-inbox-file',
;; so the "both local and remote modified" failure mode is structurally
;; impossible.  Truncate the file on the phone, in Orgzly, where it is
;; authoritative.
;;
;; Entries are identified by a hash of their full text.  Two captures with
;; identical text AND no distinguishing timestamp will be treated as one, so
;; enable Orgzly's created-time property to disambiguate them.

(defun dp--drain-state ()
  "Return a hash table of entry hashes already drained."
  (let ((table (make-hash-table :test #'equal)))
    (when (file-readable-p dp-drain-state-file)
      (with-temp-buffer
        (insert-file-contents dp-drain-state-file)
        (dolist (h (ignore-errors (read (current-buffer))))
          (puthash h t table))))
    table))

(defun dp--save-drain-state (table)
  "Persist the keys of TABLE to `dp-drain-state-file'."
  (let ((keys nil))
    (maphash (lambda (k _v) (push k keys)) table)
    (with-temp-file dp-drain-state-file
      (let ((print-length nil) (print-level nil))
        (prin1 keys (current-buffer))))))

(defun dp--mobile-entries ()
  "Return an alist of (HASH . TEXT) for each top-level entry in the mobile inbox."
  (let ((buf (find-file-noselect dp-mobile-inbox-file))
        (entries nil))
    (with-current-buffer buf
      ;; Syncthing may have rewritten the file underneath this buffer.  Without
      ;; this the drain silently reads stale content and reports nothing new.
      (unless (verify-visited-file-modtime buf)
        (revert-buffer :ignore-auto :noconfirm))
      (org-with-wide-buffer
       (goto-char (point-min))
       (while (re-search-forward "^\\* " nil t)
         (beginning-of-line)
         (let* ((beg (point))
                (end (save-excursion (org-end-of-subtree t t) (point)))
                (text (string-trim-right
                       (buffer-substring-no-properties beg end))))
           (push (cons (secure-hash 'sha256 text) text) entries)
           (goto-char end)))))
    (nreverse entries)))

(defun dp--normalize-entry ()
  "Clean up the freshly pasted entry at point.  Leaves point on the headline."
  (let ((created (org-entry-get nil "CREATED")))
    ;; Orgzly's default new-note state adds no keyword.
    (unless (org-get-todo-state)
      (let ((org-inhibit-logging t))
        (org-todo "TODO")))
    ;; His date-tagging convention: an inactive timestamp in the body.
    (save-excursion
      (org-end-of-meta-data t)
      (unless (save-excursion
                (re-search-forward org-ts-regexp-inactive
                                   (org-entry-end-position) t))
        (insert (if created
                    (concat created "\n")
                  (format-time-string "[%Y-%m-%d %a]\n")))))
    ;; Drop Orgzly bookkeeping so it does not accumulate in todo.org.
    (dolist (prop '("CREATED" "ID" "ORGZLY_ID"))
      (org-entry-delete nil prop))))

(defun dp-drain-mobile-inbox ()
  "Copy new entries from the mobile inbox into `dp-inbox-heading'.
Does not modify the mobile inbox."
  (interactive)
  (let* ((consumed (dp--drain-state))
         (fresh (seq-remove (lambda (e) (gethash (car e) consumed))
                            (dp--mobile-entries)))
         (count 0))
    (if (null fresh)
        (message "Mobile inbox: nothing new.")
      (with-current-buffer (find-file-noselect dp-todo-file)
        (org-with-wide-buffer
         (goto-char (point-min))
         (unless (re-search-forward
                  (format org-complex-heading-regexp-format
                          (regexp-quote dp-inbox-heading))
                  nil t)
           (user-error "No `%s' heading in %s" dp-inbox-heading dp-todo-file))
         (let ((level (1+ (org-current-level))))
           (org-end-of-subtree t t)
           (dolist (entry fresh)
             (org-paste-subtree level (cdr entry))
             (dp--normalize-entry)
             (puthash (car entry) t consumed)
             (setq count (1+ count))
             (org-end-of-subtree t t))))
        (save-buffer))
      ;; Only recorded once the target file is safely on disk.
      (dp--save-drain-state consumed)
      (message "Mobile inbox: drained %d entr%s."
               count (if (= count 1) "y" "ies")))))

(defun dp-review ()
  "Drain the mobile inbox, then open the nightly review.
In the agenda, schedule unfiled tasks with `org-agenda-schedule' and then
categorize them with `org-agenda-refile'.  Mark tasks that will not be pursued
as DEFER and archive them with the other terminal states."
  (interactive)
  (dp-drain-mobile-inbox)
  (org-agenda nil "r"))

;;;; Refile targets
;;
;; Only the level-1 category and milestone trees are valid destinations, and
;; the inbox itself is excluded so it cannot be a target of its own drain.

(defun dp-refile-verify ()
  "Reject the inbox heading as a refile target."
  (not (equal (org-get-heading t t t t) dp-inbox-heading)))

;;;; Completed task archiving
;;
;; Deliberately a separate command: Wiegley reviews terminal tasks before
;; letting them disappear.  Run it after eyeballing the "Ready to archive"
;; block in the review agenda.

(defun dp-archive-completed ()
  "Archive every DONE, DEFER, or CANCELLED entry across the agenda files."
  (interactive)
  (let ((count 0))
    (org-map-entries
     (lambda ()
       (org-archive-subtree)
       (setq count (1+ count)
             ;; The subtree is gone; resume from where it stood.
             org-map-continue-from (point)))
     "/DONE|DEFER|CANCELLED" 'agenda)
    (message "Archived %d entr%s." count (if (= count 1) "y" "ies"))))



;;;; Keys

(keymap-global-set "C-c a" #'org-agenda)
(keymap-global-set "C-c c" #'org-capture)
(keymap-global-set "C-c R" #'dp-review)
(keymap-global-set "C-c A" #'dp-archive-completed)

(provide 'day-planner)
;;; day-planner.el ends here
