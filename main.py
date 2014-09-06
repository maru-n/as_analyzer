#!/usr/bin/env python

import sys

def test1():
    print "a"

if __name__ == '__main__':
    filename = sys.argv[1]
    file = open(filename, 'r')
    for l in file.readline():
        print l



