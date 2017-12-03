---
layout: post
title: "how to config samba config with no password share"
date: 2017-12-03 09:49:15 +0800
comments: true
categories: samba
---

年老记忆力下降，做了N+1遍了，还是忘。

## 卸载干净

    apt-get purge samba
    rm -rf /etc/samba /etc/default/samba

## 重装

    apt-get install samba

## 配置

    vim /etc/samba/smb.conf


    [share_name]
    browseable = yes
    path = the_complete_path_to_the_shared_folder
    guest ok = yes
    read only = no
    create mask = 777

## 重启

    systemctl restart smbd
