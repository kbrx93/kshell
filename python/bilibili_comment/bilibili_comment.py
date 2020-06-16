#! /usr/bin/env python3
import requests
import re
import sqlite3
import sys
import os

'''
Target: collect Bilibili hot video comments during 3 day and store it.
'''
# def get_video_comment(oid='795908620'):
#     comment_api = 'https://api.bilibili.com/x/v2/reply?pn=1&type=1&oid=' + oid + '&sort=2'
#     # first to get page count
#     resp = requests.get(comment_api).json()
#     count = resp.get('data').get('page').get('count')
#     size = resp.get('data').get('page').get('size')
#     for i in range(1, math.ceil(count / size) + 1):
#         yield requests.get('https://api.bilibili.com/x/v2/reply?pn=' + str(i) + '&type=1&oid=' + oid + '&sort=2').json()

def get_current_path():
    for path in sys.path:
        try:
            if os.path.basename(__file__) in os.listdir(path):
                return path
        except Exception as e:
            print(e)

# common data
video_url_pre = 'https://www.bilibili.com/video/{}'
comment_api_pre = 'https://api.bilibili.com/x/v2/reply?pn=1&type=1&sort=2&oid={}'
ranking_list_url = 'https://www.bilibili.com/ranking/all/0/0/3'
get_av_no_parttern = re.compile(r'https://www.bilibili.com/video/av(.*?)/', re.S)
conn = sqlite3.connect(os.path.join(get_current_path(), 'bilibili_comment.db'))
def get_one_video_data(aid, title):
    '''
    get one video comment data
    '''
    print(comment_api_pre.format(aid) + ", title: " + title)
    resp = requests.get(comment_api_pre.format(aid))
    if not resp:
        print(f'aid: {aid} video get comment failed')
        return
    comment_json = resp.json()
    # get hot comment data
    hots_comments = comment_json.get('data').get('hots')
    if not hots_comments:
        print(f'{aid} video don\'t have hot comment, continue..')
        return
    items = []
    for hot in hots_comments:
        # get sub reply?
        item = {
            'rpid': hot.get('rpid') if hot.get('rpid') else 'undefine',
            'oid': hot.get('oid') if hot.get('oid') else 'undefine',
            'title': title,
            'ctime': hot.get('ctime') if hot.get('ctime') else 'undefine',
            'like': hot.get('like') if hot.get('like') else 'undefine',
            'content': hot.get('content').get('message') if hot.get('content') else 'undefine'
        }
        items.append(item)
    return items
    # print(f'{aid} video has hot comment --- {items}')


def get_av_no(content):
    '''
    get av number from html content by re
    '''
    result = re.search(get_av_no_parttern, content)
    if result:
        return result[1]
    else:
        print('can not get aid from content')


def parse_list(url):
    r = requests.get(url)
    if not r:
        print('url is invalid')
        return
    return re.findall('{"aid":"(.*?)","bvid".*?"title":"(.*?)".*?}', r.text, re.S)

def store(data):
    if not data:
        print('data is null')
        return False
    try:
        create_table_cmd = '''
        create table if not exists comment
        (
            rpid text primary key,
            oid text,
            like int,
            title text,
            ctime text,
            content text
        );
        '''
        conn.execute(create_table_cmd)
    except:
        print('create comment table failed!')
        return False
    try:
        insert_db_cmd = '''insert or ignore into comment (rpid, oid, like, title, ctime, content) values (:rpid, :oid, :like, :title, :ctime, :content)'''
        conn.executemany(insert_db_cmd, data)
        return True
    except Exception as e:
        print('insert failed {}'.format(e))
        return False
    finally:
        conn.commit()

if __name__ == "__main__":
    resp = requests.get(video_url_pre.format('BV1QA411q79Z'))
    for oid, title in parse_list(ranking_list_url):
        store_result = store(get_one_video_data(oid, title))
        if store_result:
            print(f'insert {oid} video hot comment success !!!')
        else:
            print(f'insert {oid} video hot comment failed ... continue')