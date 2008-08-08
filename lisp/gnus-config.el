 ;;; Configuration for gnus

(require 'gnus)

(setq gnus-select-method '(nntp "news.kc.sbcglobal.net"))

(setq gnus-secondary-select-methods
      '(
	(nnimap "minermail"
		(nnimap-address "minermail.mst.edu")
		(nnimap-server-port 993)
		(nnimap-stream ssl))

	(nnimap "mattli.us"
		(nnimap-address "mattli.us")
		(nnimap-server-port 993)
		(nnimap-stream ssl))
	)
      )

(setq nnimap-expunge-on-close "never")
(setq gnus-permanently-visible-groups "e") ;Always display subscribed groups with e in name ;)