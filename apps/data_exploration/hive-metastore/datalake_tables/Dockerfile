FROM python:3.8

WORKDIR /datalake_tables/

COPY sql_ddl/ ./sql_ddl/

COPY requirements.txt .

RUN pip3 install --no-cache-dir -r requirements.txt

COPY datalake_tables_generator.py .

CMD ["python3", "datalake_tables_generator.py"]