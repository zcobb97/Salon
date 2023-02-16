#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?" 

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID SERVICE NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  
  read SERVICE_ID_SELECTED

  INPUT_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $INPUT_SELECTED ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"

  else
    echo -e "\nWhat's your phone number?" 

    read CUSTOMER_PHONE

    CUSTOMER_PHONE_EXIST=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_PHONE_EXIST ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"

      read CUSTOMER_NAME

      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      echo -e "\nWhat time would you like your $INPUT_SELECTED, $CUSTOMER_NAME?"

      read SERVICE_TIME

      echo -e "\n I have put you down for a $INPUT_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    else
      echo -e "\nWhat time would you like your $INPUT_SELECTED, $CUSTOMER_PHONE_EXIST?"

      read SERVICE_TIME

      echo -e "\n I have put you down for a $INPUT_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    fi

  echo Thank you
  fi

  
}

MAIN_MENU
