-- 1. Ventes totales par mois

SELECT
    date_mois,
    annee,
    mois,
    nom_mois,
    ROUND(quantite_vendue, 2) AS quantite_vendue,
    ROUND(montant_vente, 2) AS montant_vente
FROM vw_sales_monthly
ORDER BY date_mois;


-- 2. Top 10 des produits par quantité vendue

SELECT
    p.produit,
    p.categorie_produit_2,
    ROUND(SUM(f.quantite_vendue), 2) AS quantite_totale,
    ROUND(SUM(f.montant_vente), 2) AS montant_total
FROM fact_sales AS f
JOIN dim_product AS p
    ON f.product_id = p.product_id
GROUP BY
    p.product_id,
    p.produit,
    p.categorie_produit_2
ORDER BY quantite_totale DESC
LIMIT 10;


-- 3. Ventes par pays

SELECT
    r.code_pays,
    r.pays,
    ROUND(SUM(f.quantite_vendue), 2) AS quantite_totale,
    ROUND(SUM(f.montant_vente), 2) AS montant_total
FROM fact_sales AS f
JOIN dim_region AS r
    ON f.region_id = r.region_id
GROUP BY
    r.region_id,
    r.code_pays,
    r.pays
ORDER BY quantite_totale DESC;


-- 4. Comparaison mensuelle entre le réel et le prédit

SELECT
    date_mois,
    ROUND(quantite_reelle, 2) AS quantite_reelle,
    ROUND(quantite_predite, 2) AS quantite_predite,
    ROUND(erreur_absolue, 2) AS erreur_absolue
FROM vw_predictions_monthly
ORDER BY date_mois;


-- 5. Comparaison des modèles

SELECT
    model,
    ROUND(MAE, 3) AS MAE,
    ROUND(RMSE, 3) AS RMSE,
    ROUND(R2, 3) AS R2,
    ROUND(WAPE, 2) AS WAPE
FROM model_metrics
ORDER BY RMSE;


-- 6. Performance du modèle par pays

SELECT
    code_pays,
    pays,
    ROUND(quantite_reelle, 2) AS quantite_reelle,
    ROUND(quantite_predite, 2) AS quantite_predite,
    ROUND(absolute_error, 2) AS erreur_moyenne,
    ROUND(WAPE, 2) AS WAPE
FROM vw_country_performance
ORDER BY WAPE;


-- 7. Prévisions futures mensuelles

SELECT
    date_mois,
    ROUND(demande_predite, 2) AS demande_predite,
    stock_securite,
    stock_recommande
FROM vw_forecast_monthly
ORDER BY date_mois;


-- 8. Stock recommandé par produit

SELECT
    produit,
    categorie_produit_2,
    ROUND(demande_annuelle_predite, 2)
        AS demande_annuelle_predite,
    ROUND(stock_cible_moyen, 2)
        AS stock_cible_moyen,
    stock_cible_max
FROM vw_stock_by_product
ORDER BY stock_cible_max DESC;


-- 9. Produits avec le stock de sécurité le plus élevé

SELECT
    p.produit,
    r.code_pays,
    MAX(f.stock_securite) AS stock_securite_max,
    MAX(f.stock_cible_recommande) AS stock_cible_max
FROM fact_stock_forecast AS f
JOIN dim_product AS p
    ON f.product_id = p.product_id
JOIN dim_region AS r
    ON f.region_id = r.region_id
GROUP BY
    p.product_id,
    p.produit,
    r.code_pays
ORDER BY stock_securite_max DESC
LIMIT 10;


-- 10. Prévisions mensuelles par pays

SELECT
    d.date_mois,
    r.code_pays,
    r.pays,
    ROUND(SUM(f.quantite_predite), 2)
        AS demande_predite,
    SUM(f.stock_securite)
        AS stock_securite,
    SUM(f.stock_cible_recommande)
        AS stock_recommande
FROM fact_stock_forecast AS f
JOIN dim_date AS d
    ON f.date_id = d.date_id
JOIN dim_region AS r
    ON f.region_id = r.region_id
GROUP BY
    d.date_id,
    d.date_mois,
    r.region_id,
    r.code_pays,
    r.pays
ORDER BY
    d.date_mois,
    r.code_pays;


-- 11. Vérification des relations sans produit

SELECT COUNT(*) AS ventes_sans_produit
FROM fact_sales AS f
LEFT JOIN dim_product AS p
    ON f.product_id = p.product_id
WHERE p.product_id IS NULL;


-- 12. Vérification des relations sans date

SELECT COUNT(*) AS previsions_sans_date
FROM fact_stock_forecast AS f
LEFT JOIN dim_date AS d
    ON f.date_id = d.date_id
WHERE d.date_id IS NULL;