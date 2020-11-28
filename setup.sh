#!/bin/bash

declare -A REQUIRED_KEYS=(
    [APP_ALIAS]=$(cat .env | grep "^APP_ALIAS=.*" | cut -d= -f2)
    [APP_CONTAINER_NAME]=$(cat .env | grep "^APP_CONTAINER_NAME=.*" | cut -d= -f2)
)

for key in ${!REQUIRED_KEYS[@]}; do
    value=${REQUIRED_KEYS[$key]}
    if [[ -z $value ]]; then
        echo "Missing $key" >> /dev/stderr
        exit 1
    fi
done

declare -r DESTINATION_FILE=/usr/local/bin/${REQUIRED_KEYS[APP_ALIAS]}

case $1 in
    --purge|--remove)
        if [[ -e $DESTINATION_FILE ]]; then
            rm $DESTINATION_FILE
            echo "File $DESTINATION_FILE has been removed"
        fi
        exit
    ;;

    --reload)
        $0 --purge >> /dev/null
        $0 >> /dev/null
        echo "File $DESTINATION_FILE has been reloaded"
        exit
    ;;
esac

if [[ -e $DESTINATION_FILE ]]; then
    echo "File $DESTINATION_FILE already exists, Do you want to overwrite it? [Yes/No]"
    read answer
    case $answer in
        y|Y|yes|Yes|YES)
            rm $DESTINATION_FILE
            echo "File $DESTINATION_FILE has been removed"
        ;;
        *)
            echo "File $DESTINATION_FILE already exists, remove the file first then run this script again" >> /dev/stderr
            exit 2;
        ;;
    esac
fi

STUB=$(cat stub.sh | sed "s/APP_CONTAINER_NAME/${REQUIRED_KEYS[APP_CONTAINER_NAME]}/g")
echo "$STUB" >> $DESTINATION_FILE
chmod a+x $DESTINATION_FILE
echo "File $DESTINATION_FILE has been created"

completion="complete -W \"$(./stub.sh --commands)\" ${REQUIRED_KEYS[APP_ALIAS]}"
completion_file=~/.${REQUIRED_KEYS[APP_ALIAS]}.sh
echo $completion > $completion_file

grep -q "^. $completion_file$" ~/.zshrc || echo -e ". $completion_file\n"  >> ~/.zshrc
