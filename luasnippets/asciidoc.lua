--- @diagnostic disable: unused-local
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local snippets, autosnippets = {}, {}


---@see https://docs.asciidoctor.org/asciidoc/latest/attributes/document-attributes-ref


local function in_header()
    local end_line = vim.fn.line(".") - 1
    local lines = vim.api.nvim_buf_get_lines(0, 0, end_line, true)
    local found_title = false
    local has_blank_line = false
    for _, line in ipairs(lines) do
        if line:match("^= ") then
            found_title = true
        end
        if found_title and line:match("^%s*$") then
            has_blank_line = true
            break
        end
    end
    return found_title and not has_blank_line
end

local function not_api_cli_only()
    return false
end

local function is_line_start(line)
    return not line:match("%S%s")
end

local intrinsic_attributes = {
    s({ trig = ":backend:", name = "backend", dscr = "The backend used to select and activate the converter that creates the output file. Usually named according to the output format (e.g., `html5`)" }, { t(":backend: "), i(1, "html5") }, { show_condition = is_line_start }),
    s({ trig = ":backend-<backend>:", name = "backend", dscr = "A convenience attribute for checking which backend is selected. <backend> is the value of the `backend` attribute (e.g., `backend-html5`). Only one such attribute is set at time." }, { t(":backend-"), i(1, "<backend>"), t(": ") }, { show_condition = is_line_start }),
    s({ trig = ":basebackend:", name = "basebackend", dscr = "The generic backend on which the backend is based. Typically derived from the backend value minus trailing numbers (e.g., the basebackend for `docbook5` is `docbook`). May also indicate the internal backend employed by the converter (e.g., the basebackend for `pdf` is `html`)." }, { t(":basebackend: "), i(1, "html") }, { show_condition = is_line_start }),
    s({ trig = ":basebackend-<basebackend>:", name = "basebackend", dscr = "A convenience attribute for checking which basebackend is active. <basebackend> is the value of the `basebackend` attribute (e.g., `basebackend-html`). Only one such attribute is set at time." }, { t(":basebackend-"), i(1, "<basebackend>"), t(": ") }, { show_condition = is_line_start }),
    s({ trig = ":docdate:", name = "docdate", dscr = "Last modified date of the source document." }, { t(":docdate: "), i(1, os.date("%Y-%m-%d")) }, { show_condition = is_line_start }),
    s({ trig = ":docdatetime:", name = "docdatetime", dscr = "Last modified date and time of the source document." }, { t(":docdatetime: "), i(1, os.date("%Y-%m-%d %H:%M:%S UTC")) }, { show_condition = is_line_start }),
    s({ trig = ":docdir:", name = "docdir", dscr = "Full path of the directory that contains the source document. Empty if the safe mode is SERVER or SECURE (to conceal the file’s location)." }, { t(":docdir: "), i(1, vim.fn.getcwd()) }, { show_condition = not_api_cli_only }),
    s({ trig = ":docfile:", name = "docfile", dscr = "Full path of the source document. Truncated to the basename if the safe mode is SERVER or SECURE (to conceal the file’s location)." }, { t(":docfile: "), i(1, vim.fn.expand("%:p")) }, { show_condition = not_api_cli_only }),
    s({ trig = ":docfilesuffix:", name = "docfilesuffix", dscr = "File extension of the source document, including the leading period." }, { t(":docfilesuffix: "), i(1, ".adoc") }, { show_condition = not_api_cli_only }),
    s({ trig = ":docname:", name = "docname", dscr = "Root name of the source document (no leading path or file extension)." }, { t(":docname: "), i(1, vim.fn.expand('%:t:r')) }, { show_condition = not_api_cli_only }),
    s({ trig = ":doctime:", name = "doctime", dscr = "Last modified time of the source document." }, { t(":doctime: "), i(1, os.date("%H:%M:%S UTC")) }, { show_condition = is_line_start }),
    s({ trig = ":doctype-<doctype>:", name = "doctype-<doctype>", dscr = "A convenience attribute for checking the doctype of the document. <doctype> is the value of the `doctype` attribute (e.g., `doctype-book`). Only one such attribute is set at time." }, { t(":doctype-: "), i(1, "<doctype>") }, { show_condition = is_line_start }),
    s({ trig = ":docyear:", name = "docyear", dscr = "Year that the document was last modified." }, { t(":docyear: "), i(1, os.date("%Y")) }, { show_condition = is_line_start }),
    s({ trig = ":embedded:", name = "embedded", dscr = "Only set if content is being converted to an embedded document (i.e., body of document only)." }, { t(":embedded: "), i(1, os.date("%Y")) }, { show_condition = is_line_start }),
    s({ trig = ":filetype:", name = "filetype", dscr = "File extension of the output file name (without leading period)." }, { t(":filetype: "), i(1, "html") }, { show_condition = not_api_cli_only }),
    s({ trig = ":filetype-<filetype>:", name = "filetype-<filetype>", dscr = "A convenience attribute for checking the filetype of the output. <filetype> is the value of the `filetype` attribute (e.g., `filetype-html`). Only one such attribute is set at time." }, { t(":filetype-: "), i(1, "<filetype>") }, { show_condition = is_line_start }),
    s({ trig = ":htmlsyntax:", name = "htmlsyntax", dscr = "Syntax used when generating the HTML output. Controlled by and derived from the backend name (html=html or xhtml=html)." }, { t(":htmlsyntax: "), c(1, { t('html'), t('xml') }) }, { show_condition = is_line_start }),
    s({ trig = ":localdate:", name = "localdate", dscr = "Date when the document was converted." }, { t(":localdate: "), i(1, os.date("%Y-%m-%d")) }, { show_condition = is_line_start }),
    s({ trig = ":localdatetime:", name = "localdatetime", dscr = "Date and time when the document was converted." }, { t(":localdatetime: "), i(1, os.date("%Y-%m-%d %H:%M:%S UTC")) }, { show_condition = is_line_start }),
    s({ trig = ":localtime:", name = "localtime", dscr = "Time when the document was converted." }, { t(":localtime: "), i(1, os.date("%H:%M:%S UTC")) }, { show_condition = is_line_start }),
    s({ trig = ":localyear:", name = "localyear", dscr = "Year when the document was converted." }, { t(":localyear: "), i(1, os.date("%Y")) }, { show_condition = is_line_start }),
    s({ trig = ":outdir:", name = "outdir", dscr = "Full path of the output directory. (Cannot be referenced in the content. Only available to the API once the document is converted)." }, { t(":outdir: "), i(1, vim.fn.expand('%:p')) }, { show_condition = is_line_start }),
    s({ trig = ":outfile:", name = "outfile", dscr = "Full path of the output file. (Cannot be referenced in the content. Only available to the API once the document is converted)." }, { t(":outfile: "), i(1, vim.fn.expand('%:p:r')..".html") }, { show_condition = is_line_start }),
    s({ trig = ":outfilesuffix:", name = "outfilesuffix", dscr = "File extension of the output file (starting with a period) as determined by the backend (`.html` for `html`, `.xml` for `docbook`, etc.)." }, { t(":outfilesuffix: "), i(1, ".html") }, { show_condition = is_line_start }),
    s({ trig = ":safe-mode-level:", name = "safe-mode-level", dscr = "Numeric value of the safe mode setting. (0=UNSAFE, 1=SAFE, 10=SERVER, 20=SECURE)." }, { t(":safe-mode-level: "), c(1, { t('0'), t('1'), t("10"), t("20") }) }, { show_condition = is_line_start }),
    s({ trig = ":safe-mode-name:", name = "safe-mode-name", dscr = "Textual value of the safe mode setting." }, { t(":safe-mode-name: "), c(1, { t('UNSAFE'), t('SAFE'), t("SERVER"), t("SECURE") }) }, { show_condition = is_line_start }),
    s({ trig = ":safe-mode-unsafe:", name = "safe-mode-unsafe", dscr = "Set if the safe mode is UNSAFE." }, { t(":safe-mode-unsafe: ") }, { show_condition = is_line_start }),
    s({ trig = ":safe-mode-safe:", name = "safe-mode-safe", dscr = "Set if the safe mode is SAFE." }, { t(":safe-mode-safe: ") }, { show_condition = is_line_start }),
    s({ trig = ":safe-mode-server:", name = "safe-mode-server", dscr = "Set if the safe mode is SERVER." }, { t(":safe-mode-server: ") }, { show_condition = is_line_start }),
    s({ trig = ":safe-mode-secure:", name = "safe-mode-secure", dscr = "Set if the safe mode is SECURE." }, { t(":safe-mode-secure: ") }, { show_condition = is_line_start }),
    s({ trig = ":user-home:", name = "user-home", dscr = "Full path of the home directory for the current user. Masked as `.` if the safe mode is `SERVER` or `SECURE`." }, { t(":user-home: "), i(1, vim.env.HOME) }, { show_condition = is_line_start }),
}

