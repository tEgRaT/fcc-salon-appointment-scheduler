#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?"
  fi
  
  # get available services
  AVAILABLE_SERVICES="$($PSQL "SELECT * FROM services ORDER BY service_id")"

  # display available services
  echo
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # read service_id selected
  read SERVICE_ID_SELECTED

  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
}

MAIN_MENU

if [[ -z $SERVICE_NAME_SELECTED ]]
then
  MAIN_MENU "I could not find that service. What would you like today?"
fi

# get phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

# if phone number not exists
if [[ -z $CUSTOMER_NAME ]]
then
  # ask and read name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  # insert into customers
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# get customer name with phone number
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# ask appointment time
echo -e "\nWhat time would you like your $(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
read SERVICE_TIME

# insert into appointments
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# tell customer about the appointment just made
echo -e "\nI have put you down for a$SERVICE_NAME_SELECTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
