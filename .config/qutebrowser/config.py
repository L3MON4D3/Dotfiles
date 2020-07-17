import subprocess
import yaml

def read_xresources(prefix):
    props = {}
    x = subprocess.run(['xrdb', '-query'], stdout=subprocess.PIPE)
    lines = x.stdout.decode().split('\n')
    for line in filter(lambda l : l.startswith(prefix), lines):
        prop, _, value = line.partition(':\t')
        props[prop] = value
    return props

xresources = read_xresources('*')

with (config.configdir / 'colors.yml').open() as f:
    yaml_data = yaml.safe_load(f)

def dict_attrs(obj, path=''):
    if isinstance(obj, dict):
        for k, v in obj.items():
            yield from dict_attrs(v, '{}.{}'.format(path, k) if path else k)
    else:
        yield path, obj

for k, v in dict_attrs(yaml_data):
    config.set(k, xresources[v])

c.fonts.tabs.selected = '13pt Fira Code'
c.fonts.tabs.unselected = '13pt Fira Code'
c.fonts.hints = '13pt Fira Code'
c.fonts.keyhint = '13pt Fira Code'
c.fonts.prompts = '13pt Fira Code'
c.fonts.downloads = '13pt Fira Code'
c.fonts.statusbar = '13pt Fira Code'
c.fonts.contextmenu = '13pt Fira Code'
c.fonts.messages.info = '13pt Fira Code'
c.fonts.debug_console = '13pt Fira Code'
c.fonts.completion.entry = '13pt Fira Code'
c.fonts.completion.category = '13pt Fira Code'

c.tabs.title.format = '{current_title}'
c.tabs.favicons.show = 'never'
c.tabs.indicator.width = 0
c.tabs.show = 'switching'

c.url.default_page = 'file:///home/simon/Code/Html/Startpage/index.html'
c.url.start_pages = 'file:///home/simon/Code/Html/Startpage/index.html'

c.statusbar.show = 'never'

c.editor.command = ['st', '-e', 'nvim', '{}']
