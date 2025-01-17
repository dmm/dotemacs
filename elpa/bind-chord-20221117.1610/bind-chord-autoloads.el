;;; bind-chord-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from bind-chord.el

(autoload 'bind-chord "bind-chord" "\
Bind CHORD to COMMAND in KEYMAP (`global-map' if not passed).

(fn CHORD COMMAND &optional KEYMAP)" nil t)
(autoload 'bind-chords "bind-chord" "\
Bind multiple chords at once.

Accepts keyword argument:
:map - a keymap into which the keybindings should be added

The rest of the arguments are conses of keybinding string and a
function symbol (unquoted).

(fn &rest ARGS)" nil t)
(register-definition-prefixes "bind-chord" '("bind-chords-form"))

;;; End of scraped data

(provide 'bind-chord-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; bind-chord-autoloads.el ends here
