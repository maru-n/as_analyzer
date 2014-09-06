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

    def add_child(self, element_node):
        self.__child_node.append(element_node)

    def get_child(self):
        return self.__child_node

    def get_parent(self):
        return self.__parent_node

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

    def __str__(self, prefix=""):
        return self.type + " " + self.name + " (l:" + str(self.__line_num) + ")"
