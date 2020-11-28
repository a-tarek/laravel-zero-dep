#!/bin/bash

declare -a commands=(
    # docker-composer
    build
    up
    down
    # composer
    install
    require
    dmp
    # artisan 
    art
)

[ $# -eq 0 ] && {
    echo -e "\e[41m    No arguments\e[0m" >> /dev/stderr
    exit 1
}

build() {
    docker-compose up --build -d
}

up() {
    docker-compose up -d app
    docker-compose up -d mysql
    docker-compose up -d phpmyadmin
    docker-compose up -d mongo
    docker-compose up -d mongo-express
}

down() {
    docker-compose down
}

install() {
    docker run --rm -v $(pwd):/APP_CONTAINER_NAME composer/composer install
}

require() {
    docker run --rm -v $(pwd):/APP_CONTAINER_NAME composer/composer "$@"
}

dmp() {
    docker run --rm -v $(pwd):/APP_CONTAINER_NAME composer/composer dump-autoload
}

art() {
    docker exec -t APP_CONTAINER_NAME php artisan $@
}

if [[ $1 == '--commands' ]]; then
    echo ${commands[@]}
else
    if [[ -n $(echo "${commands[@]}" | tr  ' ' '\n' | grep "$1") ]]; then
        command=$1
        shift
        $command "$@"
    else
        :
    fi
fi
