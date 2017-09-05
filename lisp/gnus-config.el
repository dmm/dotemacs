 ;;; Configuration for gnus

(require 'gnus)
(require 'pgg) ;; gpg support



(setq gnus-select-method
      '(nnimap "mattli.us"
		(nnimap-address "mattlimech.com")
		(nnimap-server-port 143)
;		(remove-prefix "INBOX.")
;		(nnimap-authinfo-file "/home/dmm/.imap-authinfo")
		(nnimap-stream starttls)
		)
)
(setq nnimap-expunge-on-close "never")
(setq gnus-permanently-visible-groups "I") ;Always display subscribed groups with e in name ;)



