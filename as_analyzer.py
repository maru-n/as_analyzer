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
                    elem_type = elem_str.split(" ")[0]
                    elem_name = elem_str.split(" ")[-1]
                    if elem_type == "import":
                        self.__current_node.add_use_packag_name(elem_name)
                    elif elem_type == "call_function":
                        self.__current_node.add_use_function_name(elem_name)
                    elif elem_type == "extends":
                        self.__current_node.set_extends_class_name(elem_name)
                    else:
                        self.__add_new_node(elem_type, elem_name)
                        line_add_element = self.__current_node
            line_add_element.add_line_num(1)

    def analyze_call_dependency(self, entry_poinst_type="class", entry_poinst_name="Main"):
        entry_point = self.__top_node.find_nodes(entry_poinst_type, entry_poinst_name)
        if len(entry_point) != 1:
            raise Exception("No entry point: " + entry_poinst_type + "." + entry_poinst_name)
        else:
            entry_point = entry_point[0]

        called_functions = [ f for f in entry_point.find_nodes("function")]
        called_functions.extend(self.__top_node.find_nodes("function", entry_point.get_extends_class_name()))

        while len(called_functions) != 0:
            target_function = called_functions.pop(0)
            if target_function.is_used():
                continue
            target_function.set_used()

            for fn in target_function.get_use_function_names():
                use_function = self.__top_node.find_nodes("function", fn)
                if len(use_function) > 1:
                    print "Function name is overlapped: " +  use_function[0].name + " in"
                    print "    ",
                    for i in use_function:
                        print i.get_parent().name + ",",
                    print ""

                called_functions.extend(use_function)


    def __parse_line(self, line):
        element_array = re.findall(
            'package\s+\w+[\.\w+]*|class\s+\w+|extends\s+\w+|class\s+\w+|function\s.*\(.*\)|import\s+\w+[\.\w+]*|new\s+\w+\(.*\)|\.\w+\(.*\)|{|}', line)
        for i,e in enumerate(element_array):
            if e[0] == ".":
                element_array[i] = "call_function " + re.sub("\.|\(.*\)", "", e)
            elif e[0:3] == "new":
                element_array[i] = "call_function " + re.sub("new|\(.*\)", "", e)
            elif e[0:8] == "function":
                element_array[i] = "function " + re.sub("function|\(.*\)", "", e)
        print element_array
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

    def get_files(self):
        return self.__top_node.find_nodes("file")

    def get_packages(self):
        return self.__top_node.find_nodes("package")

    def get_classes(self):
        return self.__top_node.find_nodes("class")

    def get_functions(self):
        return self.__top_node.find_nodes("function")

    def print_tree(self):
        self.__top_node.describe()

    def print_summary(self):
        print "total line: " + str(self.get_total_line_num())
        files = self.get_files()
        used_files = [f for f in files if f.is_used()]
        used_line = 0
        unused_line = 0
        for f in files:
            if f.is_used():
                used_line += f.get_line_num()
            else:
                unused_line += f.get_line_num()
        print "files"
        print "  used  : " + str(len(used_files)) + " (l:" + str(used_line) + ")"
        print "  unused: " + str(len(files) - len(used_files)) + " (l:" + str(unused_line) + ")"
        print "  total : " + str(len(files)) + " (l:" + str(used_line+unused_line) + ")"
        classes = self.get_classes()
        used_classes = [c for c in classes if c.is_used()]
        print "class"
        print "  used  : " + str(len(used_classes))
        print "  unused: " + str(len(classes) - len(used_classes))
        print "  total : " + str(len(classes))
        functions = self.get_functions()
        used_functions = [f for f in functions if f.is_used()]
        print "function"
        print "  used  : " + str(len(used_functions))
        print "  unused: " + str(len(functions) - len(used_functions))
        print "  total : " + str(len(functions))
        print "\nunused classes:"
        for c in [c for c in classes if not c.is_used()]:
            print c.get_parent().name + "/" + c.name
        print ""
        for c in classes:
            print c.get_parent().get_parent()
        """
        print "\nunused functions:"
        for f in [f for f in functions if not f.is_used()]:
            print f.get_parent().get_parent().name + "/" + f.get_parent().name + "/" + f.name
        """


if __name__ == '__main__':
    filename = sys.argv[1]
    analyzer = ASAnalyzer()
    for file_name in sys.argv[1:]:
        analyzer.analyze_structure(file_name)
    analyzer.analyze_call_dependency()

    analyzer.print_tree()
    print "\n----------------"
    analyzer.print_summary()
