docker-compose build
docker-compose run web bash -c "while ! mysqladmin ping -h db --silent; do echo waiting for mysql; sleep 3; done; rake db:create; rake db:schema:load"
docker-compose run web rake db:setup

if [ $? == 0 ]; then
  echo -e "\nDocker containers initialized, run 'docker-compose up' to start Codeburner."
fi
