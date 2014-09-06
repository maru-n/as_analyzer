#!/usr/bin/env python

import sys
import re

class Element:
   def addOneStep():
       self.lines = self.lines + 1

class ASParser(object):

    def __init__(self, src_code_file_name):
        super(ASParser, self).__init__()
        file = open(src_code_file_name, 'r')
        self.org_src_code = file.read()
        self.src_code = cleanup_source_code(self.org_src_code)

    def get_total_line_num():
        #TODO:
        print "this is not implemented!"
        return 100

    def get_packages():
        #TODO:
        print "this is not implemented!"
        return ["package1", "package2"]

    def get_classes():
        #TODO:
        print "this is not implemented!"
        return ["classA", "classB", "classC"]

    def get_methods():
        #TODO:
        print "this is not implemented!"
        return ["method_a", "method_b", "method_c", "method_d"]

    def print_src_code(self):
        print self.src_code

    def print_org_src_code(self):
        print self.org_src_code

    def get_available_line(self):
        line_num = 0
        lines = self.src_code.split('\n')[:-1]
        while True:
            try:
                yield lines[line_num]
                line_num += 1
            except IndexError, e:
                raise StopIteration


def remove_comment(src_code_text):
    comment_reg_str = '//.*\n'
    comment_reg = re.compile(comment_reg_str, re.MULTILINE)
    src_code_text = re.sub(comment_reg, '\n', src_code_text)
    return src_code_text


def remove_blank(src_code_text):
    blank_reg_str = '^\s*\n'
    blank_reg = re.compile(blank_reg_str, re.MULTILINE)
    src_code_text = re.sub(blank_reg, '', src_code_text)
    return src_code_text


def cleanup_source_code(src_code_text):
    src_code_text = remove_comment(src_code_text)
    src_code_text = remove_blank(src_code_text)
    return src_code_text

def check_line_type(text):
    if is_package(text):
        return "package"
    elif is_class(text):
        return "class"
    elif is_method(text):
        return "method"
    elif has_left_brace(text):
        return "control flow"
    elif has_right_brace(text):
        return "finish"
    return "line"

def is_package(text):
    package_reg_str = 'package [a-zA-Z]*{\n'
    package_reg     = re.compile(package_reg_str, re.MULTILINE)
    return re.match(package_reg, text)

def is_class(text):
    class_reg_str   = 'class [a-zA-Z]*{\n'
    class_reg       = re.compile(class_reg_str, re.MULTILINE)
    return re.match(class_reg, text)

def is_method(text):
    method_reg_str  = 'function [a-zA-Z]*{\n'
    method_reg      = re.compile(method_reg_str, re.MULTILINE)
    return re.match(method_reg, text)

if __name__ == '__main__':
    filename = sys.argv[1]
    parser = ASParser(filename)

    element_stack = []
    for 
        line_text = parser.get_available_line()
        line_type = check_line_type(line_text)
        if line_type == "package" || line_type == "class" || line_type == "method" || line_type == "control flow":
            element = Element.new(line_type)
            element_stack.push(element)
        else if line_type == "finish":
            element_stack.pop
        current_element = element_stack.last_object
        current_element.addOneStep()

    parser.print_src_code()
    #parser.print_org_src_code()
    for l in parser.get_available_line():
        #print l + "  :" +str(len(l))
        print l
