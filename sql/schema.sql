PRAGMA foreign_keys = ON;

-- Dimension date

CREATE TABLE IF NOT EXISTS dim_date (
    date_id INTEGER PRIMARY KEY,
    date_mois TEXT NOT NULL,
    annee INTEGER NOT NULL,
    mois INTEGER NOT NULL,
    nom_mois TEXT NOT NULL,
    trimestre INTEGER NOT NULL,
    annee_mois TEXT NOT NULL
);

-- Dimension produit

CREATE TABLE IF NOT EXISTS dim_product (
    product_id INTEGER PRIMARY KEY,
    produit TEXT NOT NULL UNIQUE,
    categorie_produit_1 TEXT NOT NULL,
    categorie_produit_2 TEXT NOT NULL
);

-- Dimension géographique

CREATE TABLE IF NOT EXISTS dim_region (
    region_id INTEGER PRIMARY KEY,
    code_pays TEXT NOT NULL UNIQUE,
    pays TEXT NOT NULL,
    region TEXT NOT NULL
);

-- Table des ventes historiques

CREATE TABLE IF NOT EXISTS fact_sales (
    sales_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date_mois TEXT NOT NULL,
    annee INTEGER NOT NULL,
    mois INTEGER NOT NULL,
    trimestre INTEGER NOT NULL,
    categorie_produit_1 TEXT NOT NULL,
    categorie_produit_2 TEXT NOT NULL,
    produit TEXT NOT NULL,
    region TEXT NOT NULL,
    pays TEXT NOT NULL,
    code_pays TEXT NOT NULL,
    devise TEXT,
    quantite_vendue REAL NOT NULL,
    montant_vente REAL NOT NULL,
    inflation REAL,
    gdp_growth REAL,
    temperature REAL,
    precipitation REAL,
    interest_rate REAL,
    wheat_price REAL,
    corn_price REAL,
    soybean_price REAL,
    product_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    date_id INTEGER NOT NULL,

    FOREIGN KEY (product_id)
        REFERENCES dim_product(product_id),

    FOREIGN KEY (region_id)
        REFERENCES dim_region(region_id),

    FOREIGN KEY (date_id)
        REFERENCES dim_date(date_id)
);

-- Table des prédictions historiques

CREATE TABLE IF NOT EXISTS fact_predictions (
    prediction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date_mois TEXT NOT NULL,
    produit TEXT NOT NULL,
    categorie_produit_1 TEXT NOT NULL,
    categorie_produit_2 TEXT NOT NULL,
    region TEXT NOT NULL,
    pays TEXT NOT NULL,
    code_pays TEXT NOT NULL,
    quantite_reelle REAL NOT NULL,
    quantite_predite REAL NOT NULL,
    erreur REAL NOT NULL,
    erreur_absolue REAL NOT NULL,
    modele TEXT NOT NULL,
    annee INTEGER NOT NULL,
    mois INTEGER NOT NULL,
    trimestre INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    date_id INTEGER NOT NULL,

    FOREIGN KEY (product_id)
        REFERENCES dim_product(product_id),

    FOREIGN KEY (region_id)
        REFERENCES dim_region(region_id),

    FOREIGN KEY (date_id)
        REFERENCES dim_date(date_id)
);

-- Table des prévisions futures

CREATE TABLE IF NOT EXISTS fact_stock_forecast (
    forecast_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date_mois TEXT NOT NULL,
    horizon_mois INTEGER NOT NULL,
    produit TEXT NOT NULL,
    categorie_produit_1 TEXT NOT NULL,
    categorie_produit_2 TEXT NOT NULL,
    region TEXT NOT NULL,
    pays TEXT NOT NULL,
    code_pays TEXT NOT NULL,
    quantite_predite REAL NOT NULL,
    borne_inferieure REAL NOT NULL,
    borne_superieure REAL NOT NULL,
    ecart_type_erreur REAL NOT NULL,
    stock_securite INTEGER NOT NULL,
    point_commande INTEGER NOT NULL,
    stock_cible_recommande INTEGER NOT NULL,
    niveau_service REAL NOT NULL,
    delai_approvisionnement_mois INTEGER NOT NULL,
    hypothese_open_data TEXT NOT NULL,
    annee INTEGER NOT NULL,
    mois INTEGER NOT NULL,
    trimestre INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    date_id INTEGER NOT NULL,

    FOREIGN KEY (product_id)
        REFERENCES dim_product(product_id),

    FOREIGN KEY (region_id)
        REFERENCES dim_region(region_id),

    FOREIGN KEY (date_id)
        REFERENCES dim_date(date_id)
);

-- Résultats des modèles

CREATE TABLE IF NOT EXISTS model_metrics (
    model TEXT PRIMARY KEY,
    MAE REAL NOT NULL,
    RMSE REAL NOT NULL,
    R2 REAL NOT NULL,
    WAPE REAL NOT NULL
);

-- Importance des variables

CREATE TABLE IF NOT EXISTS feature_importance (
    feature TEXT PRIMARY KEY,
    importance REAL NOT NULL
);

-- Résumé de l'évaluation

CREATE TABLE IF NOT EXISTS evaluation_summary (
    evaluation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    best_model TEXT NOT NULL,
    MAE REAL NOT NULL,
    RMSE REAL NOT NULL,
    R2 REAL NOT NULL,
    WAPE_percent REAL NOT NULL,
    mean_error REAL NOT NULL,
    bias_percent REAL NOT NULL,
    improvement_vs_naive_percent REAL NOT NULL,
    zero_demand_percent REAL NOT NULL,
    total_real REAL NOT NULL,
    total_predicted REAL NOT NULL,
    nb_predictions INTEGER NOT NULL
);

