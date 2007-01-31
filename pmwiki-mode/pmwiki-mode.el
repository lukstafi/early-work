;;; pmwiki-mode.el --- edit PmWiki pages within Emacs
;;
;; Copyright (C) 2003  Christian Ridderström, 2007 Lukasz Stafiniak
;;
;; Authors:  Christian Ridderström <christian.ridderstrom@home.se>, Lukasz Stafiniak <lukstafi@gmail.com>
;; Maintainer: Lukasz Stafiniak <lukstafi@gmail.com>
;; Release: $Name:  $
;; Revision: $Revision: 1.10 $
;; Keywords: hypermedia
;; URI: http://www.pmwiki.org/wiki/EmacsModes/Pmwiki-mode
;; 
;;
;; This file is not part of GNU Emacs.
;;
;;; License:
;;
;; This is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;;; Commentary:
;;
;; Changelog:
;;
;; v0.1: (2007/01/28) first release: no CamelCase; anchor links
;; v0.2: (2007/01/29) follow URI support, link shortcuts
;; v0.3: (2007/01/31) `mmm-mode' support, `preview-latex' works
;;
;; Background:
;;
;; I've rewritten `pmwiki-mode' to work on articles on my homepage.
;; [lukstafi]
;;
;; `pmwiki-mode' was created because in order to easily edit wiki
;; pages at http://wiki.lyx.org (also see http://www.lyx.org). This
;; site the wiki engine PmWiki (see http://www.pmwiki.org/wiki).
;;
;; `pmwiki-mode' is based on the source of `simple-wiki-mode', i.e.
;; 	simple-emacswiki.el, simple-wiki-edit.el and simple-wiki.el.
;; `simple-wiki-mode' was written by Alex Schroeder <alex@gnu.org>
;; (see http://www.emacswiki.org/cgi-bin/wiki.pl/SimpleWikiEditMode).
;;
;;
;; Requirements:
;;
;; This file has been tested with Emacs 21.2.1, 21.4 and 22 and requires
;; these additional packages:
;;	`http-post'	http://www.emacswiki.org/cgi-bin/wiki.pl/HttpPost
;;	`http-get'	http://www.emacswiki.org/cgi-bin/wiki.pl/HttpGet
;;
;; In addition, this package is useful:
;;	`longlines'	http://www.emacswiki.org/cgi-bin/wiki.pl/LongLines
;;
;; If you downloaded this file as a tar.gz-file, you should already
;; have these packages. Note that the version of `longlines' in the
;; archive has been patched --- this line has been added to the end:
;;	(provide 'longlines)
;; Similarly, a minor change has been done to the `http-post' and
;; `http-get' so that *HTTP...-buffers are not put at the front of the
;; list of recently selected buffers.
;; When you have `mmm-mode' installed, some submode support is added.
;;
;; Installation and basic customization:
;;
;; 1. Assuming that this file is located in the directory
;;
;;	~/emacs/pmwiki-mode/
;;
;;    add these lines to your .emacs-file:
;;
;;	(add-to-list 'load-path "~/emacs/pmwiki-mode")
;;	(require 'pmwiki-mode)
;;
;; 2. If you want `preview-latex' to work, copy the "preamble.tex" file,
;;    or your own LaTeX file, to your _home directory_, and add this line
;;    to your .emacs-file:
;;
;;    (setq pmwiki-TeX-master-file "~/preamble.tex")
;;
;;    where "~/preamble.tex" is the path to your preamble file
;;    (tested under Linux only).
;;
;; 3. In order to edit password protected pages on the LyX wiki, you
;;    also have to add something like this (see the wiki for details):
;;
;;	(set 'pmwiki-uri-transforms
;;	     (list
;;	      '("http://wiki.lyx.org\\(/[A-Z]\\|/?\\?\\)"
;;		"http://wiki.lyx.org"
;;		"http://wiki.lyx.org/pmwiki.php")
;;	      '("http://wiki.lyx.org/pmwiki.php"
;;		"http://wiki.lyx.org"
;;		"http://chr:LyXers@wiki.lyx.org")
;;	      ))
;;	(set 'pmwiki-author "chr")
;;
;;    where you in the last lines should replace 'chr' with
;;    a username that describes you.
;;
;; 4. To use `mywiki-open' and `mywiki-save-as' commands, add:
;;
;;    (setq pmwiki-main-wiki-base-uri
;;       "http://your.path.to/WikiEngine")
;;    (setq pmwiki-main-homepage-uri
;;        (concat pmwiki-main-wiki-base-uri "?n=Main.HomePage"))
;;
;;    replace "http://your.path.to/WikiEngine" with your wiki base URI.
;;
;; 5. If you have `mmm-mode' and use SourceBlock recipe, add the lines
;;
;;    (pmwiki-multi-source "lisp" 'emacs-lisp-mode 'pmwiki-elisp-submode ?l)
;;
;;    customized for languages you use (optional ?l is a key to use with
;;    [C-c %], 'pmwiki-elisp-mode is arbitrary symbol to name the submode).
;;
;; 6. Optionally, use the command `byte-compile' to compile this file.
;; 7. Restart Emacs.
;;
;;
;; Usage:
;;
;; Two examples to get you started:
;; * Use the command `pmwiki-open' with the argument
;;	Main.WikiSandbox
;;   to download the page Main.WikiSandbox from the PmWiki wiki.
;;
;; * Use the command `pmwiki-open' to open a page by specifying
;;   its URI. For example, to open the page where this mode is
;;   described, give the following URI as argument to the command:
;;
;;	http://www.pmwiki.org/wiki/Cookbook/EmacsPmWikiMode
;;
;; Note:
;; * Do not try to use `pmwiki-mode' to edit a page. 
;;   You must use `pmwiki-open' instead.
;;
;; Enjoy. /Christian, /Lukasz
;;
;;
;; Configuration options:
;;
;; Note that the code below is meant to be inserted in .emacs (or an
;; equivalent file).
;; 
;; If you want to use any of the configuration examples below, first
;; insert this line of code:
;;
;;	(defvar pmwiki-mode-hooks)
;;
;; If your auto-fill-mode is usually on, you might want to turn it off:
;;
;;	(add-hook 'pmwiki-mode-hooks 'turn-off-auto-fill)
;;	
;;
;; Also consider using the package longlines.el, for details see
;;   http://www.emacswiki.org/cgi-bin/wiki.pl/LongLines 
;;
;; 	(add-hook 'pmwiki-mode-hooks
;;	  'pmwiki-delayed-hook-longlines-mode-on)
;;	(add-hook 'pmwiki-save-before-hooks 'longlines-mode-off)
;;
;; in which case, also customize `pmwiki-fill-column' back to 70.
;; Note that you may have to patch the file longlines.el by adding
;; 	(provide 'longlines)
;; to the end of it. As an alternative configuration, this code also
;; makes the `longlines-mode' show the hard newlines.
;;
;; 	(add-hook 'pmwiki-mode-hooks
;;	  'pmwiki-delayed-hook-longlines-mode-showing-hard-newlines)
;;	(add-hook 'pmwiki-save-before-hooks 'longlines-mode-off)
;;
;; Note: PmWiki supports using '\' as line continuation character,
;; i.e. if it is the the last character on the line the linebreak is
;; ignored. This is not supported.
;;
;; !!!Author name
;;
;; The name of the author who modified the page is set through the
;; variable `pmwiki-author'. To configure this, either customize the
;; variable or set it from the your initialization script like this:
;;
;;	(set 'pmwiki-author "chr")
;;
;; !!!File extension for PmWiki-files
;;
;; (add-to-list 'auto-mode-alist '("\\.pmwiki\\'" . pmwiki-mode))
;;

;;; Code:
;; Are we running XEmacs or Emacs?
(defvar pmwiki-running-xemacs (string-match "XEmacs\\|Lucid" emacs-version)
  "Indicates if XEmacs (t) or Emacs (nil) is used")
(defvar pmwiki-running-emacs (not pmwiki-running-xemacs)
  "Indicates if Emacs (t) or XEmacs (nil) is used")

;; Define helper macro for defining functions that might already exist
(defmacro pmwiki-defun-when-void (&rest args)
  "Define a function, just like `defun', unless it's already defined.
Used for compatibility among different emacs variants."
  `(if (fboundp ',(car args))
       nil
     (defun ,@args)))

(require 'thingatpt)
(require 'http-get)
(require 'http-post)
(require 'cl)				; Defines caddr etc
(if pmwiki-running-xemacs
    (require 'mule))	     ; Defines encode-coding-string for xemacs
;;
;; Fix required for XEmacs prior to 21.5

(pmwiki-defun-when-void
 replace-regexp-in-string (regexp rep string &optional
				  fixedcase literal subexp start)
"Replace all matches for REGEXP with REP in STRING.
Return a new string containing the replacements.
Optional arguments FIXEDCASE, LITERAL and SUBEXP are like the
arguments with the same names of function `replace-match'.  If START
is non-nil, start replacements at that index in STRING.
REP is either a string used as the NEWTEXT arg of `replace-match' or a
function.  If it is a function it is applied to each match to generate
the replacement passed to `replace-match'; the match-data at this
point are such that match 0 is the function's argument.
To replace only the first match (if any), make REGEXP match up to \\'
and replace a sub-expression, e.g.
  (replace-regexp-in-string \"\\(foo\\).*\\'\" \"bar\" \" foo foo\" nil nil 1)
    => \" bar foo\"
"
  ;; To avoid excessive consing from multiple matches in long strings,
  ;; don't just call `replace-match' continually.  Walk down the
  ;; string looking for matches of REGEXP and building up a (reversed)
  ;; list MATCHES.  This comprises segments of STRING which weren't
  ;; matched interspersed with replacements for segments that were.
  ;; [For a `large' number of replacments it's more efficient to
  ;; operate in a temporary buffer; we can't tell from the function's
  ;; args whether to choose the buffer-based implementation, though it
  ;; might be reasonable to do so for long enough STRING.]
  (let ((l (length string))
        (start (or start 0))
        matches str mb me)
    (save-match-data
      (while (and (< start l) (string-match regexp string start))
        (setq mb (match-beginning 0)
              me (match-end 0))
        ;; If we matched the empty string, make sure we advance by one char
        (when (= me mb) (setq me (min l (1+ mb))))
        ;; Generate a replacement for the matched substring.
        ;; Operate only on the substring to minimize string consing.
        ;; Set up match data for the substring for replacement;
        ;; presumably this is likely to be faster than munging the
        ;; match data directly in Lisp.
        (string-match regexp (setq str (substring string mb me)))
        (setq matches
              (cons (replace-match (if (stringp rep)
                                       rep
                                     (funcall rep (match-string 0 str)))
                                   fixedcase literal str subexp)
                    (cons (substring string start mb) ; unmatched prefix
                          matches)))
        (setq start me))
      ;; Reconstruct a string from the pieces.
      (setq matches (cons (substring string start l) matches)) ; leftover
      (apply #'concat (nreverse matches)))))

;; Fix required for XEmacs since `string-bytes' doesn't exist
(pmwiki-defun-when-void string-bytes (string)
   "Fake replacement for Emacs `string-bytes'. This function fails for
multibyte characters."
    (length string))

;; ----------------------------------------------------------------------
;;
;;	Preliminaries
;;
;; Define variables with various patterns
;;
(defvar pmwiki-HTTP-pattern
  "^[hH][tT][tT][pP][sS]?:"
  "Pattern matching 'http:' (case insensitive) at the beginning of a string.")

(defvar pmwiki-base-pattern
  (concat "\\(" pmwiki-HTTP-pattern "//[^/?]+\\)\\(/?\\)$\\|"
	  "\\(" pmwiki-HTTP-pattern ".+?\\)\\(\\?n=\\|\\?pagename=\\)\\|"
	  "\\(" pmwiki-HTTP-pattern ".+\\)\\(/\\)[^/?.]+[/.][^/?.#]*\\($\\|#.*\\)\\|"
	  "\\(" pmwiki-HTTP-pattern ".+?\\.php\\)\\(/\\|$\\)")
  "This pattern gets WikiEngine address and where pagename starts.")


;; The pmwiki-site-pattern is used to extract the name of the 
;; site from a URI. The match with the site is match n:o 1
(defvar pmwiki-site-pattern
  (concat pmwiki-HTTP-pattern "//\\(.+?\\)[/?]")
  "Pattern that is used to extract the name of the site")

(defvar pmwiki-link-pattern
  "\\[\\[\\([^]|>]*?\\)\\(?:\\]\\]\\||.+?\\]\\]\\)\\|\\[\\[.+?->\\([^]|>]*?\\)\\]\\]"
  "The pattern used for `pmwiki-next', `pmwiki-prev', `pmwiki-follow' etc.")

;;
;; Other patterns
;;
(defvar pmwiki-style-pattern
  "%%\\|%[A-Za-z][-,=#\\w\\s]*%"
  "Pattern for PmWiki style tags.")

(defvar pmwiki-password-URI-pattern
  "http://\\(.*?:.*?\\)@\\([^/:]+\\)\\(:\\([0-9]+\\)\\)?/\\(.*/\\)?\\([^:]*\\)"
  "Pattern matching a URI like this:
	http://user:password@www.pmwiki.org/Main/WikiSandbox")

;; ----------------------------------------------------------------------
;;
;; Define variables with some default URI's
;;

(defvar pmwiki-org-sandbox-uri "http://www.pmwiki.org/wiki/Main/WikiSandbox"
  "URI to sandbox at http://www.pmwiki.org")

(defvar pmwiki-default-uri pmwiki-org-sandbox-uri
  "Default URI used by some interactive functions")

(defvar pmwiki-default-site "pmwiki.org"
  "Name given for default site in `pmwiki-open' etc")

(defvar pmwiki-open-uri-default pmwiki-org-sandbox-uri
  "Default URI used by `pmwiki-open-uri'.")

(defcustom pmwiki-main-wiki-base-uri nil
  "Base URI of your favorite Wiki site")
(defcustom pmwiki-main-homepage-uri nil
  "URI for the home page of your favorite wiki")
(defcustom pmwiki-TeX-master-file nil
  "LaTeX file with preamble (empty document) for `preview-latex'.")

;; ----------------------------------------------------------------------
;;
;; Define general variables 
;;
;; `pmwiki-page-uri' becomes local to a buffer in `pmwiki-mode'
(defvar pmwiki-page-uri nil
  "The URI of the page corresponding to the current buffer, thus defining
the base URI of the wiki engine as well as group and page name.")

(defvar pmwiki-encoded-password nil
  "The password when authorization is required")

;;
;; There are too many "URI's" now... basically we have
;; 'base URI' -> the PmWiki-script, e.g. http://wiki.lyx.org/pmwiki.php
;; 'post URI' -> to where the form with a page is posted, same as 'base URI'
;; 'page URI' -> the page, e.g. http://wiki.lyx.org/pmwiki.php/Main/WikiWord
;; 'source URI' -> source of PmWiki-page, e.g.
;;		http://wiki.lyx.org/pmwiki.php/Main/WikiWord?action=source
;;
;; I'm thinking of storing the location data as a list, location-list
;; This requires conversion methods:
;;	data    -> pageURI	=> (pmwiki-loc 'URI  listData)
;;	        -> baseURI	=> (pmwiki-loc 'base listData)
;;	pageURI -> data		=> (pmwiki-uri-to-loc-list URI)
;;	srcURI  -> data		=> (pmwiki-uri-to-loc-list URI)

(defvar pmwiki-location-list nil
  "List with four strings, (<baseURI> <group> <page> . <anchor>), specifying
the base URI of the wiki engine, group name, page name and anchor on page.")

(defcustom pmwiki-slash-format nil
  "If nil, format URI as http://...?Group.Page, else as http://.../Group/Page.
Usually set by last user choice, see `pmwiki-freeze-slash-format'.")

(defcustom pmwiki-freeze-slash-format nil
  "If non-nil, don't follow user choice of slash vs. question-mark.
See `pmwiki-slash-format'.")

(defvar pmwiki-save-function 'pmwiki-default-save-function
  "Specifies the function used to save a PmWiki-buffer.")

(defcustom pmwiki-fill-column 76 "Fill column width for `pmwiki-mode'.")
(defcustom pmwiki-mode-hooks nil "")
(defcustom pmwiki-save-before-hooks nil "")

(defcustom pmwiki-decode nil
  "Function called after loading wiki source. No arguments are passed.
It is supposed to process current buffer contents.
See also `pmwiki-encode'.")
(defcustom pmwiki-encode nil
  "Function called on `buffer-string' before saving it as wiki source.
It is called by `pmwiki-default-save-function', can be bypassed when
customizing `pmwiki-save-function'.
It is supposed to be the inverse of `pmwiki-decode'.")

(defcustom pmwiki-author "" "\"Name\" that shows up as author of the
changes when a page is saved from `pmwiki-mode'.")

(defvar pmwiki-mode-line-buffer-identification
  '(#("%09b" 0 4
      (face
       (:weight bold)
       help-echo "mouse-1: previous buffer, mouse-3: next buffer" local-map
       (keymap
	(header-line keymap
		     (mouse-3 . mode-line-bury-buffer)
		     (down-mouse-3 . ignore)
		     (mouse-1 . mode-line-unbury-buffer)
		     (down-mouse-1 . ignore))
	(mode-line keymap
		   (mouse-3 . mode-line-bury-buffer)
		   (mouse-1 . mode-line-unbury-buffer)
		   (down-mouse-1 . ignore)))))
    " "
    (:eval (propertize (pmwiki-create-mode-line-string)
		       'face 'italic 'mouse-face 'bold-italic
		       'help-echo pmwiki-page-uri
		       ))
    )
  "The mode line control used in pmwiki-mode for buffer identification, i.e.
it adds the name of the site after the name of the buffer (wiki page).")



;; ----------------------------------------------------------------------
;;
;;	Auxiliary helper function
;;
(defun pmwiki-default-string (s s0)
  "Return S if not empty, otherwise return S0"
  (if (string= s "") s0 s))

(defun pmwiki-URIp (name)
  "Returns t if NAME matches a URI pattern 
If NAME starts with 'http:', it must match `pmwiki-base-pattern',
otherwise an error is thrown."
  (let ((case-fold-search nil))
    (if (string-match pmwiki-HTTP-pattern name)
	(if (string-match pmwiki-base-pattern name) t
	  (error
	   "pmwiki-uri-type: %s does not match a proper URI pattern" name))
      nil)))



;; ----------------------------------------------------------------------
;;
;;	Main code
;;
;; Define the `pmwiki-mode'. 
;;
;; Have to modify patterns for faces. List of faces:
;; builtin, comment, constant, doc, function, keyword, string, type, variable,
;; warning
;;	[=...=]			- string
;;	[[#<target>]]		- constant
;;	[[<uri> <text>]]	- type
;;  ;;	 <monospace>		- comment  (not used anymore)
;;	@@<monospace>@@		- comment
;;	''<emp>''		- type
;;	'''<strong>'''		- function
;;	'''''<extra>'''''	- warning
;;	*...			- builtin
;;	#...			- doc
;;	!...			- function
;;	:..: : <indented par.>	- doc
;;
;; Maybe remove sgml-tag-alist?

;; Special faces
(defface pmwiki-question-face
  '((t (:bold t)))
  "Used to indicate a question in a PmWiki page.")

(defface pmwiki-answer-face
  '((t (:bold t :italic t)))
  "Used to indicate an answer in a PmWiki page.")


(define-derived-mode pmwiki-mode text-mode "PmWiki"
  "`pmwiki-mode` v0.2 is a Mode to edit PmWiki pages (http://www.pmwiki.org).

Typically you start by using the function `pmwiki-open' to open a URI, e.g.
	http://www.pmwiki.org/wiki/Main/WikiSandbox
Once you have opened a wiki page, you can simply use `pmwiki-open'
again with a simple argument such as 'Main.OtherPage' to open another
page in the same site.

As a special case, you can also use `pmwiki-open' to open a wiki page
from the site pmwiki.org (since it is the default site) even if you
are currently not in a buffer that contains an opened wiki page.

Pages in the `pmwiki-main-wiki-base-uri' site can always be opened using
`mywiki-open', since this function always assumes that the page names refer
to that site (giving the URI of a page overrides this bevhaviour however).

Note that it is not recommended to use `pmwiki-mode' as a command to
start editing a wiki page - it likely won't work.

Once a page has been opened, you can edit it and then save it using
`pmwiki-save' or `pmwiki-save-as'. The latter function allows you to
save the page with a new name, and even on a different wiki engine by
giving an URI as argument.

To view the wiki page that you are editing in a browser, first save it
and then use the command `pmwiki-browse'.

While editing the page, you can use `pmwiki-next' and `pmwiki-prev' to
quickly go to the next and previous links. And when the point is on a
link, you can use `pmwiki-follow' to goto the page that the link
points to, i.e. that page is opened in a new buffer.

Interactive functions:
`pmwiki-open'    - Open wiki page specified by group/name or URI.
                   The default site is pmwiki.org.
`pmwiki-show-uri` - Show the URI of the current wiki page.
`pmwiki-next'    - Goto the next [[link]].
`pmwiki-prev'    - Goto the previous [[link]].
`pmwiki-follow'  - Open (goto) page pointed to by link at point.
`pmwiki-save'    - Save current buffer to the wiki engine.
`pmwiki-save-as' - Save buffer to new page specified by group/name or URI.
`pmwiki-reload'  - Reload the page.
`pmwiki-browse'  - Show current buffer in browser.
`pmwiki-search'  - Search the wiki site for a text. [in v0.5]
`pmwiki-map-site'  - Generate a map of the site (all groups and pages).
                     [in v0.5]
`pmwiki-delete'	 - Delete a page
`pmwiki-rename'	 - Save a page under a different name and delete the original

`mywiki-open'       - Open a page from the LyX wiki.
`mywiki-save-as'    - Save current buffer to page at the LyX wiki.

\\{pmwiki-mode-map}"
  (when pmwiki-running-emacs
    (font-lock-add-keywords
     nil
     '(
;;       ("^[ \t].+?$" . font-lock-comment-face)		;  <monospace>
       ("\\[=[^=]*=\\]" . font-lock-function-name-face)	; [= ... =]
       ("@@[^ \t@][^@]*[^ \t@]@@" . font-lock-comment-face) ; @@a .. b@@
       ("\\(^[*#]+\\)[^*#]" 1 font-lock-constant-face)	; {*|#}+ ...
       ("^!+[^!].*" . font-lock-constant-face)		; !+ ...
       ("\\[\\[<<\\]\\]" . font-lock-comment-face)	; [[<<]]
       ;("\\[\\[#[^]]+\\]\\]" . font-lock-constant-face)	; [[#<target>]]
       ;("\\[\\[[^#].*?\\]\\]" . font-lock-type-face)	; [[ ... ]]
       ("\\[\\[.*?\\]\\]" . font-lock-type-face)	; [[ ... ]]
       ("\\\\$" . font-lock-keyword-face)		;     \
       ("^:+ +:" . font-lock-doc-face)			; :..: : 
       ("^:[ \t]*[^ \t:]+[ \t]*+:" . font-lock-string-face) ; : term : 
       ("%[^ \t%][^%]*[^ \t%]%" . font-lock-warning-face) ; %color = red%
       ("^Q:" . pmwiki-question-face)			; Q:
       ("^A:" . pmwiki-answer-face)			; A:
       )))

;;   (when pmwiki-running-emacs
;;     (font-lock-add-keywords
;;      nil
;;      (list (cons (symbol-value 'pmwiki-link-pattern) 'font-lock-keyword-face))
;;      ))

  (when pmwiki-running-emacs (font-lock-mode 1))
  (goto-address)
  (set (make-local-variable 'sgml-tag-alist)
       `(("b") ("code") ("em") ("i") ("strong") ("nowiki")
	 ("pre" \n) ("tt") ("u")))
  (set (make-local-variable 'skeleton-transformation) 'identity)
  (set (make-local-variable 'pmwiki-search-mode-status) nil)
  (setq indent-tabs-mode t)
  (set (make-local-variable 'mode-line-buffer-identification)
       pmwiki-mode-line-buffer-identification)
  (run-hooks 'pmwiki-mode-hooks))

  

(define-key pmwiki-mode-map (kbd "C-c C-p") 'pmwiki-prev)
(define-key pmwiki-mode-map (kbd "C-c C-n") 'pmwiki-next)
(define-key pmwiki-mode-map (kbd "C-c C-f") 'pmwiki-follow)
(define-key pmwiki-mode-map (kbd "C-c C-g") 'pmwiki-follow)
(define-key pmwiki-mode-map (kbd "C-c C-o") 'pmwiki-open)
(define-key pmwiki-mode-map (kbd "C-c C-c") 'pmwiki-save)
(define-key pmwiki-mode-map (kbd "C-c C-w") 'pmwiki-save-as)
(define-key pmwiki-mode-map (kbd "C-c C-b") 'pmwiki-browse)
(define-key pmwiki-mode-map (kbd "C-c C-m") 'pmwiki-map-site)
;(define-key pmwiki-mode-map (kbd "C-c C-s") 'pmwiki-search) ; FIXME
(define-key pmwiki-mode-map (kbd "C-c C-r") 'pmwiki-reload)
(define-key pmwiki-mode-map (kbd "C-c m")   'pmwiki-minor-mode)

(defvar pmwiki-uri-transforms nil 
"Specifies transformations that will be applied to a URI pattern,
for instance in order to insert user:password.
See `pmwiki-apply-uri-transforms' for more information.

Here is an example of a transformation pattern:

(set 'pmwiki-uri-transforms
     (list
      '(\"http://some.site.se\\(/[A-Z]\\)\\|\\(\\?\\)\"
	\"http://some.site.se\"
	\"http://some.site.se/wiki/pmwiki.php\")
      '(\"http://some.site.se/\"
	\"http://some.site.se/\"
	\"http://user:password@some.site.se/\")))

where the first transformation is useful if you have mapped the site so that
	http://some.site.se/Group/Page
is redirected to
	http://some.site.se/wiki/pmwiki.php/Group/Page.

The second transformation illustrates how to automatically insert username
and password for all accesses to pages in a URI starting with
	'some.site.se
")


;; ----------------------------------------------------------------------
;;
;; `pmwiki-edit' - main function used to load a PmWiki-page into a buffer
;;
;;
;;;###autoload
(defun pmwiki-edit (loc &optional goto-end http-ver content-type)
  "Download the wiki page specified by location list LOC.
Then change the buffer's mode to `pmwiki-mode'.
If GOTO-END is nil, wait until the process is done, process contents with
`pmwiki-decode', and move point to the anchor if it is specified." ;"
  (unless content-type (setq content-type 'iso-8859-1))
  ; ignore anchor, it's processed afterwards
  (let ((page-uri (pmwiki-loc 'URINA loc))
	(proc nil)
	(headers '(("Connection" "close")))
	(user-and-password nil))
    (setq page-uri (pmwiki-apply-uri-transforms page-uri
						pmwiki-uri-transforms))
    (when (string-match pmwiki-password-URI-pattern page-uri)
      (setq user-and-password (base64-encode-string
			       (match-string 1 page-uri)))
      (setq page-uri (replace-regexp-in-string
		      "http://.*?:.*?@" "http://" page-uri))
      (add-to-list 'headers (list "Authorization"
				  (concat "Basic " user-and-password))))
    (set 'proc
	 (http-get (concat page-uri
			   (if pmwiki-slash-format "?action=source"
			     "&action=source")) ; Source URI
		   headers		; headers
		   nil		; ?
		   http-ver		; nil -> 1.0
		   (pmwiki-loc 'name loc) ; output buffer
		   content-type)	) ; typically nil
    (pmwiki-mode)
    (set-fill-column pmwiki-fill-column)
    (set (make-local-variable 'pmwiki-location-list) loc)
    (set (make-local-variable 'pmwiki-encoded-password) user-and-password)
    (set 'TeX-header-end "^[^%\n]*\\\\begin *{document}") ;FIXME
    (set 'TeX-trailer-start "^[^%\n]*\\\\end *{document}")
    (set 'TeX-master pmwiki-TeX-master-file)
    (unless goto-end
      (while (string-equal (process-status proc) "open") (sleep-for 0.050))
      (goto-char 1)
      (funcall pmwiki-decode)
      (goto-char 1)
      (if (cdddr loc)
	  (progn
	    (sleep-for 1) ; FIXME
	    (search-forward (concat "[[#" (pmwiki-loc 'anchor loc) "]]"))))
    (not-modified))
    proc))


;; Link matching algorithm (v0.2):
;;
;; 1: extract link from "[[" to "|" orelse from "->" to "]]"
;;    orelse from "[[" to "]]"
;;
;; 2: remove all round brackets "(", ")"
;;
;; 3: extract the WikiEngine address part if there is one
;;
;; 4: capitalize all words before "#", not directly preceded by "-"
;;
;; 5: remove all spaces
;;
;; 6: extract parts [<Group>{.|/}]<Page>[#<anchor>], if Page is preceded
;;    by "!", set group to Category, if by "~", to Profiles


(defun pmwiki-capitalize (str)
  "Capitalize words in STR without changing the case of inner letters."
  (replace-regexp-in-string "[^-]\\<[a-z]\\|^[a-z]" 'capitalize str))

;; Implenents the matching algorithm, without the first point
(defun pmwiki-link-to-loc (maybe-link)
  "Convert a string with a page, e.g. \"Group.Page\" to a location list, i.e.
	(\"baseURI\" \"Group\"  \"Page\" . \"anchor\")

All parts (base, group, page, anchor) are optional. If base and only one of
group and page is given, then both group and page are set the same.
If only site is given, group and page are set to Main.HomePage."
  (let (baseURI anchor-beg anchor group page aux)
    (setq maybe-link (replace-regexp-in-string "[()]" "" maybe-link))
    (if (string-match pmwiki-base-pattern maybe-link)
	(progn
	  (setq baseURI
		(or (match-string 1 maybe-link)
		    (match-string 3 maybe-link)
		    (match-string 5 maybe-link)
		    (match-string 8 maybe-link)))
	  (setq aux (substring maybe-link
				      (or (match-end 2) (match-end 4)
					  (match-end 6) (match-end 9))))
	  (unless pmwiki-freeze-slash-format
	    (let ((slashmark (or (match-string 2 maybe-link)
				 (match-string 4 maybe-link)
				 (match-string 6 maybe-link)
				 (match-string 9 maybe-link))))
	      (if (string-match "/" slashmark)
		  (setq pmwiki-slash-format t)
		(if (string-match "?" slashmark)
		    (setq pmwiki-slash-format nil)))))
	  (setq maybe-link aux)))
    (setq anchor-beg (string-match "#\\(.+?\\)$" maybe-link))
    (if anchor-beg
	(progn
	  (setq anchor (match-string 1 maybe-link))
	  (setq anchor (replace-regexp-in-string " /" "" anchor))
	  (if (string= anchor "")
	      (setq anchor nil))
	  (setq maybe-link (substring maybe-link 0 anchor-beg))))
    (setq maybe-link (pmwiki-capitalize maybe-link))
    (setq maybe-link (replace-regexp-in-string " " "" maybe-link))
    (if (string-match "^\\(.+?\\)[./]\\(.*\\)$" maybe-link)
	(progn
	  (setq group (match-string 1 maybe-link))
	  (setq page (match-string 2 maybe-link))
	  (if (string= page "")
	      (setq page group)))
      (setq page maybe-link)
      (if baseURI
	  (setq group page)))
    `(,baseURI ,group ,page . ,anchor)))

(defun pmwiki-loc (P &optional loc-list)
  "Compute relevant information from location list.
If URI is not given, `pmwiki-location-list' is used instead.
P determines what is returned according to this list:
	'base	-> <BaseURI>
	'group	-> <group>
	'page	-> <page>
	'anchor -> <anchor>
	'name   -> \"<group>.<page>\" (if <anchor> = nil)
	'nameNA -> \"<group>.<page>\" (NA = No Anchor)
	'name   -> \"<group>.<page>#<anchor>\"
	'URI    -> \"<BaseURI>?n=<group>.<page>\" (if <anchor> = nil)
	'URINA    -> \"<BaseURI>?n=<group>.<page>\" (NA = No Anchor)
	'URI    -> \"<BaseURI>?n=<group>.<page>#<anchor>\"
	'site	-> <site> (part of BaseURI)
If `pmwiki-slash-format' is t, replace dots and \"?n=\" with slashes above."
  (unless loc-list (set 'loc-list pmwiki-location-list))
  (unless loc-list
    (error "No location given, set `pmwiki-location-list' first!"))
  (unless (symbolp P) (error "Invalid type of argument"))
  (let ((s (symbol-name P)))
    (cond
     ((string-equal s "base") (car loc-list))
     ((string-equal s "group") (cadr loc-list))
     ((string-equal s "page") (caddr loc-list))
     ((string-equal s "anchor") (cdddr loc-list))
     ((string-equal s "name")
      (concat (cadr loc-list)
	      (if pmwiki-slash-format "/" ".") (caddr loc-list)
	      (if (cdddr loc-list) (concat "#" (cdddr loc-list)) "")))
     ((string-equal s "nameNA")
      (concat (cadr loc-list)
	      (if pmwiki-slash-format "/" ".") (caddr loc-list)))
     ((string-equal s "URI")
      (concat (car loc-list)
	      (if pmwiki-slash-format "/" "?n=") (cadr loc-list)
	      (if pmwiki-slash-format "/" ".") (caddr loc-list)
	      (if (cdddr loc-list) (concat "#" (cdddr loc-list)) "")))
     ((string-equal s "URINA")
      (concat (car loc-list)
	      (if pmwiki-slash-format "/" "?n=") (cadr loc-list)
	      (if pmwiki-slash-format "/" ".") (caddr loc-list)))
     ((string-equal s "site")
      (string-match pmwiki-site-pattern (car loc-list))
      (match-string 1 (car loc-list)))
     (t (error "Invalid argument 'P' of `pmwiki-loc'!")))))

(defun pmwiki-merge-loc (loc1 &optional loc2)
  "Merge two location lists: if LOC1 doesn't specify something, use LOC2.
When LOC2 is not given, use `pmwiki-location-list'."
  (unless loc2 (setq loc2 pmwiki-location-list))
  (if loc2
      `(,(or (car loc1) (car loc2))
	,(or (cadr loc1) (cadr loc2))
	,(or (caddr loc1) (caddr loc2)) .
	,(or (cdddr loc1) (cdddr loc2)))
    loc1))
 

(defun pmwiki-create-mode-line-string ()
  "Used to create the text that goes into the mode line."
  (if pmwiki-location-list
      (format "[%s]" (pmwiki-loc 'site))
    "[?]"))


(defun pmwiki-show-uri ()
  "Show the URI for the wiki page being edited in the current buffer."
  (interactive)
  (message (pmwiki-loc 'URI)))

(defun pmwiki-next ()
  "Goto the next WikiWord or {{free link}}."
  (interactive)
  (let ((case-fold-search nil))
    (re-search-forward pmwiki-link-pattern
     nil t)))

(defun pmwiki-prev ()
  "Goto the previous WikiWord or {{free link}}."
  (interactive)
  (let ((case-fold-search nil))
    (re-search-backward pmwiki-link-pattern
     nil t)))


(defun pmwiki-follow ()
  "Goto (open) the page/anchhor pointed to by the PmWiki-link at point."
  (interactive)
  (let ((loc (pmwiki-loc-at-point)))
    (if (or (cadr loc) (caddr loc))
	(pmwiki-edit (pmwiki-merge-loc loc))
      (if (cdddr loc)
	  (or (search-forward (concat "[[#" (cdddr loc) "]]") nil t)
	      (search-backward (concat "[[#" (cdddr loc) "]]")))
	nil))))


(defun pmwiki-loc-at-point ()
  "Return location list for PmWiki link at point of the current buffer.

If no link is found at the current point, nil is returned.
See `pmwiki-location-list'."
  (interactive)
  (let ((case-fold-search nil)
	(found-full-link (thing-at-point-looking-at pmwiki-link-pattern)))
    (if found-full-link
	(let ((maybe-link (match-string 1)))
	  (message (concat "maybe-link: " maybe-link))
	  (pmwiki-link-to-loc maybe-link))
      nil))) ; not looking at [[ ... ]]


(defun pmwiki-buffer-loc-list (&optional buf)
  "Return location list for buffer BUF."
  (if buf
      (save-excursion
	(set-buffer buf)
	pmwiki-location-list)
    pmwiki-location-list))


(defun pmwiki-buffer-uri (&optional buf)
  "Return URI of page in buffer BUF, or if BUF is not given, in current buffer."
  (interactive "b")
  (pmwiki-loc 'URI (pmwiki-buffer-loc-list buf)))


(defun pmwiki-browse (&optional buf)
  "Open the buffer BUF in a browser. If BUF is not given,
the current buffer is used."
  (interactive)
  (browse-url (pmwiki-buffer-uri buf)))


(defun pmwiki-open (name)
  "Open a page specified by NAME from the current wiki engine, or
open page specified by a URI."
  (interactive "sName or URI (ex: Main.WikiSandbox): ")
  (let ((loc (pmwiki-merge-loc (pmwiki-link-to-loc name))))
    (if (car loc) (pmwiki-edit loc)
      (message
       (concat "No page URI given, assuming site is " pmwiki-default-site))
      (sleep-for 1) 			; Pause 1 second to show message
      (pmwiki-edit (pmwiki-merge-loc loc (pmwiki-link-to-loc
					  pmwiki-default-site))))))


(defun pmwiki-reload ()
  "Reload the current page from the wiki engine."
  (interactive)
  (unless pmwiki-location-list
    (error "pmwiki-reload: `pmwiki-location-ilst' is empty!"))
  (let ((old-point (point))
	(proc nil))
    (if pmwiki-search-mode-status
	nil ; (pmwiki-search pmwiki-search-text) ; FIXME
      (set 'proc (pmwiki-edit pmwiki-location-list)))
    (while (string-equal (process-status proc) "open") 
      (sleep-for 0 50))
    (goto-char old-point)))


(defun pmwiki-save ()
  "Uploads current buffer to the wiki."
  (interactive)
  (unless pmwiki-save-function (error "No save function specified"))
  (when pmwiki-search-mode-status (error "Not available for search buffers"))
  (run-hooks 'pmwiki-save-before-hooks)
  (save-excursion (funcall pmwiki-save-function))
  (not-modified))


(defun pmwiki-save-to-loc (loc)
  "Uploads current buffer to a PAGE-URI (allows you to store the buffer
under a new name, or in a different wiki)."
  (set 'pmwiki-location-list loc)
  (rename-buffer (pmwiki-loc 'nameNA))
  (pmwiki-save))


(defun pmwiki-save-as (name)
  "Uploads current buffer to a specific page on a wiki. This also
changes `pmwiki-page-uri', so future saves also goes to this page.
The argument NAME can be either a name (= <group>.<page>) or an URI.
An URI must begin with 'http'."
  (interactive "sUpload page as NAME or URI (ex: Main.WikiSandbox): ")
  (pmwiki-save-to-loc (pmwiki-link-to-loc name)))
      

(defun mywiki-save-as (name)
  "Save buffer to a certain <group>.<page> (=NAME) at main wiki"
  (interactive "sName (ex: Main.WikiSandbox): ")
  (let ((loc (pmwiki-merge-loc
	      (pmwiki-link-to-loc name)
	      (pmwiki-link-to-loc pmwiki-main-wiki-base-uri))))
    (message (concat "Saving to " (pmwiki-loc 'URINA loc)))
    (pmwiki-save-to-loc loc)))
	

(defun pmwiki-delete (name)
  "Delete page from the current wiki engine, specified by NAME which
can be empty (current buffer), a page name or a URI."
  (interactive "sDelete page (or empty for current page): ")
  (unless (string-equal name "")
    (pmwiki-open (pmwiki-link-to-loc name)))
  (erase-buffer)
  (insert "delete")
  (pmwiki-save)
  (kill-buffer nil)
  )

(defun pmwiki-rename (new-name)
  "Save current buffer under a new name and delete the original page."
  (interactive "sNew page name: ")
  (let ((old-page (pmwiki-loc 'nameNA)))
    (pmwiki-save-as new-name)
    (pmwiki-delete old-page)))

(defun pmwiki-apply-uri-transform (uri transf)
  "Transform a URI according to the list TRANSF comprised of three strings.
If the 1st string matches URI (as a regexp), then the 2nd string will be
replaced by the 3rd string."
  (let ((case-fold-search nil)
	(do-debug nil))
    (when do-debug
      (message (concat "page-uri=" uri))
      (message (concat "1st part " (car transf)))
      (message (concat "2nd part " (cadr transf)))
      (message (concat "3rd part " (caddr transf))))
    
    (if (and transf (string-match (car transf) uri))
	(setq uri
	      (replace-regexp-in-string (cadr transf) (caddr transf) uri))
      uri)
    (when do-debug
      (message (concat "result=" uri "\n")))
    uri))

(defun pmwiki-apply-uri-transforms (uri transforms)
  "Transform URI according to transformations in the list TRANSFORMS.
Each transform in TRANSFORMS is applied to URI using the function
pmwiki-apply-uri-transform."
    (while transforms
      (set 'uri (pmwiki-apply-uri-transform uri (car transforms)))
      (set 'transforms (cdr transforms)))
    uri)

;;
;; Functions useful for configuration.
;;
(defun pmwiki-delayed-hook-longlines-mode-on ()
  "Hook that activates `longlines-mode' when Emacs has been idle for 1 s."
  (require 'longlines)
  (run-with-idle-timer
   1 nil
   (lambda (buf)
     (save-excursion
       (set-buffer buf)
       (message (concat "Enabling longlines-mode for " (buffer-name)))
       (longlines-mode-on)))
   (current-buffer)))

(defun pmwiki-delayed-hook-longlines-mode-showing-hard-newlines ()
  "Hook that activates `longlines-mode' when Emacs has been idle for 1 s,
and in addition runs it `longlines-show-hard-newlines'."
  (require 'longlines)
  (run-with-idle-timer
   1 nil
   (lambda (buf)
     (save-excursion
       (set-buffer buf)
       (message (concat "Enabling longlines-mode for " (buffer-name)))
       (longlines-mode-on)
       (longlines-show-hard-newlines)))
   (current-buffer)))

;;; ************************************************************************
;;;
;;; Based on simple-emacswiki.el
;;;

(defun pmwiki-default-save-function ()
  "Save the current page to a PmWiki wiki."
  (let ((cur-buffer (buffer-name))
	(page-uri (pmwiki-loc 'URINA))
	(loc pmwiki-location-list)
	(in-minor-mode pmwiki-minor-mode)
	(diffclass (if pmwiki-minor-mode "minor" ""))
	(pagename (pmwiki-loc 'nameNA))
	(password pmwiki-encoded-password)
	(cur-fill-column fill-column)
	(headers nil))
    (if password
	(setq headers
	      (list (list "Authorization" (concat "Basic " password)))))
    (message (concat "Any output is in "
		   (buffer-name 
		    (process-buffer
		     (http-post
		      (pmwiki-loc 'base) ;; Get destination
		      (list 
;;		       (cons "User-Agent" "Emacs pmwiki-mode")
		       (cons "pagename" pagename)
		       (cons "action" "edit")
		       (cons "post" "1")
		       (cons "diffclass" diffclass)
		       (cons "author" pmwiki-author)
		       (cons "text"
			     (if pmwiki-encode
				 (funcall pmwiki-encode (buffer-string))
			       (buffer-string))))
		      'iso-8859-1
		      headers)))))
    (switch-to-buffer cur-buffer)
    (pmwiki-mode)
    (set (make-local-variable 'pmwiki-location-list) loc)
    (set (make-local-variable 'pmwiki-encoded-password) password)
    (set 'fill-column cur-fill-column)
    (when in-minor-mode (pmwiki-minor-mode))))


(defun mywiki-open (name)
  "Open page NAME from main wiki (or a page specified by an URI).
Ex: 'Main.WikiSandbox' will open the page
   http://.../Main/WikiSandbox
Note when NAME is an URI, the page doesn't have to belong to the main wiki."
  (interactive "sName (default Main.HomePage): ")
    (pmwiki-edit (pmwiki-merge-loc
		  (pmwiki-link-to-loc name)
		  (pmwiki-link-to-loc pmwiki-main-homepage-uri))))


; In my Windows Emacs I have to use this line instead:
(easy-mmode-define-minor-mode pmwiki-minor-mode
  "Toggle `pmwiki' minor changes mode.
With no argument, this command toggles the mode. 
Non-null prefix argument turns on the mode.
Null prefix argument turns off the mode.
The default is for this mode to be activated!

When this minor mode is active, saved changes will be tagged with a
`pmwiki-diffclass` of \"minor\"."
  t " minor")



;; mmm-mode
;; set auctex-mode to work within pmwiki-mode for jsMath
(when
 (require 'mmm-mode nil t)

  (setq mmm-global-mode 'maybe)

  (defun pmwiki-multi-source (lang mode name &optional insertchar)
  "Add submode for source code.
Add submode MODE (function toggling the mode) for language LANG
(string with the SourceBlock name of language) as NAME (any symbol).
INSERTCHAR is the character to insert the source markup with
[C-c % INSERTCHAR] sequence."
    (interactive)
    (mmm-add-classes
     (if insertchar
	 `((,name
	    :submode ,mode
	    :face mmm-code-submode-face
	    :front ,(concat "(:source lang=" lang ".*?:)")
	    :back "(:sourcend:)"
	    :insert ((,insertchar ocaml-source .
				  (nil @ "(:source lang=" ,lang ":)" \n @
					 _ @ \n "(:sourcend:)" @)))))
       `((,name
	  :submode ,mode
	  :face mmm-code-submode-face
	  :front ,(concat "(:source lang=" lang ".*?:)")
	  :back "(:sourcend:)"))))
    (mmm-add-mode-ext-class 'pmwiki-mode nil name))


  (mmm-add-classes
   '((pmwiki-jsmath-latex
      :submode latex-mode
      :face mmm-declaration-submode-face
      :front "\\({\\)$$?"
      :back "$?$\\(}\\)"
      :front-match 1
      :back-match 1
      :insert ((?$ inline-math . (nil @ "{" @ "$" _ "$" @ "}" @ ))
	       (?[ math . (nil @ "{" @ "$$" _ "$$" @ "}" @ ))))))

  (mmm-add-mode-ext-class 'pmwiki-mode nil 'pmwiki-jsmath-latex)

   ;; for some reason, testing for `mmm-font-lock-mode' doesn't work for me
   (defun mmm-fontify-region (start stop &optional loudly)
     "Fontify from START to STOP keeping track of submodes correctly."
     (when loudly
       (message "Fontifying %s with submode regions..." (buffer-name)))
     ;; Necessary to catch changes in font-lock cache state and position.
     (mmm-save-changed-local-variables
      mmm-current-overlay mmm-current-submode)
     ;; For some reason `font-lock-fontify-block' binds this to nil, thus
     ;; preventing `mmm-beginning-of-syntax' from doing The Right Thing.
     ;; I don't know why it does this, but let's undo it here.
     (let ((font-lock-beginning-of-syntax-function 'mmm-beginning-of-syntax))
       (mapc #'(lambda (elt)
		 (mmm-fontify-region-list (car elt) (cdr elt)))
	     (mmm-regions-alist start stop)))
     ;; With jit-lock, this causes blips in the mode line and menus.
     ;; Shouldn't be necessary here, since it's in post-command-hook too.
     ;;(mmm-update-submode-region)
     (when loudly (message nil)))
)

(provide 'pmwiki-mode)
;;; pmwiki-mode.el ends here
