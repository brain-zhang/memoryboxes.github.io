#/bin/bash
bundle exec rake generate
bundle exec rake deploy
git add .
git commit -a -m "update posts"
git push origin source -f