local compliance_attributes = {
    s({ trig = ":attribute-missing:", name = "attribute-missing", dscr = "Controls how missing attribute references are handled." }, { t(":attribute-missing: "), c(1, { t('skip'), t('drop'), t('drop-line'), t('warn') }) }, { show_condition = is_line_start }),
    s({ trig = ":attribute-undefined:", name = "attribute-undefined", dscr = "Controls how attribute unassignments are handled." }, { t(":attribute-undefined: "), c(1, { t('drop'), t('drop-line') }) }, { show_condition = is_line_start }),
    s({ trig = ":compat-mode:", name = "compat-mode", dscr = "Controls when the legacy parsing mode is used to parse the document." }, { t(":"), i(1), t({ "compat-mode:", "" }) }, { show_condition = is_line_start }),
    s({ trig = ":experimental:", name = "experimental", dscr = "Enables Button and Menu UI Macros and the Keyboard Macro." }, { t(":"), i(1),t({ "experimental:", "" }) }, { show_condition = in_header }),
    s({ trig = ":reproducible:", name = "reproducible", dscr = "Prevents last-updated date from being added to HTML footer or DocBook info element. Useful for storing the output in a source code control system as it prevents spurious changes every time you convert the document. Alternately, you can use the SOURCE_DATE_EPOCH environment variable, which sets the epoch of all source documents and the local datetime to a fixed value." }, { t(":"), i(1),t({ "reproducible:", "" }) }, { show_condition = in_header }),
    s({ trig = ":skip-front-matter:", name = "skip-front-matter", dscr = "Consume YAML-style frontmatter at top of document and store it in `front-matter` attribute." }, { t(":"), i(1), t({ "skip-front-matter:", "" }) }, { show_condition = in_header }),
}

