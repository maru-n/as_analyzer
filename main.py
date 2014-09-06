#!/usr/bin/env python

import sys
import re

def remove_comment(text):
    comment_reg_str = '//.*\n'
    comment_reg = re.compile(comment_reg_str, re.MULTILINE)
    text = re.sub(comment_reg, '\n', text)
    return text

def remove_blank(text):
    blank_reg_str = '^\s*\n'
    blank_reg = re.compile(blank_reg_str, re.MULTILINE)
    text = re.sub(blank_reg, '', text)
    return text

def cleanup_source_text(text):
    text = remove_comment(text)
    text = remove_blank(text)
    return text

if __name__ == '__main__':
    filename = sys.argv[1]
    file = open('sample.as', 'r')
    text = file.read()
    text = cleanup_source_text(text)
    print text

