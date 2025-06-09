#!/bin/bash
cd /usr/src/app/
export DJANGO_SUPERUSER_PASSWORD=$DJANGO_PASS
sleep 20
python3 manage.py migrate
python manage.py createsuperuser --username=$DJANGO_USER --email=$DJANGO_MAIL --noinput
python3 manage.py runserver 0.0.0.0:3000
