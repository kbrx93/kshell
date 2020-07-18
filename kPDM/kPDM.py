#! /usr/bin/env python3
# -*- coding: UTF-8 -*- 

import requests
import os
import sys
from http.cookiejar import LWPCookieJar
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util import Retry
import re
import execjs
import zipfile
import time

def get_current_path():
    for path in sys.path:
        try:
            if os.path.basename(__file__) in os.listdir(path):
                return path
        except Exception as e:
            print(e)

class PDM(object):
    '''
    PDM Manager
    '''

    def __init__(self):
        # Common Param
        self.headers = {
            'Host': 'pdm.vivo.xyz',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36'
        }

        # URL
        self.detail_page_pre_url = 'http://pdm.vivo.xyz'
        self.pre_url = 'http://pdm.vivo.xyz/rdms'
        self.pre_login_url = 'http://pdm.vivo.xyz/rdms/login.jsp'
        self.login_url = 'http://pdm.vivo.xyz/rdms/authorize.do?method=login'
        self.bug_list_url = 'http://pdm.vivo.xyz/rdms/personal/actions/personalBugQuery.do?method=resetMyQuery'
        
        # Path Setting
        self.log_zip_pre_path = '/opt4/zhouhaobin/log/log_zip'
        self.log_extract_pre_path = '/opt4/zhouhaobin/log/log_extract'
        self.support_ext = ['zip']
        
        # Session param and Cookie handle data
        self.max_retries = 5
        self.cookie_test_url = 'http://pdm.vivo.xyz/rdms/Portal.jsp'
        self.cookie_filename = os.path.join(get_current_path(), 'cookie.txt')
        self.invaild_text = "top.location.href='/rdms/login.jsp'"
        self.session = None

        self.login_username = os.environ.get('username') if os.environ.get('username') else '11104457'
        self.login_password = os.environ.get('password')

        self.rsa_js_filename = os.path.join(get_current_path(), 'des.js')
        self.sleep_time = 3

    def getCookie(self):
        '''
        save cookie to file and  test cookie,
        if invaild, get new one and bind to self.headers
        '''
        s = requests.Session()
        # get cookie file to test, if invaild, to step 1, else fit to self.header and return
        
        load_cookiejar = LWPCookieJar()
        if os.path.exists(self.cookie_filename):
            #从文件中加载cookies(LWP格式)
            load_cookiejar.load(self.cookie_filename, ignore_discard=True, ignore_expires=True)
            #工具方法转换成字典
            load_cookies = requests.utils.dict_from_cookiejar(load_cookiejar)
            #工具方法将字典转换成RequestsCookieJar，赋值给session的cookies.
            s.cookies = requests.utils.cookiejar_from_dict(load_cookies)
        # s.cookies = MozillaCookieJar(filename=self.cookie_filename)
        # set max retry entries -> 5
        s.mount('http://', HTTPAdapter(max_retries=Retry(total=5, method_whitelist=frozenset(['GET', 'POST']))))
        try:
            test_resp = s.get(self.cookie_test_url)
        except requests.exceptions.RequestException as e:
            print('test cookie failed')
            return None
        # Test cookie vaild
        if not self.invaild_text in test_resp.text:
            print('Cookie vaild')
            self.session = s
            return s.cookies
        # Invaild Cookie, get new Cookie
        print('Store Cookie invaild, get new one...')
        try:
            # Get login info
            pre_login_resp = s.get(self.pre_login_url)
            if not pre_login_resp.status_code == 200:
                print('Get key or sessId failed')
                return None
            # find key and sessId
            key_match = re.search(r"\('input\[name=password\]'\)\.val\(\), '(.*?)'", pre_login_resp.text, re.S)
            if not key_match:
                print('get key failed')
                return None
            key = key_match.group(1)
            sessId_match = re.search('<input.*?name="sessId".*?value="(.*?)".*?>', pre_login_resp.text, re.S)
            if not sessId_match:
                print('get sessid failed')
                return None
            sessId = sessId_match.group(1)
            rsaPwd = ''
            with open(self.rsa_js_filename, 'r', encoding='utf-8') as f:
                des = execjs.compile(f.read())
                rsaPwd = str(des.call('encMe', self.login_password, key))
            if not rsaPwd:
                print('get rsaPwd failed')
                return None
            login_data = {
                'redirectUrl': '',
                'productCode': 'Portal',
                'extParams': '',
                'vu': '',
                'sessId': sessId,
                'username': self.login_username,
                'rsaPassword': rsaPwd,
                'password': self.login_password,
                'savePassword': 'true',
                'autoLogin': 'on'
            }
            # Login Action
            login_resp = s.post(self.login_url, data=login_data)
            if login_resp.status_code == 200:
                print('Get new cookie done ')
                #保存cookie到文件
                #ignore_discard的意思是即使cookies将被丢弃也将它保存下来
                #ignore_expires的意思是如果在该文件中cookies已经存在，则覆盖原文件写入
                with open(self.cookie_filename, 'w') as f:
                    f.seek(0)
                    f.truncate()
                new_cookie_jar = LWPCookieJar(self.cookie_filename)
                requests.utils.cookiejar_from_dict({c.name: c.value for c in s.cookies}, new_cookie_jar)
                new_cookie_jar.save(ignore_discard=True,ignore_expires=True)
                self.session = s
                return s.cookies
            else:
                print('Get new Cookie failed')
                return None
        except requests.exceptions.RequestException as e:
            print('Get Pre login info failed')
            return None

    def get_list_page(self, url):
        '''
        get PDM bug list page
        @return bug list
        '''
        data = {
            'nextPage': 1,
            'selectedQuery': 'false',
            'exportExcel': 'false',
            'exportAll': 'false',
            'exportExcelNextPage': 'false',
            'advanceQuery': 'false',
            'QR_Name': 'qr',
            'QR_CL_qr': 'com.chinaspis.personal.query.PersonalBugQuery',
            'action': 'executeQuery',
            'executeQueryClass': 'com.chinaspis.personal.query.PersonalBugQuery',
            'forwardPage': '/personal/views/listPersonalBugView.jsp',
            'functionID': 'PersonalBug_all',
            'objectId': '',
            'executeQuery': 'true',
            'newQuery': 'true',
            'pagination': 'true',
            'orderField': 'updated',
            'order': 'DESC',
            'pageList': 0,
            'queryType': 1,
            'selectQueryType': 'all',
            'QR_qr_created[1]_Condition': 2,
            'QR_qr_created[1]': '',
            'QR_qr_created[2]_Condition': 8,
            'QR_qr_created[2]': '',
            'QR_qr_status[1]_Condition': 32,
            'QR_qr_status[1]': 'ISSUE_CLOSED',
            'QR_qr_status[2]_Condition': 32,
            'QR_qr_status[3]_Condition': 32,
            'QR_qr_status[4]_Condition': 32,
            'QR_qr_status[5]_Condition': 32,
            'QR_qr_status[6]_Condition': 32,
            'QR_qr_duplicateBug_Condition': 32,
            'QR_qr_tag[1]_Condition': 1024,
            'QR_qr_tag[2]_Condition': 1024,
            'QR_qr_tag[3]_Condition': 1024,
            'QR_qr_tag[4]_Condition': 1024,
            'QR_qr_tag[5]_Condition': 1024,
            'QR_qr_tag[6]_Condition': 1024,
            'QR_qr_tag[7]_Condition': 1024,
            'QR_qr_tag[8]_Condition': 1024,
            'QR_qr_tag[9]_Condition': 1024,
            'QR_qr_tag[10]_Condition': 1024,
            'QR_qr_tag[11]_Condition': 1024,
            'QR_qr_tag[12]_Condition': 1024,
            'QR_qr_tag[13]_Condition': 1024,
            'QR_qr_tag[14]_Condition': 1024,
            'QR_qr_projectId_Condition': 16,
            'QR_qr_key|title_Condition': 64,
            'QR_qr_key|title': '',# search title
            'QR_qr_description_Condition': 64,
            'QR_qr_description': '',
            'QR_qr_priority_Condition': 16,
            'QR_qr_status_Condition': 16,
            'QR_qr_status': ['ISSUE_OPEN', 'ISSUE_REOPENED', 'ISSUE_INPROGRESS'], # same key in post data
            'QR_qr_security_Condition': 16,
            'QR_qr_reporter.name_Condition': 64,
            'QR_qr_reporter.name': '',
            'QR_qr_assignee.name_Condition': 64,
            'QR_qr_assignee.name': '',
            'QR_qr_findVersion.versionTag_Condition': 64,
            'QR_qr_findVersion.versionTag': '',
            'QR_qr_fixedVersion_Condition': 256,
            'QR_qr_fixedVersion': '',
            'QR_qr_created_Condition': 2,
            'QR_qr_created': ''
        }
        buglist = []
        while True:
            try:
                one_page_list_resp = self.session.post(url, headers=self.headers, data=data)
                if one_page_list_resp.status_code == 200:
                    result = re.findall('<TD.*?<a.*?href="(.*?)".*?</TD>', one_page_list_resp.text, re.S)
                    one_page_bug_list = [item for item in result if 'getBugDetail' in item]
                    if set(one_page_bug_list).issubset(buglist):
                        return
                    else:
                        # add to buglist
                        buglist.extend(one_page_bug_list)
                        data.update(nextPage=data.get('nextPage') + 1)
                        for i, item in enumerate(one_page_bug_list):
                            print(f'{i}  --> {self.pre_url}/{item[6:]}')
                            yield f'{self.pre_url}/{item[6:]}'
                else:
                    print('Get one page list failed')
            except requests.exceptions.RequestException as e:
                print(e)
 

    def get_detail_page(self, url):
        '''
        get detail page to parse bug info
        @return bug_link and bug_dst_file_path
        '''
        try:
            detail_bug_resp = self.session.post(url, headers=self.headers)
            if detail_bug_resp.status_code != 200:
                print('get detail bug page info failed')
                return None
            detail_info = re.findall('<a href="(.*?)".*?>(.*?)</a>', detail_bug_resp.text, re.S)
            bugNum_match = re.search('<title.*?>(.*?)</title>', detail_bug_resp.text, re.S)
            if not bugNum_match:
                print(f'bug no: {url} is null')
                return None
            bugNum = bugNum_match.group(1).split(']', 1)[0][1:]
            count = 0
            for link, text in detail_info:
                if 'downloadAttachment' in link and os.path.splitext(text)[-1][1:] in self.support_ext:
                    count += 1
                    yield f'{self.detail_page_pre_url}{link}', f'{bugNum}_{count}'
        except requests.exceptions.RequestException as e:
            print(e)

    def save_zipfile(self, url, save_path):
        '''
        save zip file by url
        @return True if save success
        '''
        if os.path.exists(save_path):
            print(f'{save_path} exists')
            return True
        with self.session.get(url, stream=True) as resp:
            resp.raise_for_status()
            with open(save_path, 'wb') as f:
                for chunk in resp.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)

    def unzip_file(self, zip_file, dst_dir):
        '''
        extract file to dst_dir
        '''
        zip_path, zip_filename = zip_file.rsplit(os.sep, 1)
        zip_basename, ext = zip_filename.split('.', 1)
        # print('zip_path: {}, zip_filename: {}, zip_basename: {}, ext: {}'.format(zip_path, zip_filename, zip_basename, ext))
        if os.path.exists(dst_dir):
            print('{} folder exists!'.format(dst_dir))
            return
        result = zipfile.is_zipfile(zip_file)
        if not result:
            print(f'{zip_file} is not zip file')
            return
        
        fz = zipfile.ZipFile(zip_file, 'r')
        for file in fz.namelist():
            # Extract First
            fz.extract(file, dst_dir)
            # if sub file is zip, extract
            sub_file_path = os.path.join(dst_dir, file)
            if zipfile.is_zipfile(sub_file_path):
                self.unzip_file(sub_file_path, os.path.abspath(os.path.dirname(sub_file_path)))

    def run(self):
        '''
        Execute method
        '''
        self.getCookie()
        if not self.session:
            print('session is null, return')
            return
        for item in self.get_list_page(self.bug_list_url):
            for link, folder in self.get_detail_page(item):
                zip_full_path = '{}.{}'.format(os.path.join(self.log_zip_pre_path, folder), self.support_ext[0])
                self.save_zipfile(link, zip_full_path)
                self.unzip_file(zip_full_path, os.path.join(self.log_extract_pre_path, folder))
        print('---------- finish ----------')

if __name__ == '__main__':
    pdm = PDM()
    while True:
        pdm.run()
        print('sleep...')
        time.sleep(pdm.sleep_time)
    

