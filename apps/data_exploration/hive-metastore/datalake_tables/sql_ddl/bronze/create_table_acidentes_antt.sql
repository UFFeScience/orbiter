CREATE TABLE delta_lake.bronze.acidentes_antt(
	id integer,
	n_da_ocorrencia varchar,
    tipo_de_ocorrencia varchar,
    km varchar,
    trecho varchar,
    sentido varchar,
    tipo_de_acidente varchar,
    automovel integer,
    bicicleta integer,
    caminhao integer,
    moto integer,
    onibus integer,
    outros integer,
    tracao_animal integer,
    transporte_de_cargas_especiais integer,
    trator_maquinas integer,
    utilitarios integer,
    ilesos integer,
    levemente_feridos integer,
    moderadamente_feridos integer,
    gravemente_feridos integer,
    mortos integer,
    rodovia varchar,
    data_hora TIMESTAMP(3) WITH TIME ZONE
)
WITH (
  location = 's3a://datalake/bronze/acidentes_antt/'
)