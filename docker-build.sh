docker-compose build
docker-compose start db
sleep 3
docker-compose run db mysqladmin -u root -h db create codeburner_production
docker-compose run web rake db:setup RAILS_ENV=production

if [ $? == 0 ]; then
  CODEBURNER_URL="http://$(docker-machine ip):3000/"
  echo "Docker containers initialized, run 'docker-compose up' to start Codeburner."
fi
