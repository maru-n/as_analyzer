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
        self.__used = False
        self.__use_packages = []
        self.__use_function = []
        self.__inner_token_names = []

    def add_token_name(self, token_name):
        self.__inner_token_names.append(token_name)

    def get_token_names(self):
        return self.__inner_token_names

    def add_use_packag_name(self, import_package_name):
        self.__use_packages.append(import_package_name)

    def get_use_package_names(self):
        use_packages = []
        use_packages.extend(self.__use_packages)
        if not self.is_top():
            use_packages.extend(self.get_parent().get_use_package_names())
        return use_packages

    def add_use_function_name(self, use_function_name):
        self.__use_function.append(use_function_name)

    def get_use_function_names(self):
        use_function_names = []
        use_function_names.extend(self.__use_function)
        for c in self.get_child():
            use_function_names.extend(c.get_use_function_names())
        return use_function_names

    def set_extends_class_name(self, extends_class_name):
        self.__extend_class_name = extends_class_name

    def get_extends_class_name(self):
        return self.__extend_class_name

    def have_extends_class(self):
        return self.type == "class" and hasattr(self, "__extend_class_name")

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

    def set_used(self, used=True):
        self.__used = used

    def is_used(self):
        if self.__used:
            return True
        else:
            for c in self.get_child():
                if c.is_used():
                    return True
        return False

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
        s = self.type + " " + self.name
        s += " (l:" + str(self.__line_num) + ")"
        s += " [used]" if self.is_used() else ""
        """
        s += "(function_call:"
        for f in self.get_use_function_names():
            s = s + f + ","
        s += ")"
        """
        return s






