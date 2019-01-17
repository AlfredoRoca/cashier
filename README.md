# README

Create a docker image put these files inside a folder and execute the following line

    docker build . -t cashier_app
    docker-compose up --build

Start the container and enter inside

    docker run -it cashier_app /bin/bash

Start the container as detached

    docker run -d cashier_app /bin/bash

Start tests

    docker-compose run app rspec

