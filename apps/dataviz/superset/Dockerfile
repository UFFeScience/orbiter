FROM apache/superset

USER root

# ENV PATH="/app/superset_home/.local/bin:$PATH"

RUN pip install --upgrade pip && \
    pip install sqlalchemy-trino==0.5.0

USER superset