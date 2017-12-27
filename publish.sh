#/bin/bash
bundle exec rake generate
cp _deploy/CNAME  public/CNAME
bundle exec rake deploy
git add .
git commit -a -m "update posts"
git push origin source
