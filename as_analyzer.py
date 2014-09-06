#!/usr/bin/env python

import sys
from elements import *
from src_code import *

class ASAnalyzer(object):

    def __init__(self, src_code_file_name):
        super(ASAnalyzer, self).__init__()
        self.src_code = SrcCode(src_code_file_name)

    def __analyze(self):
        element_stack = []
        """
        line_text = parser.get_available_line()
        line_type = check_line_type(line_text)
        if line_type == "package" || line_type == "class" || line_type == "method" || line_type == "control flow":
            element = Element.new(line_type)
            element_stack.push(element)
        else if line_type == "finish":
            element_stack.pop
            current_element = element_stack.last_object
            current_element.addOneStep()
        """
        pass

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
    analyzer = ASAnalyzer(filename)
    src_code = analyzer.src_code

    for l in src_code.get_available_line():
        print l
