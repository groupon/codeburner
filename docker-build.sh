docker-compose build
docker-compose run web bash -c "while ! mysqladmin ping -h db --silent; do echo waiting for mysql; sleep 3; done; mysqladmin -u root -h db create codeburner_production"
docker-compose run web rake db:setup

if [ $? == 0 ]; then
  echo "Docker containers initialized, run 'docker-compose up' to start Codeburner."
fi
