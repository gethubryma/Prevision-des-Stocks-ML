from pathlib import Path
from datetime import datetime
import logging
import shutil
import subprocess
import sys


# Chemins du projet

PROJECT_PATH = Path(__file__).resolve().parents[1]

NOTEBOOKS_PATH = PROJECT_PATH / "notebooks"

DATA_PATH = PROJECT_PATH / "data"
RAW_PATH = DATA_PATH / "raw"
INTERNAL_PATH = RAW_PATH / "internal"
OPEN_DATA_PATH = RAW_PATH / "open_data"
HISTORY_PATH = RAW_PATH / "history"

REPORTS_PATH = PROJECT_PATH / "reports"
LOGS_PATH = REPORTS_PATH / "logs"

DATABASE_SCRIPT = PROJECT_PATH / "src" / "database.py"


# False : utiliser les fichiers existants
# True : refaire la collecte depuis Internet

FORCER_COLLECTE = False


# Création des dossiers nécessaires

HISTORY_PATH.mkdir(parents=True, exist_ok=True)
LOGS_PATH.mkdir(parents=True, exist_ok=True)

LOG_FILE = LOGS_PATH / "pipeline.log"


# Configuration des messages du pipeline

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(
            LOG_FILE,
            encoding="utf-8"
        ),
        logging.StreamHandler()
    ]
)


# Liste des fichiers nécessaires pour continuer le pipeline

FICHIERS_RAW = [
    INTERNAL_PATH / "ventes_brutes.csv",
    OPEN_DATA_PATH / "corn_price.csv",
    OPEN_DATA_PATH / "gdp.csv",
    OPEN_DATA_PATH / "inflation.csv",
    OPEN_DATA_PATH / "interest_rate.csv",
    OPEN_DATA_PATH / "soybean_price.csv",
    OPEN_DATA_PATH / "weather.csv",
    OPEN_DATA_PATH / "wheat_price.csv"
]


def donnees_raw_existantes():

    return all(
        fichier.exists() and fichier.stat().st_size > 0
        for fichier in FICHIERS_RAW
    )


def executer_notebook(nom_notebook):

    notebook_path = NOTEBOOKS_PATH / nom_notebook

    if not notebook_path.exists():
        raise FileNotFoundError(
            f"Notebook absent : {notebook_path}"
        )

    logging.info(
        f"Début du notebook : {nom_notebook}"
    )

    commande = [
        sys.executable,
        "-m",
        "jupyter",
        "nbconvert",
        "--to",
        "notebook",
        "--execute",
        "--inplace",
        "--ExecutePreprocessor.timeout=1200",
        nom_notebook
    ]

    subprocess.run(
        commande,
        cwd=NOTEBOOKS_PATH,
        check=True
    )

    logging.info(
        f"Fin du notebook : {nom_notebook}"
    )


def collecter_donnees():

    if FORCER_COLLECTE or not donnees_raw_existantes():

        logging.info(
            "Les fichiers Raw sont absents ou la collecte est forcée"
        )

        executer_notebook(
            "collecte_donnees.ipynb"
        )

        if not donnees_raw_existantes():
            raise FileNotFoundError(
                "La collecte est terminée, mais certains fichiers Raw sont absents."
            )

    else:

        logging.info(
            "Les fichiers Raw existent déjà : collecte Internet ignorée"
        )


def historiser_donnees():

    date_execution = datetime.now().strftime(
        "%Y%m%d_%H%M%S"
    )

    dossier_historique = (
        HISTORY_PATH / date_execution
    )

    dossier_internal = (
        dossier_historique / "internal"
    )

    dossier_open_data = (
        dossier_historique / "open_data"
    )

    dossier_internal.mkdir(
        parents=True,
        exist_ok=True
    )

    dossier_open_data.mkdir(
        parents=True,
        exist_ok=True
    )

    for fichier in INTERNAL_PATH.glob("*.csv"):

        shutil.copy2(
            fichier,
            dossier_internal / fichier.name
        )

    for fichier in OPEN_DATA_PATH.glob("*.csv"):

        shutil.copy2(
            fichier,
            dossier_open_data / fichier.name
        )

    logging.info(
        f"Historisation créée : {dossier_historique}"
    )


def creer_base_donnees():

    if not DATABASE_SCRIPT.exists():
        raise FileNotFoundError(
            f"Script absent : {DATABASE_SCRIPT}"
        )

    logging.info(
        "Début de la création de la base de données"
    )

    subprocess.run(
        [
            sys.executable,
            str(DATABASE_SCRIPT)
        ],
        cwd=PROJECT_PATH,
        check=True
    )

    logging.info(
        "Base de données créée"
    )


def verifier_resultats():

    fichiers_resultats = [
        DATA_PATH / "processed" / "dataset_final.csv",
        DATA_PATH / "processed" / "dataset_model_ml.csv",
        REPORTS_PATH / "ml" / "predictions_test.csv",
        REPORTS_PATH / "ml" / "previsions_stock_futur.csv",
        DATA_PATH / "powerbi" / "fact_sales.csv",
        DATA_PATH / "powerbi" / "fact_predictions.csv",
        DATA_PATH / "powerbi" / "fact_stock_forecast.csv",
        DATA_PATH / "database" / "stock_prediction.db"
    ]

    fichiers_absents = [
        fichier
        for fichier in fichiers_resultats
        if not fichier.exists()
    ]

    if fichiers_absents:

        logging.warning(
            "Certains fichiers de résultat sont absents :"
        )

        for fichier in fichiers_absents:
            logging.warning(
                str(fichier)
            )

    else:

        logging.info(
            "Tous les fichiers de résultat ont été créés"
        )


def executer_pipeline():

    logging.info(
        "Début du pipeline complet"
    )

    # 1. Collecte ou utilisation des fichiers existants

    collecter_donnees()

    # 2. Historisation des données Raw

    historiser_donnees()

    # 3. Préparation des données

    executer_notebook(
        "preparation_donnees.ipynb"
    )

    # 4. Analyse exploratoire

    executer_notebook(
        "analyse_exploratoire.ipynb"
    )

    # 5. Entraînement des modèles

    executer_notebook(
        "machine_learning.ipynb"
    )

    # 6. Évaluation des modèles

    executer_notebook(
        "evaluation_modeles.ipynb"
    )

    # 7. Prévisions futures

    executer_notebook(
        "prediction_future.ipynb"
    )

    # 8. Préparation des fichiers Power BI et Tableau

    executer_notebook(
        "preparation_powerbi.ipynb"
    )

    # 9. Création de la base SQLite

    creer_base_donnees()

    # 10. Exécution des requêtes SQL

    notebook_requetage = (
        NOTEBOOKS_PATH / "requetage_donnees.ipynb"
    )

    if notebook_requetage.exists():

        executer_notebook(
            "requetage_donnees.ipynb"
        )

    else:

        logging.warning(
            "Le notebook requetage_donnees.ipynb est absent"
        )

    # 11. Vérification finale

    verifier_resultats()

    logging.info(
        "Pipeline terminé avec succès"
    )


if __name__ == "__main__":

    try:

        executer_pipeline()

    except Exception:

        logging.exception(
            "Le pipeline a rencontré une erreur"
        )

        raise