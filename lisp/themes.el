;; Protesilaos Stavrou's excellent high contrast themes, perfect for working in
;; bright sunlight (especially on my laptop's dim screen).
(use-package modus-themes
  :ensure nil
  :defer
  :init
  (setq modus-themes-common-palette-overrides
        `((date-common cyan)   ; default value (for timestamps and more)
          (date-deadline red-warmer)
          (date-event magenta-warmer)
          (date-holiday blue) ; for M-x calendar
          (date-now yellow-warmer)
          (date-scheduled magenta-cooler)
          (date-weekday cyan-cooler)
          (date-weekend blue-faint)
          (mail-recipient fg-main)
          ;; (fg-heading-1 blue-warmer)
          ;; (fg-heading-2 yellow-cooler)
          ;; (fg-heading-3 cyan-cooler)
          ;; (fg-line-number-inactive "gray50")
          (fg-line-number-active fg-main)
          (bg-line-number-inactive unspecified)
          (bg-line-number-active unspecified)
          (bg-region bg-sage)
          (fg-region unspecified)
          ;; (comment yellow-cooler)
          ;; (string green-cooler)
          (fringe unspecified) ;; bg-blue-nuanced
          (border-mode-line-active unspecified)
          (border-mode-line-inactive unspecified)))
  (setq modus-operandi-palette-overrides
        '((bg-mode-line-active bg-blue-intense) ;
          (fg-mode-line-active fg-main)
          (fg-heading-1 "#a01f64")
          (fg-heading-2 "#2f5f9f") ;;"#193668"
          (fg-heading-3 "#1a8388")))
  (setq modus-vivendi-palette-overrides
        `((fg-main "#d6d6d4")
          ;; (bg-main "#121212")
          (bg-region bg-lavender)
          (bg-main "#090909")
          (fg-heading-1 magenta-faint)
          ;; (bg-main "#181A1B")
          (bg-mode-line-active bg-lavender) ;; bg-graph-magenta-1
          (fg-mode-line-active "#ffffff")))
  (setq modus-themes-org-blocks 'gray-background
        modus-themes-bold-constructs t
        modus-themes-prompts '(bold background)
        modus-themes-variable-pitch-ui nil
        modus-themes-headings
        '((0 . (1.35))
          (1 . (1.30))       ;variable-pitch
          (2 . (1.24))       ;variable-pitch
          (3 . (semibold 1.17))
          (4 . (1.14))
          (t . (monochrome)))))