local localization_and_numbering_attributes = {
    s({ trig = ":appendix-caption:", name = "appendix-caption", dscr = "Label added before an appendix title." }, { t(":appendix-caption: "), i(1, "Appendix") }, { show_condition = is_line_start }),
    s({ trig = ":appendix-number:", name = "appendix-number", dscr = "Sets the seed value for the appendix number sequence." }, { t(":appendix-number: "), i(1) }, { show_condition = is_line_start }),
    s({ trig = ":appendix-refsig:", name = "appendix-refsig", dscr = "Signifier added to Appendix title cross references." }, { t(":appendix-refsig: "), i(1, "Appendix") }, { show_condition = is_line_start }),
    s({ trig = ":caution-caption:", name = "caution-caption", dscr = "Text used to label CAUTION admonitions when icons aren’t enabled." }, { t(":caution-caption: "), i(1, "Caution") }, { show_condition = is_line_start }),
    s({ trig = ":chapter-number:", name = "chapter-number", dscr = "Sets the seed value for the chapter number sequence.[1] Book doctype only." }, { t(":chapter-number: "), i(1, "1") }, { show_condition = is_line_start }),
    s({ trig = ":chapter-refsig:", name = "chapter-refsig", dscr = "Signifier added to Chapter titles in cross references. Book doctype only." }, { t(":chapter-refsig: "), i(1, "Chapter") }, { show_condition = is_line_start }),
    s({ trig = ":chapter-signifier:", name = "chapter-signifier", dscr = "Label added to level 1 section titles (chapters). Book doctype only." }, { t(":chapter-signifier: "), i(1, "any") }, { show_condition = is_line_start }),
    s({ trig = ":example-caption:", name = "example-caption", dscr = "Text used to label example blocks." }, { t(":example-caption: "), i(1, "Example") }, { show_condition = is_line_start }),
    s({ trig = ":example-number:", name = "example-number", dscr = "Sets the seed value for the example number sequence." }, { t(":example-number: "), i(1, "1") }, { show_condition = is_line_start }),
    s({ trig = ":figure-caption:", name = "figure-caption", dscr = "Text used to label images and figures." }, { t(":figure-caption: "), i(1, "Figure") }, { show_condition = is_line_start }),
    s({ trig = ":figure-number:", name = "figure-number", dscr = "Sets the seed value for the figure number sequence." }, { t(":figure-number: "), i(1, "1") }, { show_condition = is_line_start }),
    s({ trig = ":footnote-number:", name = "footnote-number", dscr = "Sets the seed value for the footnote number sequence." }, { t(":footnote-number: "), i(1, "1") }, { show_condition = is_line_start }),
    s({ trig = ":important-caption:", name = "important-caption", dscr = "Text used to label IMPORTANT admonitions when icons are not enabled." }, { t(":important-caption: "), i(1, "Important") }, { show_condition = is_line_start }),
    s({ trig = ":lang:", name = "lang", dscr = "Language tag specified on document element of the output document. Refer to the lang and xml:lang attributes section of the HTML specification to learn about the acceptable values for this attribute." }, { t(":lang: "), i(1, "zh-CN") }, { show_condition = in_header }),
    s({ trig = ":last-update-label:", name = "last-update-label", dscr = "Text used for “Last updated” label in footer." }, { t(":last-update-label: "), i(1, "Last updated") }, { show_condition = in_header }),
    s({ trig = ":listing-caption:", name = "listing-caption", dscr = "Text used to label listing blocks." }, { t(":listing-caption: "), i(1) }, { show_condition = is_line_start }),
    s({ trig = ":listing-number:", name = "listing-number", dscr = "Sets the seed value for the listing number sequence." }, { t(":listing-number: "), i(1, "1") }, { show_condition = is_line_start }),
    s({ trig = ":manname-title:", name = "manname-title", dscr = "Label for program name section in the man page." }, { t(":manname-title: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":nolang:", name = "nolang", dscr = "Prevents `lang` attribute from being added to root element of the output document." }, { t(":"), i(1), t({ "nolang:", "" }) }, { show_condition = in_header }),
    s({ trig = ":note-caption:", name = "note-caption", dscr = "Text used to label NOTE admonitions when icons aren’t enabled." }, { t(":note-caption: "), i(1, "Note") }, { show_condition = is_line_start }),
    s({ trig = ":part-refsig:", name = "part-refsig", dscr = "Signifier added to Part titles in cross references. Book doctype only." }, { t(":part-refsig: "), i(1, "Part") }, { show_condition = is_line_start }),
    s({ trig = ":part-signifier:", name = "part-signifier", dscr = "Label added to level 0 section titles (parts). Book doctype only." }, { t(":part-signifier: "), i(1) }, { show_condition = is_line_start }),
    s({ trig = ":preface-title:", name = "preface-title", dscr = "Title text for an anonymous preface when `doctype` is `book`." }, { t(":preface-title: "), i(1) }, { show_condition = is_line_start }),
    s({ trig = ":section-refsig:", name = "section-refsig", dscr = "Signifier added to title of numbered sections in cross reference text." }, { t(":section-refsig: "), i(1, "Section") }, { show_condition = is_line_start }),
    s({ trig = ":table-caption:", name = "table-caption", dscr = "Text of label prefixed to table titles." }, { t(":table-caption: "), i(1, "Table") }, { show_condition = is_line_start }),
    s({ trig = ":table-number:", name = "table-number", dscr = "Sets the seed value for the table number sequence." }, { t(":table-number: "), i(1, "1") }, { show_condition = is_line_start }),
    s({ trig = ":tip-caption:", name = "tip-caption", dscr = "Text used to label TIP admonitions when icons aren’t enabled." }, { t(":tip-caption: "), i(1, "Tip") }, { show_condition = is_line_start }),
    s({ trig = ":toc-title:", name = "toc-title", dscr = "Title for table of contents." }, { t(":toc-title: "), i(1, "Table of Contents") }, { show_condition = in_header }),
    s({ trig = ":untitled-label:", name = "untitled-label", dscr = "Default document title if document doesn’t have a document title." }, { t(":untitled-label: "), i(1, "Untitled") }, { show_condition = in_header }),
    s({ trig = ":version-label:", name = "version-label", dscr = "See Version Label Attribute." }, { t(":version-label: "), i(1, "Version") }, { show_condition = in_header }),
    s({ trig = ":warning-caption:", name = "warning-caption", dscr = "Text used to label WARNING admonitions when icons aren’t enabled." }, { t(":warning-caption: "), i(1, "Warning") }, { show_condition = is_line_start }),
}

local document_metadata_attributes = {
    s({ trig = ":app-name:", name = "app-name", dscr = "Adds `application-name` meta element for mobile devices inside HTML document head." }, { t(":app-name: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":author:", name = "author", dscr = "Can be set automatically via the author info line or explicitly. See Author Information." }, { t(":author: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":authorinitials:", name = "authorinitials", dscr = "Derived from the author attribute by default. See Author Information." }, { t(":authorinitials: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":authors:", name = "authors", dscr = "Can be set automatically via the author info line or explicitly as a comma-separated value list. See Author Information." }, { t(":authors: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":copyright:", name = "copyright", dscr = "Adds `copyright` meta element in HTML document head." }, { t(":copyright: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":doctitle:", name = "doctitle", dscr = "See doctitle attribute." }, { t(":doctitle: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":description:", name = "description", dscr = "Adds description meta element in HTML document head." }, { t(":description: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":email:", name = "email", dscr = "Can be any inline macro, such as a URL. See Author Information." }, { t(":email: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":firstname:", name = "firstname", dscr = "See Author Information." }, { t(":firstname: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":front-matter:", name = "front-matter", dscr = "If `skip-front-matter` is set via the API or CLI, any YAML-style frontmatter skimmed from the top of the document is stored in this attribute." }, { t(":front-matter: "), i(1) }, { show_condition = is_line_start }),
    s({ trig = ":keywords:", name = "keywords", dscr = "Adds keywords meta element in HTML document head." }, { t(":keywords: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":lastname:", name = "lastname", dscr = "See Author Information." }, { t(":lastname: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":middlename:", name = "middlename", dscr = "See Author Information." }, { t(":middlename: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":orgname:", name = "orgname", dscr = "Adds `<orgname>` element value to DocBook info element." }, { t(":orgname: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":revdate:", name = "revdate", dscr = "See Revision Information." }, { t(":revdate: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":revremark:", name = "revremark", dscr = "See Revision Information." }, { t(":revremark: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":revnumber:", name = "revnumber", dscr = "See Revision Information." }, { t(":revnumber: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":title:", name = "title", dscr = "Value of `<title>` element in HTML `<head>` or main DocBook `<info>` of output document. Used as a fallback when the document title is not specified. See title attribute." }, { t(":title: "), i(1) }, { show_condition = in_header }),
}

local section_title_and_table_of_contents_attributes = {
    s({ trig = ":idprefix:", name = "idprefix", dscr = "Prefix of auto-generated section IDs. See Change the ID prefix." }, { t(":idprefix: "), i(1) }, { show_condition = is_line_start }),
    s({ trig = ":idseparator:", name = "idseparator", dscr = "Word separator used in auto-generated section IDs. See Change the ID word separator." }, { t(":idseparator: "), i(1) }, { show_condition = is_line_start }),
    s({ trig = ":leveloffset:", name = "leveloffset", dscr = "Increases or decreases level of headings below assignment. A leading + or - makes the value relative." }, { t(":leveloffset: "), i(1, "0") }, { show_condition = is_line_start }),
    s({ trig = ":partnums:", name = "partnums", dscr = "Enables numbering of parts. See Number book parts. Book doctype only." }, { t(":"), i(1), t({ "partnums: ", "" }) }, { show_condition = is_line_start }),
    s({ trig = ":sectanchors:", name = "sectanchors", dscr = "Adds anchor in front of section title on mouse cursor hover." }, { t(":"), i(1), t({ "sectanchors: ", "" }) }, { show_condition = is_line_start }),
    s({ trig = ":sectids:", name = "sectids", dscr = "Generates and assigns an ID to any section that does not have an ID. See Disable automatic ID generation." }, { t(":"), i(1), t({ "sectids: ", "" }) }, { show_condition = is_line_start }),
    s({ trig = ":sectlinks:", name = "sectlinks", dscr = "Turns section titles into self-referencing links." }, { t(":"), i(1), t({ "sectlinks: ", "" }) }, { show_condition = is_line_start }),
    s({ trig = ":sectnums:", name = "sectnums", dscr = "Numbers sections to depth specified by `sectnumlevels`." }, { t(":sectnums: "), i(1, "all") }, { show_condition = is_line_start }),
    s({ trig = ":sectnumlevels:", name = "sectnumlevels", dscr = "Controls depth of section numbering." }, { t(":sectnumlevels: "), i(1, "3") }, { show_condition = is_line_start }),
    s({ trig = ":title-separator:", name = "title-separator", dscr = "Character used to separate document title and subtitle." }, { t(":title-separator: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":toc:", name = "toc", dscr = "Turns on table of contents and specifies its location." }, { t(":toc: "), c(1, { t("auto"), t("left"), t("right"), t("macro"), t("preamble") }) }, { show_condition = in_header }),
    s({ trig = ":toclevels:", name = "toclevels", dscr = "Maximum section level to display." }, { t(":toclevels: "), i(1, "2") }, { show_condition = in_header }),
    s({ trig = ":fragment:", name = "fragment", dscr = "Informs parser that document is a fragment and that it shouldn’t enforce proper section nesting." }, { t(":"), i(1), t({ "fragment: ", "" }) }, { show_condition = in_header }),
}

local general_content_and_formatting_attributes = {
    s({ trig = ":asset-uri-scheme:", name = "asset-uri-scheme", dscr = "Controls protocol used for assets hosted on a CDN." }, { t(":asset-uri-scheme: "), c(1, { t("https"), t("http") }) }, { show_condition = in_header }),
    s({ trig = ":cache-uri:", name = "cache-uri", dscr = "Cache content read from URIs." }, { t(":"), i(1), t({ "cache-uri: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":data-uri:", name = "data-uri", dscr = "Embed graphics as data-uri elements in HTML elements so file is completely self-contained." }, { t(":"), i(1), t({ "data-uri: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":docinfo:", name = "docinfo", dscr = "Read input from one or more DocBook info files." }, { t(":docinfo: "), c(1, { t("private"), t("shared"), t("shared-head"), t("private-head"), t("shared-footer"), t("private-footer") }) }, { show_condition = in_header }),
    s({ trig = ":docinfodir:", name = "docinfodir", dscr = "Location of docinfo files. Defaults to directory of source file if not specified." }, { t(":docinfodir: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":docinfosubs:", name = "docinfosubs", dscr = "AsciiDoc substitutions that are applied to docinfo content." }, { t(":docinfosubs: "), i(1, "attributes") }, { show_condition = in_header }),
    s({ trig = ":doctype:", name = "doctype", dscr = "Output document type." }, { t(":doctype: "), c(1, { t("article"), t("book"), t("inline"), t("manpage") }) }, { show_condition = in_header }),
    s({ trig = ":eqnums:", name = "eqnums", dscr = "Controls automatic equation numbering on LaTeX blocks in HTML output (MathJax). If the value is AMS, only LaTeX content enclosed in an `\\begin{ equation }...\\end{ equation }` container will be numbered. If the value is all, then all LaTeX blocks will be numbered. See equation numbering in MathJax." }, { t(":eqnums: "), c(1, { t("AMS"), t("all"), t("none") }) }, { show_condition = in_header }),
    s({ trig = ":hardbreaks-option:", name = "hardbreaks-option", dscr = "Preserve hard line breaks." }, { t(":"), i(1), t({ "hardbreaks-option: ", "" }) }, { show_condition = is_line_start }),
    s({ trig = ":hide-uri-scheme:", name = "hide-uri-scheme", dscr = "Hides URI scheme for raw links." }, { t(":"), i(1), t({ "hide-uri-scheme: ", "" }) }, { show_condition = is_line_start }),
    s({ trig = ":media:", name = "media", dscr = "Specifies media type of output and enables behavior specific to that media type. PDF converter only." }, { t(":media: "), c(1, { t("screen"), t("prepress"), t("print") }) }, { show_condition = in_header }),
    s({ trig = ":nofooter:", name = "nofooter", dscr = "Turns off footer." }, { t(":"), i(1), t({ "nofooter: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":nofootnotes:", name = "nofootnotes", dscr = "Turns off footnotes." }, { t(":"), i(1), t({ "nofootnotes: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":noheader:", name = "noheader", dscr = "Turns off header." }, { t(":"), i(1), t({ "noheader: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":notitle:", name = "notitle", dscr = "Hides the doctitle in an embedded document. Mutually exclusive with the `showtitle` attribute." }, { t(":"), i(1), t({ "notitle: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":outfilesuffix:", name = "outfilesuffix", dscr = "File extension of output file, including dot (`.`), such as `.html`." }, { t(":outfilesuffix: "), i(1, ".html") }, { show_condition = in_header }),
    s({ trig = ":pagewidth:", name = "pagewidth", dscr = "Page width used to calculate the absolute width of tables in the DocBook output." }, { t(":pagewidth: "), i(1, "425") }, { show_condition = in_header }),
    s({ trig = ":relfileprefix:", name = "relfileprefix", dscr = "The path prefix to add to relative xrefs." }, { t(":relfileprefix: "), i(1) }, { show_condition = is_line_start }),
    s({ trig = ":relfilesuffix:", name = "relfilesuffix", dscr = "The path suffix (e.g., file extension) to add to relative xrefs. Defaults to the value of the `outfilesuffix` attribute. (Preferred over modifying outfilesuffix)." }, { t(":relfilesuffix: "), i(1, ".html") }, { show_condition = is_line_start }),
    s({ trig = ":show-link-uri:", name = "show-link-uri", dscr = "Prints the URI of a link after the link text. PDF converter only." }, { t(":"), i(1), t({ "show-link-uri: ", "" }) }, { show_condition = is_line_start }),
    s({ trig = ":showtitle:", name = "showtitle", dscr = "Displays the doctitle in an embedded document. Mutually exclusive with the `notitle` attribute." }, { t(":"), i(1), t({ "showtitle: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":stem:", name = "stem", dscr = "Enables mathematics processing and interpreter." }, { t(":stem: "), c(1, { t("asciimath"), t("latexmath") }) }, { show_condition = in_header }),
    s({ trig = ":table-frame:", name = "table-frame", dscr = "Controls default value for `frame` attribute on tables." }, { t(":table-frame: "), c(1, { t("all"), t("ends"), t("sides"), t("none") }) }, { show_condition = is_line_start }),
    s({ trig = ":table-grid:", name = "table-grid", dscr = "Controls default value for `grid` attribute on tables." }, { t(":table-grid: "), c(1, { t("all"), t("cols"), t("rows"), t("none") }) }, { show_condition = is_line_start }),
    s({ trig = ":table-stripes:", name = "table-stripes", dscr = "Controls default value for `stripes` attribute on tables." }, { t(":table-stripes: "), c(1, { t("none"), t("even"), t("odd"), t("hover"), t("all") }) }, { show_condition = is_line_start }),
    s({ trig = ":tabsize:", name = "tabsize", dscr = "Converts tabs to spaces in verbatim content blocks (e.g., listing, literal)." }, { t(":tabsize: "), i(1, "4") }, { show_condition = is_line_start }),
    s({ trig = ":webfonts:", name = "webfonts", dscr = "Control whether webfonts are loaded when using the default stylesheet. When set to empty, uses the default font collection from Google Fonts. A non-empty value replaces the `family` query string parameter in the Google Fonts URL." }, { t(":"), i(1), t({ "webfonts: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":xrefstyle:", name = "xrefstyle", dscr = "Formatting style to apply to cross reference text." }, { t(":xrefstyle: "), c(1, { t("full"), t("short"), t("basic") }) }, { show_condition = is_line_start }),
}

local image_and_icon_attributes = {
    s({ trig = ":iconfont-cdn:", name = "iconfont-cdn", dscr = "If not specified, uses the cdnjs.com service. Overrides CDN used to link to the Font Awesome stylesheet." }, { t(":iconfont-cdn: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":iconfont-name:", name = "iconfont-name", dscr = "Overrides the name of the icon font stylesheet." }, { t(":iconfont-name: "), i(1, "font-awesome") }, { show_condition = in_header }),
    s({ trig = ":iconfont-remote:", name = "iconfont-remote", dscr = "Allows use of a CDN for resolving the icon font. Only relevant used when value of `icons` attribute is `font`." }, { t(":"), i(1), t({ "iconfont-remote: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":icons:", name = "icons", dscr = "Chooses images or font icons instead of text for admonitions. Any other value is assumed to be an icontype and sets the value to empty (image-based icons)." }, { t(":icons: "), c(1, { t("image"), t("font") }) }, { show_condition = in_header }),
    s({ trig = ":iconsdir:", name = "iconsdir", dscr = "Location of non-font-based image icons. Defaults to the icons folder under `imagesdir` if `imagesdir` is specified and `iconsdir` is not specified." }, { t(":iconsdir: "), i(1, "./images/icons") }, { show_condition = is_line_start }),
    s({ trig = ":icontype:", name = "icontype", dscr = "File type for image icons. Only relevant when using image-based icons." }, { t(":icontype: "), c(1, { t("png"), t("jpg"), t("gif"), t("svg") }) }, { show_condition = is_line_start }),
    s({ trig = ":imagesdir:", name = "imagesdir", dscr = "Location of image files." }, { t(":imagesdir: "), i(1, "./images") }, { show_condition = is_line_start }),
}

local source_highlighting_and_formatting_attributes = {
    s({ trig = ":coderay-css:", name = "coderay-css", dscr = "Controls whether CodeRay uses CSS classes or inline styles." }, { t(":coderay-css: "), i(1, "class") }, { show_condition = in_header }),
    s({ trig = ":coderay-linenums-mode:", name = "coderay-linenums-mode", dscr = "Sets how CodeRay inserts line numbers into source listings." }, { t(":coderay-linenums-mode: "), c(1, { t("table"), t("inline") }) }, { show_condition = is_line_start }),
    s({ trig = ":coderay-unavailable:", name = "coderay-unavailable", dscr = "Instructs processor not to load CodeRay. Also set if processor fails to load CodeRay." }, { t(":"), i(1), t({ "coderay-unavailable: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":highlightjsdir:", name = "highlightjsdir", dscr = "Location of the highlight.js source code highlighter library." }, { t(":highlightjsdir: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":highlightjs-theme:", name = "highlightjs-theme", dscr = "Name of theme used by highlight.js." }, { t(":highlightjs-theme: "), i(1, "github") }, { show_condition = in_header }),
    s({ trig = ":prettifydir:", name = "prettifydir", dscr = "Location of non-CDN prettify source code highlighter library." }, { t(":prettifydir: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":prettify-theme:", name = "prettify-theme", dscr = "Name of theme used by prettify." }, { t(":prettify-theme: "), i(1, "prettify") }, { show_condition = in_header }),
    s({ trig = ":prewrap:", name = "prewrap", dscr = "Wrap wide code listings." }, { t(":"), i(1), t({ "prewrap: ", "" }) }, { show_condition = is_line_start }),
    s({ trig = ":pygments-css:", name = "pygments-css", dscr = "Controls whether Pygments uses CSS classes or inline styles." }, { t(":pygments-css: "), i(1, "class") }, { show_condition = in_header }),
    s({ trig = ":pygments-linenums-mode:", name = "pygments-linenums-mode", dscr = "Sets how Pygments inserts line numbers into source listings." }, { t(":pygments-linenums-mode: "), c(1, { t("table"), t("inline") }) }, { show_condition = is_line_start }),
    s({ trig = ":pygments-style:", name = "pygments-style", dscr = "Name of style used by Pygments." }, { t(":pygments-style: "), i(1, "pastie") }, { show_condition = in_header }),
    s({ trig = ":pygments-unavailable:", name = "pygments-unavailable", dscr = "Instructs processor not to load Pygments. Also set if processor fails to load Pygments." }, { t(":"), i(1), t({ "pygments-unavailable: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":rouge-css:", name = "rouge-css", dscr = "Controls whether Rouge uses CSS classes or inline styles." }, { t(":rouge-css: "), i(1, "class") }, { show_condition = in_header }),
    s({ trig = ":rouge-linenums-mode:", name = "rouge-linenums-mode", dscr = "Sets how Rouge inserts line numbers into source listings. `inline` not yet supported by Asciidoctor. See asciidoctor#3641." }, { t(":rouge-linenums-mode: "), i(1, "table") }, { show_condition = is_line_start }),  -- not currently implemented, see #3641
    s({ trig = ":rouge-style:", name = "rouge-style", dscr = "Name of style used by Rouge." }, { t(":rouge-style: "), i(1, "github") }, { show_condition = in_header }),
    s({ trig = ":rouge-unavailable:", name = "rouge-unavailable", dscr = "Instructs processor not to load Rouge. Also set if processor fails to load Rouge." }, { t(":"), i(1), t({ "rouge-unavailable: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":source-highlighter:", name = "source-highlighter", dscr = "Specifies source code highlighter. Any other value is permitted, but must be supported by a custom syntax highlighter adapter." }, { t(":source-highlighter: "), c(1, { t("highlight.js"), t("coderay"), t("pygments"), t("rouge") }) }, { show_condition = in_header }),
    s({ trig = ":source-indent:", name = "source-indent", dscr = "Normalize block indentation in source code listings." }, { t(":source-indent: "), i(1, "0") }, { show_condition = is_line_start }),
    s({ trig = ":source-language:", name = "source-language", dscr = "Default language for source code blocks." }, { t(":source-language: "), i(1) }, { show_condition = is_line_start }),
    s({ trig = ":source-linenums-option:", name = "source-linenums-option", dscr = "Turns on line numbers for source code listings." }, { t(":"), i(1), t({ "source-linenums-option: ", "" }) }, { show_condition = is_line_start }),
}

local html_styling_attributes = {
    s({ trig = ":copycss:", name = "copycss", dscr = "Copy CSS files to output. Only relevant when the `linkcss` attribute is set." }, { t(":copycss: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":css-signature:", name = "css-signature", dscr = "Assign value to `id` attribute of HTML `<body>` element. Preferred approach is to assign an ID to document title." }, { t(":css-signature: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":linkcss:", name = "linkcss", dscr = "Links to stylesheet instead of embedding it. Can’t be unset in SECURE mode." }, { t(":"), i(1), t({ "linkcss: ", "" }) }, { show_condition = in_header }),
    s({ trig = ":max-width:", name = "max-width", dscr = "Constrains maximum width of document body. Not recommended. Use CSS stylesheet instead." }, { t(":max-width: "), i(1, "80em") }, { show_condition = in_header }),
    s({ trig = ":stylesdir:", name = "stylesdir", dscr = "Location of CSS stylesheets." }, { t(":stylesdir: "), i(1, "./stylesheets") }, { show_condition = in_header }),
    s({ trig = ":stylesheet:", name = "stylesheet", dscr = "CSS stylesheet file name. An empty value tells the converter to use the default stylesheet." }, { t(":stylesheet: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":toc-class:", name = "toc-class", dscr = "CSS class on the table of contents container." }, { t(":toc-class: "), i(1, "toc") }, { show_condition = in_header }),
}

local manpage_attributes = {
    s({ trig = ":mantitle:", name = "mantitle", dscr = "Metadata for man page output." }, { t(":mantitle: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":manvolnum:", name = "manvolnum", dscr = "Metadata for man page output." }, { t(":manvolnum: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":manname:", name = "manname", dscr = "Metadata for man page output." }, { t(":manname: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":manpurpose:", name = "manpurpose", dscr = "Metadata for man page output." }, { t(":manpurpose: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":man-linkstyle:", name = "man-linkstyle", dscr = "Link style in man page output." }, { t(":man-linkstyle: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":mansource:", name = "mansource", dscr = "Source (e.g., application and version) the man page describes." }, { t(":mansource: "), i(1) }, { show_condition = in_header }),
    s({ trig = ":manmanual:", name = "manmanual", dscr = "Manual name displayed in the man page footer." }, { t(":manmanual: "), i(1) }, { show_condition = in_header }),
}

-- Since these attributes deal with security, they can only be set from the API or CLI.
local security_attributes = {
    s({ trig = ":allow-uri-read:", name = "allow-uri-read", dscr = "Allows data to be read from URLs." }, { t(":"), i(1), t({ "allow-uri-read: ", "" }) }, { show_condition = not_api_cli_only }),
    s({ trig = ":max-attribute-value-size:", name = "max-attribute-value-size", dscr = "Limits maximum size (in bytes) of a resolved attribute value. Default value is only set in SECURE mode. Since attributes can reference attributes, it’s possible to create an output document disproportionately larger than the input document without this limit in place." }, { t(":max-attribute-value-size: "), i(1, "4096") }, { show_condition = not_api_cli_only }),
    s({ trig = ":max-include-depth:", name = "max-include-depth", dscr = "Curtail infinite include loops and to limit the opportunity to exploit nested includes to compound the size of the output document." }, { t(":max-include-depth: "), i(1, "64") }, { show_condition = not_api_cli_only }),
}

local other_snippets = {
    s({ trig = "note", name = "[NOTE] block" }, { t({ "[NOTE]", "====", "" }), i(1), t({ "", "====", "", "" }) }, { show_condition = is_line_start }),
    s({ trig = "tip", name = "[TIP] block" }, { t({ "[TIP]", "====", "" }), i(1), t({ "", "====", "", "" }) }, { show_condition = is_line_start }),
    s(
        { trig = "warning", name = "[WARNING] block" },
        { t({ "[WARNING]", "====", "" }), i(1), t({ "", "====", "", "" }) },
        { show_condition = is_line_start }
    ),
    s(
        { trig = "caution", name = "[CAUTION] block" },
        { t({ "[CAUTION]", "====", "" }), i(1), t({ "", "====", "", "" }) },
        { show_condition = is_line_start }
    ),
    s(
        { trig = "important", name = "[IMPORTANT] block" },
        { t({ "[IMPORTANT]", "====", "" }), i(1), t({ "", "====", "", "" }) },
        { show_condition = is_line_start }
    ),
    s({ trig = "note", name = "NOTE:" }, { t("NOTE: ") }, { show_condition = is_line_start }),
    s({ trig = "tip", name = "TIP:" }, { t("TIP: ") }, { show_condition = is_line_start }),
    s({ trig = "warning", name = "WARNING:" }, { t("WARNING: ") }, { show_condition = is_line_start }),
    s({ trig = "caution", name = "CAUTION:" }, { t("CAUTION: ") }, { show_condition = is_line_start }),
    s({ trig = "important", name = "IMPORTANT:" }, { t("IMPORTANT: ") }, { show_condition = is_line_start }),
    s(
        { trig = "source", name = "source block" },
        { t("[source, "), i(1, "laungurge"), t({ "]", "----", "" }), i(2), t({ "", "----", "", "" }) },
        { show_condition = is_line_start }
    ),
    s(
        { trig = "quote", name = "quote block" },
        { t("[quote, "), i(1, "author"), t(", "), i(2, "book"), t({ "]", "____", "" }), i(3), t({ "", "____", "", "" }) },
        { show_condition = is_line_start }
    ),
    s({ trig = "sidebar", name = "sidebar block" }, { t({ "****", "" }), i(1), t({ "", "****", "", "" }) }, { show_condition = is_line_start }),
    s(
        { trig = "image:", name = "image one line" },
        { t("image:"), i(1, "url"), t("["), i(2, "alt"), t(","), i(3, "width"), t(","), i(4, "height"), t("]") }
    ),
    s(
        { trig = "image::", name = "image block", dscr = "hello" },
        { t("image::"), i(1, "url"), t("["), i(2, "alt"), t(","), i(3, "width"), t(","), i(4, "height"), t("]") },
        { show_condition = is_line_start }
    ),
    s({ trig = "toc::", name = "toc", dscr = "toc macro" }, { t("toc::[]") }, { show_condition = is_line_start }),
    s(
        { trig = "ifgithub", name = "ifgithub" },
        { t({ "ifdef::env-github[]", "" }), i(1), t({ "", "endif::[]", "" }) },
        { show_condition = is_line_start }
    ),
    s({ trig = "link", name = "link macro" }, { t("link:"), i(1, "url"), t("["), i(2, "text"), t("]") }),
}

snippets = vim.iter({
    intrinsic_attributes,
    compliance_attributes,
    localization_and_numbering_attributes,
    document_metadata_attributes,
    section_title_and_table_of_contents_attributes,
    general_content_and_formatting_attributes,
    image_and_icon_attributes,
    source_highlighting_and_formatting_attributes,
    html_styling_attributes,
    manpage_attributes,
    security_attributes,
    other_snippets,
}):flatten():totable()

return snippets, autosnippets
