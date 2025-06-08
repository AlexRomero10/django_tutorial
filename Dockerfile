FROM python:3
WORKDIR /usr/src/app
RUN pip install django mysqlclient 
ADD django_tutorial/ /usr/src/app
ADD django_polls.sh /opt
RUN mkdir static && chmod +x /opt/django_polls.sh
ENV ALLOWED_HOSTS=*
ENV HOST=mariadb
ENV USUARIO=django
ENV CONTRA=django
ENV BASE_DATOS=django
ENV DJANGO_SUPERUSER_PASSWORD=admin
ENV DJANGO_SUPERUSER_USERNAME=admin
ENV DJANGO_SUPERUSER_EMAIL=admin@example.org
CMD ["/opt/django_polls.sh"]
