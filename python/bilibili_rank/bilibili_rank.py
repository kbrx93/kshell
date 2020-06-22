import requests
from pyquery import PyQuery as pq
import os

headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'
}
url = 'https://www.bilibili.com/ranking'
# current_work_path = os.path.abspath(os.getcwd())
current_path = os.path.dirname(os.path.abspath(__file__))
html = requests.get(url, headers=headers).text
if not html:
    print('html get null, return')
else:
    doc = pq(html)
    items = doc('li.rank-item').items()
    for item in items:
        rank_num = item.find('.num').text()
        title = item.find('.info a').text()
        score = item.find('.pts div').text()
        with open(os.path.join(current_path, 'bilibili_ranking.txt'), 'a', encoding='utf-8') as f:
            f.write('\n'.join([rank_num, title, score]))
            f.write('{}{}{}'.format('\n', '=' * 50, '\n'))