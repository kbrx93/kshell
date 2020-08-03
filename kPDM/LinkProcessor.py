from abc import abstractmethod
from typing import List
import re
import os

class AbstractLinkHandler(object):
    """
    The interface of link handler
    """

    @abstractmethod
    def handle(self, content: str) -> List:
        pass

    def find_bug_no(self, content: str) -> str:
        bugNum_match = re.search('<title.*?>(.*?)</title>', content, re.S)
        if not bugNum_match:
            return None
        return bugNum_match.group(1).split(']', 1)[0][1:]

class AttachmentLinkHandler(AbstractLinkHandler):

    def __init__(self):
        self._support_ext = ['zip']
        self._detail_page_pre_url = 'https://www.com/'

    def handle(self, content):
        result = []
        attachment_link_list = re.findall('<a href="(.*?)".*?>(.*?)</a>', content, re.S)
        bug_num = self.find_bug_no(content)
        for link, text in attachment_link_list:
            if 'downloadAttachment' in link and os.path.splitext(text)[-1][1:] in self._support_ext:
                result.append((f'{self._detail_page_pre_url}{link}', f'{bug_num}_{hash(text)[-6:]}'))
        return result

class LinkContext(object):
    """
    The LinkContext defines the interface to clients
    """

    def __init__(self, linkHandlers: List[AbstractLinkHandler]) -> None:
        """
        Usually LinkContext provides the way to set link handler through the constructor, 
        also accepts change it in running time by setter method
        """
        self._linkHandlers = linkHandlers

    @property
    def linkHandlers(self) -> AbstractLinkHandler:
        return self._linkHandlers

    @linkHandlers.setter
    def linkHandlers(self, handlers: List[AbstractLinkHandler]) -> None:
        self._linkHandlers = handlers

    def addLinkHander(self, handler: AbstractLinkHandler) -> None:
        if self._linkHandlers:
            self._linkHandlers.append(handler)
        else:
            print('linkHandlers is invaild')

    def handle(self, content: str) -> List:
        result = []
        for handler in self._linkHandlers:
            print('{} process -- E'.format(handler.__class__.__name__))
            result.extend(handler.handle(content))
            print('{} process -- X'.format(handler.__class__.__name__))
        return result