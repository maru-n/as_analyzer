import re
from elements import *

class SrcCode(object):

    def __init__(self, src_code_file_name):
        super(SrcCode, self).__init__()
        file = open(src_code_file_name, 'r')
        self.org_src_code = file.read()
        self.src_code = self.__cleanup_source_code(self.org_src_code)

    def get_org_string(self):
        return self.org_src_code

    def get_string(self):
        return self.src_code

    def get_available_line(self):
        line_num = 0
        lines = self.src_code.split('\n')[:-1]
        while True:
            try:
                yield lines[line_num]
                line_num += 1
            except IndexError:
                raise StopIteration

    def __remove_comment(self, src_code_text):
        multi_line_comment_reg = re.compile("/\*((?:.|\n)*?)\*/")
        src_code_text = re.sub(multi_line_comment_reg, '', src_code_text)
        single_line_comment_reg = re.compile('//.*\n', re.MULTILINE)
        src_code_text = re.sub(single_line_comment_reg, '\n', src_code_text)
        return src_code_text

    def __remove_blank(self, src_code_text):
        blank_reg_str = '^\s*\n'
        blank_reg = re.compile(blank_reg_str, re.MULTILINE)
        src_code_text = re.sub(blank_reg, '', src_code_text)
        return src_code_text

    def __cleanup_source_code(self, src_code_text):
        src_code_text = self.__remove_comment(src_code_text)
        src_code_text = self.__remove_blank(src_code_text)
        return src_code_text
