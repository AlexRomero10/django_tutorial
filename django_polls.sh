#!/bin/sh

set -e  # Detener en cualquier error

echo "Esperando a la base de datos..."
# Espera activa a que esté el puerto 3306 (MySQL)
until nc -z -v -w30 "$HOST" 3306
do
  echo "Esperando a la base de datos en $HOST:3306..."
  sleep 5
done

echo "Base de datos disponible. Ejecutando migraciones..."

python3 manage.py makemigrations
python3 manage.py migrate

# Crear superusuario solo si no existe
echo "from django.contrib.auth import get_user_model; \
      User = get_user_model(); \
      User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists() or \
      User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', '$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD')" \
      | python3 manage.py shell

python3 manage.py collectstatic --no-input

echo "Iniciando servidor Django..."
exec python3 manage.py runserver 0.0.0.0:8006
