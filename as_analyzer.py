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

    def analyze_structure(self, src_code_file_name):
        self.__current_node = self.__top_node
        self.__add_new_node("file", src_code_file_name)
        self.__src_code = SrcCode(src_code_file_name)
        self.__run_parse()

    def analyze_call_dependency(self):
        self.__run_call_analysis()

    def __run_parse(self):
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
                    if elem_type == "import":
                        self.__current_node.add_use_package(elem_name)
                    else:
                        self.__add_new_node(elem_type, elem_name)
                        line_add_element = self.__current_node
            line_add_element.add_line_num(1)

    def __run_call_analysis(self):
        pass

    def __parse_line(self, line):
        element_array = re.findall('package\s+\w+[\.\w+]*|class\s+\w+|function\s.*\(.*\)|import\s+\w+[\.\w+]*|{|}',line)
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

    def get_packages(self):
        return self.__top_node.get_nodes("package")

    def get_classes(self):
        return self.__top_node.get_nodes("class")

    def get_functions(self):
        return self.__top_node.get_nodes("function")

    def print_tree(self):
        self.__top_node.describe()


if __name__ == '__main__':
    filename = sys.argv[1]
    analyzer = ASAnalyzer()
    for file_name in sys.argv[1:]:
        analyzer.analyze_structure(file_name)
    analyzer.print_tree()
    print "\n----------------"
    print "total line: " + str(analyzer.get_total_line_num())
    classes = analyzer.get_classes()
    print "classes num:" + str(len(classes))
    #print "classes:"
    #print [c.name for c in classes]
    functions = analyzer.get_functions()
    print "function num:" + str(len(functions))
    #print "classes:"
    #print [c.name for c in classes]

    #print analyzer.src_code.get_string()
