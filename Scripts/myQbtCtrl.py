#!/bin/python

import pycurl as pc
import os
import sys
from subprocess import Popen, PIPE, STDOUT
from urllib.parse import urlencode
from json import loads
from io import BytesIO

def post(addr, cookie, data) :
    c = pc.Curl()
    c.setopt(c.URL, addr)
    c.setopt(c.COOKIEFILE, cookie_loc)
    c.setopt(c.POSTFIELDS, urlencode(data))
    c.perform()
    c.close()

def dLim(addr, cookie_loc, args) :
    addr += '/transfer/setDownloadLimit'
    data = {'limit' : str(int(args[2])*1024)}
    post(addr, cookie_loc, data)

def dUnLim(addr, cookie_loc, args) :
    addr += '/transfer/setDownloadLimit'
    data = {'limit' : 'NaN'}
    post(addr, cookie_loc, data)

def pAll(addr, cookie_loc, args) :
    addr += '/torrents/pause'
    data = {'hashes' : 'all'}
    post(addr, cookie_loc, data)

def rAll(addr, cookie_loc, args) :
    addr += '/torrents/resume'
    data = {'hashes' : 'all'}
    post(addr, cookie_loc, data)

def add(addr, cookie_loc, args) :
    addr += '/torrents/add'
    url = ''
    if len(args) == 2 :
        proc = Popen(['wl-paste'], stdout=PIPE)
        url = proc.communicate()[0].decode('UTF-8').strip('\n')
    else :
        url = args[2]
    data = {
        'autoTMM' : 'false',
        'savepath' : '/mnt/external/Downloads/',
        'cookie' : '',
        'rename' : '',
        'category' : '',
        'paused' : 'false',
        'root_folder' : 'true',
        'dlLimit' : '',
        'upLimit' : '',
        'urls' : url
    }
    post(addr, cookie_loc, data)

def torrent_descr(torr) :
    #34 is limit from mako.
    name = torr['name']
    if len(name) > 34 :
        name = name[0:31] + '...'

    return (
        #'<span weight="bold">' +
        name +
        #'</span>' +
        '\n' +
        '{:5.1f}'.format(float(torr['progress']*100))+'%' + '   ' +
        '{:6.1f}'.format(float(torr['dlspeed'])/1024) + ' ↓    ' +
        '{:6.1f}'.format(float(torr['upspeed'])/1024) + ' ↑    ' + '\n')

def print_status(addr, cookie, args) :
    resp = BytesIO()

    c = pc.Curl()
    c.setopt(c.URL, addr+'/sync/maindata')
    c.setopt(c.COOKIEFILE, cookie_loc)
    c.setopt(c.WRITEFUNCTION, resp.write)
    c.perform()
    c.close()

    #print(resp.getvalue())

    resp_dict = loads(resp.getvalue())
    import pprint
    torrents = resp_dict['torrents'].values()
    torr_desc = ''
    for torr in torrents :
        torr_desc += torrent_descr(torr)
    Popen(['notify-send', '-c', 'torr', 'Torrents', torr_desc])
    return

funcs = {
    '--dUnLim' : dUnLim,
    '--dLim' : dLim,
    '--rAll' : rAll,
    '--pAll' : pAll,
    '--add' : add,
    '--status' : print_status
}

addr = 'pi:8080/api/v2'
cookie_loc = '/home/simon/.cache/myCookies/qbt'

#generate cookie
proc = Popen(['/home/simon/Scripts/myCreateCookieQBT.sh', cookie_loc])
proc.wait()

funcs[sys.argv[1]](addr, cookie_loc, sys.argv)
