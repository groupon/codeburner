docker-compose build
docker-compose run web rake db:setup RAILS_ENV=production

if [ $? == 0 ]; then
  echo "Docker containers initialized, run 'docker-compose up' to start Codeburner."
fi
