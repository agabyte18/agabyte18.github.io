curl --fail --silent --show-error -H 'Content-type: application/json' \
     --data '{"text": "Pluralsight is Awesome"}' "$(cat ~/.config/mysql-alerts/webhook)"
