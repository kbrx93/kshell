import requests
from urllib.parse import urlencode
import sys
import os
from multiprocessing.pool import Pool

def get_unsplash_json(pageNum, pageSize=10):
    data = {
        'page': pageNum,
        'per_page': pageSize
    }
    url = f'https://unsplash.com/napi/photos?{urlencode(data)}'
    try:
        resp = requests.get(url)
        if resp.status_code == 200:
            return resp.json()
        else:
            print('url: {} status code is not 200'.format(url))
    except requests.ConnectionError|requests.ConnectTimeout:
        print('Connect url: {} error!'.format(url))

def parse_image_url(content):
    if not content:
        return None
    for item in content:
        yield item.get('urls')


def get_current_path():
    for path in sys.path:
        try:
            if os.path.basename(__file__) in os.listdir(path):
                return path
        except Exception as e:
            print(e)


def store_image(images, dirname='images'):
    dir_path = f'{get_current_path()}/{dirname}'
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)
    for image_size, image_url in images.items():
        try:
            resp = requests.get(image_url)
            if resp.status_code == 200:
                file_path = '{}/{}-{}.{}'.format(dir_path, image_url.rsplit('/')[-1].split('?')[0], image_size, 'jpg')
                if not os.path.exists(file_path):
                    with open(file_path, 'wb') as f:
                        f.write(resp.content)
                    print('Image: {} store success'.format(file_path))
                else:
                    print('Image: {} has store already'.format(file_path))
        except requests.ConnectionError|requests.ConnectTimeout:
            print('store pic: {}-{} fail'.format(image_size, image_url))

def main(pageNum=1):
    content = get_unsplash_json(pageNum)
    for images in parse_image_url(content):
        store_image(images)

if __name__ == "__main__":
    pool = Pool()
    GROUP_START = 1
    GROUP_END = 10
    groups = ([x for x in range(GROUP_START, GROUP_END + 1)])
    pool.map(main, groups)
    pool.close()
    pool.join()
