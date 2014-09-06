#!/usr/bin/env python

import sys
from element_node import *
from src_code import *
import pdb

class ASAnalyzer(object):

    def __init__(self):
        super(ASAnalyzer, self).__init__()
        self.__top_node = None
        self.__current_node = None
        self.__add_new_node("top", "top")

    def analyze(self, src_code_file_name):
        self.__current_node = self.__top_node
        self.__add_new_node("file", src_code_file_name)
        self.__src_code = SrcCode(src_code_file_name)
        self.__run_analyze()

    def __run_analyze(self):
        for line in self.__src_code.get_available_line():
            element_str_array = self.__parse_line(line)
            for elem_str in element_str_array:
                if elem_str is "{":
                    self.__current_node.increment_scope()
                    line_add_element = self.__current_node
                elif elem_str is "}":
                    self.__current_node.decrement_scope()
                    if self.__current_node.is_scope_ended():
                        line_add_element = self.__current_node
                        self.__current_node = self.__current_node.get_parent()
                else:
                    elem_type, elem_name = elem_str.split(" ", 1)
                    self.__add_new_node(elem_type, elem_name)
                    line_add_element = self.__current_node

            line_add_element.add_line_num(1)

    def __parse_line(self, line):
        element_array = re.findall('package\s+\w+|class\s+\w+|function\s.*\(.*\)|{|}',line)
        return element_array

    def __get_element_name(self, str):
        pass

    def __add_new_node(self, elem_type, elem_name):
        element = ElementNode(self.__current_node, elem_type, elem_name)
        if not self.__top_node:
            self.__top_node = element
        self.__current_node = element


    def get_total_line_num(self):
        return self.__top_node.get_line_num()

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

    def print_tree(self):
        self.__top_node.describe()


if __name__ == '__main__':
    filename = sys.argv[1]
    analyzer = ASAnalyzer()
    for file_name in sys.argv[1:]:
        analyzer.analyze(file_name)
    analyzer.print_tree()
    print "\n----------------"
    print "total line: " + str(analyzer.get_total_line_num())
    #print analyzer.src_code.get_string()
