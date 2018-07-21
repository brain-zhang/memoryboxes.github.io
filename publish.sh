#/bin/bash

# image url(put images folders of branch source):
# [!背景](https://github.com/memoryboxes/memoryboxes.github.io/blob/source/images/201612/bg1.jpg)
bundle exec rake generate
echo "happy123.me" > public/CNAME
bundle exec rake deploy
git add .
git commit  -m "$1"
git push origin source
