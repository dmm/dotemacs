;;; CONFIGURATION for planner mode

(setq planner-project "dmm's life")
(setq muse-project-alist
      '(("dmm's life"
	 ("~/plans" ;; Or wherever you want your planner files to be
	  :default "TaskPool"
	  :major-mode planner-mode
	  :visit-link planner-visit-link)
	 (:base "planner-xhtml"
		;; where files are published to
		;; (the value of `planner-publishing-directory', if
		;;  you have a configuration for an older version
		;;  of Planner)
		:path "~/plans/pub"))))

(require 'muse)
(require 'planner)
(require 'planner-w3m)
(require 'planner-id)
(require 'planner-cyclic)
(require 'planner-publish)
(require 'remember-planner)

(setq planner-xhtml-header "")
(setq planner-xhtml-footer "")

; Planner mode settings
(setq remember-handler-functions '(remember-planner-append))
(setq remember-annotation-functions planner-annotation-functions)

;Cyclic setting
(setq planner-cyclic-diary-file "~/plans/cyclic-tasks")

