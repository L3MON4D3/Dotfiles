c.fonts.tabs.selected = '13pt Inter'
c.fonts.tabs.unselected = '13pt Inter'
c.fonts.hints = '13pt Inter'
c.fonts.keyhint = '13pt Inter'
c.fonts.prompts = '13pt Inter'
c.fonts.downloads = '13pt Inter'
c.fonts.statusbar = '13pt Inter'
c.fonts.contextmenu = '13pt Inter'
c.fonts.messages.info = '13pt Inter'
c.fonts.debug_console = '13pt Inter'
c.fonts.completion.entry = '13pt Inter'
c.fonts.completion.category = '13pt Inter'

c.content.javascript.clipboard = 'access-paste'

c.tabs.title.format = '{current_title}'
c.tabs.favicons.show = 'never'
c.tabs.indicator.width = 0
c.tabs.show = 'switching'

c.url.default_page = 'http://google.com'
c.url.start_pages = 'http://google.com'
c.downloads.prevent_mixed_content = False

c.statusbar.show = 'never'

c.editor.command = ['foot', 'nvim', '{}']

config.load_autoconfig(False)
c.url.searchengines = {
    'DEFAULT': 'https://google.com/search?q={}',
    '!k': 'https://kagi.com/search?q={}',
    '!d': 'https://duckduckgo.com/?ia=web&q={}',
    '!a': 'https://annas-archive.org/search?q={}',
    '!np': 'https://search.nixos.org/packages?channel=24.11&type=packages&query={}',
    '!no': 'https://search.nixos.org/options?channel=24.11&query={}',
}

config.bind("pf", "spawn --userscript qute-pass --username-target=secret --username-pattern=\"[\\w]+: ?(.*)\"")
config.bind("pp", "spawn --userscript qute-pass --username-target=secret --username-pattern=\"[\\w]+: ?(.*)\" --password-only ")
config.bind("pu", "spawn --userscript qute-pass --username-target=secret --username-pattern=\"[\\w]+: ?(.*)\" --username-only ")
config.bind("e", "edit-url")
