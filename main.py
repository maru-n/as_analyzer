#!/usr/bin/env python

import sys
import re

def remove_blank(text):
    res = re.sub(re.compile('^\s*\n', re.MULTILINE), '', text)
    return res

if __name__ == '__main__':
    filename = sys.argv[1]
    file = open('sample.as', 'r')
    text = file.read()
    text = remove_blank(text)
    print text

