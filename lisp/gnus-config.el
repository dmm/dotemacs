 ;;; Configuration for gnus

(require 'gnus)

(setq gnus-select-method
          '(nnml ""))
(setq gnus-secondary-select-methods
      '((nnimap "mattli.us"
		     (nnimap-address "home.mattli.us")
		     (nnimap-server-port 993)
		     (nnimap-stream ssl))))

(setq gnus-permanently-visible-groups "I") ;Always display subscribed groups with e in name ;)

(setq gnus-auto-expirable-newsgroups "INBOX")
(setq nnmail-expiry-target 'nnmail-fancy-expiry-target
       nnmail-fancy-expiry-targets
       '(("from" ".*" "nnfolder:Archive.%Y")))