-- Erreurs par produit

CREATE TABLE IF NOT EXISTS error_by_product (
    error_product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    produit TEXT NOT NULL,
    absolute_error REAL NOT NULL,
    total_absolute_error REAL NOT NULL,
    residual REAL NOT NULL,
    quantite_reelle REAL NOT NULL,
    quantite_predite REAL NOT NULL,
    nb_predictions INTEGER NOT NULL,
    WAPE REAL NOT NULL
);

-- Erreurs par pays

CREATE TABLE IF NOT EXISTS error_by_country (
    error_country_id INTEGER PRIMARY KEY AUTOINCREMENT,
    code_pays TEXT NOT NULL,
    pays TEXT NOT NULL,
    absolute_error REAL NOT NULL,
    total_absolute_error REAL NOT NULL,
    residual REAL NOT NULL,
    quantite_reelle REAL NOT NULL,
    quantite_predite REAL NOT NULL,
    WAPE REAL NOT NULL
);

-- Erreurs par région

CREATE TABLE IF NOT EXISTS error_by_region (
    error_region_id INTEGER PRIMARY KEY AUTOINCREMENT,
    region TEXT NOT NULL,
    absolute_error REAL NOT NULL,
    total_absolute_error REAL NOT NULL,
    residual REAL NOT NULL,
    quantite_reelle REAL NOT NULL,
    quantite_predite REAL NOT NULL,
    WAPE REAL NOT NULL
);

-- Erreurs par mois

CREATE TABLE IF NOT EXISTS error_by_month (
    error_month_id INTEGER PRIMARY KEY AUTOINCREMENT,
    annee INTEGER NOT NULL,
    mois INTEGER NOT NULL,
    absolute_error REAL NOT NULL,
    total_absolute_error REAL NOT NULL,
    residual REAL NOT NULL,
    quantite_reelle REAL NOT NULL,
    quantite_predite REAL NOT NULL,
    WAPE REAL NOT NULL,
    date TEXT NOT NULL
);

-- Index pour accélérer les requêtes

CREATE INDEX IF NOT EXISTS idx_sales_date
ON fact_sales(date_id);

CREATE INDEX IF NOT EXISTS idx_sales_product
ON fact_sales(product_id);

CREATE INDEX IF NOT EXISTS idx_sales_region
ON fact_sales(region_id);

CREATE INDEX IF NOT EXISTS idx_predictions_date
ON fact_predictions(date_id);

CREATE INDEX IF NOT EXISTS idx_predictions_product
ON fact_predictions(product_id);

CREATE INDEX IF NOT EXISTS idx_forecast_date
ON fact_stock_forecast(date_id);

CREATE INDEX IF NOT EXISTS idx_forecast_product
ON fact_stock_forecast(product_id);

CREATE INDEX IF NOT EXISTS idx_forecast_region
ON fact_stock_forecast(region_id);

-- Suppression des anciennes vues

DROP VIEW IF EXISTS vw_sales_monthly;
DROP VIEW IF EXISTS vw_predictions_monthly;
DROP VIEW IF EXISTS vw_forecast_monthly;
DROP VIEW IF EXISTS vw_stock_by_product;
DROP VIEW IF EXISTS vw_country_performance;

-- Vue des ventes mensuelles

CREATE VIEW vw_sales_monthly AS
SELECT
    d.date_mois,
    d.annee,
    d.mois,
    d.nom_mois,
    SUM(f.quantite_vendue) AS quantite_vendue,
    SUM(f.montant_vente) AS montant_vente
FROM fact_sales AS f
JOIN dim_date AS d
    ON f.date_id = d.date_id
GROUP BY
    d.date_id,
    d.date_mois,
    d.annee,
    d.mois,
    d.nom_mois;

-- Vue des prédictions historiques

CREATE VIEW vw_predictions_monthly AS
SELECT
    d.date_mois,
    SUM(f.quantite_reelle) AS quantite_reelle,
    SUM(f.quantite_predite) AS quantite_predite,
    SUM(f.erreur_absolue) AS erreur_absolue
FROM fact_predictions AS f
JOIN dim_date AS d
    ON f.date_id = d.date_id
GROUP BY
    d.date_id,
    d.date_mois;

-- Vue des prévisions futures

CREATE VIEW vw_forecast_monthly AS
SELECT
    d.date_mois,
    SUM(f.quantite_predite) AS demande_predite,
    SUM(f.stock_securite) AS stock_securite,
    SUM(f.stock_cible_recommande) AS stock_recommande
FROM fact_stock_forecast AS f
JOIN dim_date AS d
    ON f.date_id = d.date_id
GROUP BY
    d.date_id,
    d.date_mois;

-- Vue du stock par produit

CREATE VIEW vw_stock_by_product AS
SELECT
    p.produit,
    p.categorie_produit_2,
    SUM(f.quantite_predite) AS demande_annuelle_predite,
    AVG(f.stock_cible_recommande) AS stock_cible_moyen,
    MAX(f.stock_cible_recommande) AS stock_cible_max
FROM fact_stock_forecast AS f
JOIN dim_product AS p
    ON f.product_id = p.product_id
GROUP BY
    p.product_id,
    p.produit,
    p.categorie_produit_2;

-- Vue de la performance par pays

CREATE VIEW vw_country_performance AS
SELECT
    code_pays,
    pays,
    quantite_reelle,
    quantite_predite,
    absolute_error,
    WAPE
FROM error_by_country;