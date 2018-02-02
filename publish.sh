#/bin/bash
bundle exec rake generate
cp _deploy/CNAME  public/CNAME
bundle exec rake deploy
git add .
git commit  -m $1
git push origin source
