#/bin/bash
bundle exec rake generate
bundle exec rake deploy
git add .
git commit -a -m "add gcc upgrade plan on centos7"
git push origin source -f
