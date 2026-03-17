# Intentionally uses python:latest for policy violation demo
FROM python:latest

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

EXPOSE 8080

CMD ["python", "app.py"]
