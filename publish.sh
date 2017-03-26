#/bin/bash
bundle exec rake generate
bundle exec rake deploy
git add .
git commit -a -m "migrate duoshuo to disqus"
git push origin source -f
