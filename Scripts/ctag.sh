#!/bin/sh
clang -M $* | sed -e 's/[\\ ]/\n/g' | \
        sed -e '/^$/d' -e '/\.o:[ \t]*$/d' | ctags -L - --c++-kinds=+p --fields=+iaS
