 ;;; Configuration for gnus

(require 'gnus)

(setq gnus-select-method '(nntp "news.kc.sbcglobal.net"))



(setq gnus-secondary-select-methods
      '(
	(nnimap "minermail"
		(nnimap-address "minermail.mst.edu")
		(nnimap-server-port 993)
		(nnimap-stream tls)
		(nnimap-list-pattern "INBOX" "INBOX.*")
		(nnimap-authinfo-file "/home/dmm/.imap-authinfo"))

	(nnimap "mattli.us"
		(nnimap-address "mattli.us")
		(nnimap-server-port 993)
		(nnimap-stream tls)
		(remove-prefix "INBOX.")
		(nnimap-list-pattern "INBOX" "INBOX.*")
;		(nnimap-list-pattern "INBOX")
		(nnimap-authinfo-file "/home/dmm/.imap-authinfo")
		)

	)
      )


(setq gnus-secondary-select-methods
      '(
	(nnimap "mattli.us"
		(nnimap-address "mattlimech.com")
		(nnimap-server-port 993)
		(nnimap-stream tls))))
		
		
(setq nnimap-expunge-on-close "never")
(setq gnus-permanently-visible-groups "e") ;Always display subscribed groups with e in name ;)


