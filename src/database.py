import pandas as pd
import sqlite3

from pathlib import Path


# Chemin principal du projet

BASE_PATH = (
    Path(__file__)
    .resolve()
    .parent
    .parent
)

POWERBI_PATH = (
    BASE_PATH
    / "data"
    / "powerbi"
)

DATABASE_PATH = (
    BASE_PATH
    / "data"
    / "database"
)

SQL_PATH = (
    BASE_PATH
    / "sql"
)

DATABASE_FILE = (
    DATABASE_PATH
    / "stock_prediction.db"
)

SCHEMA_FILE = (
    SQL_PATH
    / "schema.sql"
)

# Création du dossier de la base

DATABASE_PATH.mkdir(
    parents=True,
    exist_ok=True
)

# Correspondance entre les tables et les CSV

tables_csv = {
    "dim_date": "dim_date.csv",
    "dim_product": "dim_product.csv",
    "dim_region": "dim_region.csv",
    "fact_sales": "fact_sales.csv",
    "fact_predictions": "fact_predictions.csv",
    "fact_stock_forecast": "fact_stock_forecast.csv",
    "model_metrics": "model_metrics.csv",
    "feature_importance": "feature_importance.csv",
    "evaluation_summary": "evaluation_summary.csv",
    "error_by_product": "error_by_product.csv",
    "error_by_country": "error_by_country.csv",
    "error_by_region": "error_by_region.csv",
    "error_by_month": "error_by_month.csv"
}

# Ordre utilisé pour vider les tables

tables_suppression = [
    "fact_sales",
    "fact_predictions",
    "fact_stock_forecast",
    "model_metrics",
    "feature_importance",
    "evaluation_summary",
    "error_by_product",
    "error_by_country",
    "error_by_region",
    "error_by_month",
    "dim_date",
    "dim_product",
    "dim_region"
]


def creer_base_donnees():

    # Connexion SQLite

    connexion = sqlite3.connect(
        DATABASE_FILE
    )

    connexion.execute(
        "PRAGMA foreign_keys = ON"
    )

    # Lecture et exécution du schéma

    schema_sql = SCHEMA_FILE.read_text(
        encoding="utf-8"
    )

    connexion.executescript(
        schema_sql
    )

    # Suppression des anciennes données

    for table in tables_suppression:

        connexion.execute(
            f"DELETE FROM {table}"
        )

    connexion.commit()

    # Chargement des fichiers CSV

    for table, fichier_csv in tables_csv.items():

        chemin_csv = (
            POWERBI_PATH
            / fichier_csv
        )

        dataframe = pd.read_csv(
            chemin_csv
        )

        dataframe.to_sql(
            table,
            connexion,
            if_exists="append",
            index=False,
            chunksize=1000
        )

        print(
            table,
            ":",
            len(dataframe),
            "lignes"
        )

    connexion.commit()

    # Vérification des relations

    erreurs_relations = connexion.execute(
        "PRAGMA foreign_key_check"
    ).fetchall()

    print(
        "\nErreurs de relations :",
        len(erreurs_relations)
    )

    # Vérification des tables

    verification = []

    for table in tables_csv:

        resultat = connexion.execute(
            f"SELECT COUNT(*) FROM {table}"
        ).fetchone()

        verification.append({
            "table": table,
            "nombre_lignes": resultat[0]
        })

    verification_df = pd.DataFrame(
        verification
    )

    print("\nTables créées :")
    print(verification_df)

    connexion.close()

    print(
        "\nBase créée :",
        DATABASE_FILE
    )


if __name__ == "__main__":

    creer_base_donnees()