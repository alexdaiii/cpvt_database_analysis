# CPVT Database Analysis

This repository contains the code used to analyze the CPVT database and generate
figures and tables
for the manuscript "RYR2 Variants in Catecholaminergic Polymorphic Ventricular 
Tachycardia Patients: Insights From Protein Structure and Clinical Data".

The analysis code is in the `analysis` directory using Jupyter Notebooks. After
installation, you can start Jupyter Lab inside the root of the repository with:

```bash
jupyter lab
```

(or if you have PyCharm do it for you) 

## Requirements

This project uses Conda/Mamba for environment management. Valid OSs are Linux
(e.g. Ubuntu 24.04, AMD64)
To install the dependencies:

```bash
conda env create -f environment.yaml
conda activate cpvt_database_analysis
```

You will also need the `cpvt_database_models` package, which can be installed with:

```bash
pip install cpvt-database-models --index-url https://gitlab.com/api/v4/projects/60969577/packages/pypi/simple
```


## Data

The data to generate the figures are located inside this repo as `.xlsx` files.
Starting from notebook `05+` the data does not require access to the database.
However, to run notebooks `01` to `04`, you will need access to a PostgreSQL
database to create the `*.xlsx` files. 

The data used in this analysis is available
in [Zenodo](https://zenodo.org/doi/10.5281/zenodo.8277761). It requires
a PostgreSQL database to be loaded. Download the `*.gz.sql` and `*.sql` files
and place them in the `init` directory
relative to the root of this repository.

The project should look like this (cpvt_database_analysis is the root directory)
if you are downloading the data:

```
cpvt_database_analysis/
├── analysis/
├── init/
... other files ...
```

A quick way to load the data is to use the `docker-compose.yaml` file in the
main directory. It assumes that you have Docker and Docker Compose installed.
Instructions for installing Docker and
Docker Compose can be found
on [Docker's website](https://docs.docker.com/engine/install/).

This configuration will mount
the `init` directory to `/docker-entrypoint-initdb.d` in the PostgreSQL
container, which will load the data
when the container is started and create a new 
volume for the database data.
The database will be available at `localhost:5432`.

Also,`pgadmin` is started to allow you to interact with the database, which will
be available
at [http://localhost:5050](http://localhost:5050).

To start the database (with the terminal detached), run the following command in
the root of the repository:

```bash
docker compose up -d
```

To stop the database, run the following command in the root of the repository:

```bash
docker compose down
```

To remove the database volume (this will delete all data), run the following
command in the root of the repository:

```bash
docker compose down -v
```