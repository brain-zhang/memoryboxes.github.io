#/bin/bash
bundle exec rake generate
echo "happy123.me" > public/CNAME
bundle exec rake deploy
git add .
git commit  -m "$1"
git push origin source
