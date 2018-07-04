---
layout: post
title: "crawler ABC"
date: 2018-07-04 19:04:58 +0800
comments: true
categories: develop
---

一个小爬虫的主要的套路就是requests, beautifulsoup, phantomjs.

## requests

```
def get_html(url):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:61.0) Gecko/20100101 Firefox/61.0',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
        'Accept-Encoding': 'gzip, deflate, br',
        'Content-Type': 'application/x-www-form-urlencoded',
    }
    resp = requests.get(url, headers=headers)
    if resp.status_code == 200:
        return resp.content
    else:
        raise ValueError("Not valid response:{}".format(resp.content))

```

## beautifulsoup

```
from bs4 import BeautifulSoup
def get_username(html):
    soup = BeautifulSoup(html, 'lxml')
    user_div = soup.find(id='uhd')
    username = user_div.find('h2', class_='mt').get_text().strip()
    return username
```
