FROM python:3.11-slim

WORKDIR /app

RUN useradd -m appuser

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app

RUN chown -R appuser:appuser /app 

USER appuser

EXPOSE 5000

CMD ["python", "app/app.py"]
