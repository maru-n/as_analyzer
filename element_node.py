class ElementNode(object):

    def __init__(self, parent_node, element_type, element_name):
        super(ElementNode, self).__init__()
        self.__parent_node = parent_node
        if self.__parent_node:
            self.__parent_node.add_child(self)
        self.__child_node = []
        self.type = element_type
        self.name = element_name
        self.__line_num = 0
        self.__scope_num = 0
        self.__use_num = 0
        self.__use_packages = []
        self.__use_function = []

    def add_use_packag_names(self, import_package_name):
        self.__use_packages.append(import_package_name)

    def get_use_package_names(self):
        use_packages = []
        use_packages.extend(self.__use_packages)
        if not self.is_top():
            use_packages.extend(self.get_parent().get_use_package_names())
        return use_packages

    def add_use_function_names(self, use_function_name):
        self.__use_function.append(use_function_name)

    def get_use_function_name(self):
        return self.__use_function

    def add_child(self, element_node):
        self.__child_node.append(element_node)

    def get_child(self):
        return self.__child_node

    def get_parent(self):
        return self.__parent_node

    def is_top(self):
        if self.__parent_node is None:
            return True
        else:
            return False

    def add_use_num(self, num):
        self.__use_num += num

    def get_use_num(self):
        return self.__use_num

    def is_used(self):
        if self.__use_num <= 0:
            return False
        else:
            return True

    def find_nodes(self, type, name=None):
        if self.type == type and (name is None or self.name == name):
            return [self]
        else:
            nodes = []
            for c in self.get_child():
                nodes.extend(c.find_nodes(type, name))
            return nodes

    def add_line_num(self, n):
        if self.__parent_node is not None:
            self.__parent_node.add_line_num(n)
        self.__line_num += n

    def get_line_num(self):
        return self.__line_num

    def increment_scope(self):
        self.__scope_num += 1

    def decrement_scope(self):
        self.__scope_num -= 1

    def is_scope_ended(self):
        if self.__scope_num == 0:
            return True
        else:
            return False

    def get_scope_nest_num(self):
        return self.__scope_num

    def describe(self, prefix=""):
        print prefix + str(self)
        for c in self.__child_node:
            c.describe(prefix = prefix+"  ")

    def __str__(self):
        s = self.type + " " + self.name + " (l:" + str(self.__line_num) + ")"
        s += "(function_call:"
        for f in self.get_use_function_name():
            s = s + f + ","
        s += ")"
        return s






