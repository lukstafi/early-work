# pmwiki-mode, the 2007 releases

An Emacs mode for browsing and editing pages of a [PmWiki](https://www.pmwiki.org/) wiki from within Emacs.

Christian Ridderström wrote `pmwiki-mode` in 2003 to edit the LyX wiki, building on Alex Schroeder's `simple-wiki-mode`. In 2007 Lukasz Stafiniak took over maintenance and partly rewrote it, to edit the articles on his university homepage. The project's repository on SourceForge stops in 2005, so the 2007 work survives only as release archives at <https://sourceforge.net/projects/pmwiki-mode/files/>.

The history of this folder replays those archives, one commit per release, each dated as the release was:

| Release | Date | `pmwiki-mode.el` |
|---|---|---|
| 0.3 | 31 January 2007 | 1,163 lines |
| 0.3.5 | 4 February 2007 | 1,365 lines |
| 0.4 | 17 February 2007 | 2,307 lines |
| 0.5rc1 | 8 March 2007 | 3,823 lines |
| 0.5rc2 | 18 March 2007 | 3,872 lines |

`ChangeLog` lists what each version added: LaTeX preview and code-block submodes through `mmm-mode`, a table of contents and site map, password rules per site and page, merging when a saved page has changed on the server, browsing history, and a tool bar.

`longlines.el`, `http-get.el` and `http-post.el` are other authors' packages shipped with the releases. Editor backup files in the archives were left out.

Licence: GNU General Public License, version 2 or later (`COPYING`).
