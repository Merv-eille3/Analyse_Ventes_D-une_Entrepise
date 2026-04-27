/*Utiliser la base de données sales*/
USE sales;
/*Combien d'observations contient la base de données*/
SELECT COUNT(*)
FROM ventes;
/*Combien de cagétorie de produit possède cette entreprise*/
SELECT COUNT(DISTINCT ligne_produit)
FROM ventes;
/*Afficher les différentes catégories de produits de l'entreprise*/
SELECT DISTINCT ligne_produit
FROM ventes;
/* Afficher les différents produits avec leur code respectif de l'entreprise peu importe la catégorie*/
SELECT DISTINCT numero_ligne, code_produit
FROM ventes;

/*Afficher les différents produits en fonction de leur catégorie*/
SELECT numero_ligne, code_produit, ligne_produit
FROM ventes
GROUP BY numero_ligne, code_produit, ligne_produit;

/*Afficher les différents produits dont la catégorie est Motorcycles*/

SELECT numero_ligne, code_produit, ligne_produit
FROM ventes
WHERE ligne_produit ='Motorcycles';

/* Afficher les 10 premiers produits vendus de la base de donnees dont la categorie est Motorcycle*/

SELECT num_commande, numero_ligne
FROM ventes 
WHERE ligne_produit = 'Motorcycles'
ORDER BY numero_ligne ASC
LIMIT 10;

/* Afficher les produits et leurs catégorie dont la catégorie contient la lettre S */

SELECT numero_ligne, ligne_produit
FROM ventes
WHERE ligne_produit LIKE '%S%';

/*Afficher les produits dont les catégories commencent par M*/

SELECT numero_ligne, ligne_produit
FROM ventes
WHERE ligne_produit LIKE  'T%';

/*Afficher les produits et selon leurs catégories et le prix dans le catalogue*/

SELECT DISTINCT numero_ligne, ligne_produit, prix_catalogue
FROM ventes;

/*Afficher les les numero de commande et les produits des catégories contenant S et le prix dans le catalogue i.e le prix que l'entreprise a établi*/
/*Chercher ce que le GROUP BY change*/
SELECT DISTINCT num_commande, numero_ligne, ligne_produit, prix_catalogue
FROM ventes
WHERE ligne_produit LIKE '%S%'
GROUP BY num_commande, numero_ligne, ligne_produit, prix_catalogue
ORDER BY num_commande ASC
LIMIT 10;

/*Calculer le CA que produit chaque ligne de commande de l'entreprise*/
SELECT num_commande, ligne_produit, quantite_commandee * prix_unitaire AS CA_commande
FROM ventes;

/*Calculer le CA par catégorie de produit  pourquoi ceci ne passe pas */
SELECT ligne_produit, quantite_commandee * prix_unitaire AS CA_commande
FROM ventes
GROUP BY ligne_produit;

SELECT quantite_commandee* prix_unitaire AS CA_commande
FROM ventes;

/*Afficher les numeros de commande, les produits et les catégories de produit ainsi que leur pays*/

SELECT num_commande, numero_ligne, ligne_produit, ville, etat_province
FROM ventes
GROUP BY num_commande, numero_ligne, ligne_produit, ville, etat_province;

/*Renommer une colonne */

ALTER TABLE ventes
RENAME COLUMN num_commande TO numero_commande;

/*Calculer le CA total de l'entreprise*/

SELECT SUM(quantite_commandee *prix_unitaire) AS CA_entreprise
FROM ventes;

/* Calculer le CA par categorie de produit*/

SELECT ligne_produit, SUM(quantite_commandee *prix_unitaire) AS CA_cat_produit
FROM ventes
GROUP BY ligne_produit;

/*Calculer le CA par produit, peu importe la catégorie*/

SELECT numero_ligne, SUM(quantite_commandee *prix_unitaire) AS CA_produit
FROM ventes
GROUP BY numero_ligne;

/*Calculer le CA par produit et par catégorie de produit*/

SELECT numero_ligne, ligne_produit, SUM(quantite_commandee *prix_unitaire) AS CA_produit_et_categorie
FROM ventes
GROUP BY numero_ligne, ligne_produit;

/*Calculer la moyenne des prix unitaire des produits*/

SELECT AVG(prix_unitaire) AS Moy_prix
FROM ventes;

/*  L'achat minimum de l'entreprise de la catégorie Motorcycle   DEMANDER D'EXPLICATIONS*/
SELECT MIN(quantite_commandee*prix_unitaire) AS Min_achat
FROM ventes
WHERE ligne_produit ='Motorcycles';

/* les CA au dessus de 40000 par catégorie de produit*/
SELECT ligne_produit, SUM(quantite_commandee*prix_unitaire)
FROM ventes
GROUP BY ligne_produit
HAVING SUM(quantite_commandee*prix_unitaire) > 40000;

/*le statut de la commande et le numero de la commmande ainsi que la catégorie produit*/

SELECT numero_commande, ligne_produit, statut
FROM ventes
GROUP BY numero_commande, ligne_produit, statut;

/* la moyenne du CA par annee et par mois */
SELECT annee, mois, AVG(quantite_commandee*prix_unitaire) 
FROM ventes 
GROUP BY annee, mois;

/* CASE  THEN  WHEN */

SELECT quantite_commandee*prix_unitaire,
CASE
    WHEN quantite_commandee*prix_unitaire > 5000 THEN 'Élevé'
    WHEN quantite_commandee*prix_unitaire > 1000 THEN 'Moyen'
    ELSE 'Faible'
END AS categorie
FROM ventes;


SELECT nom_client,
CASE
    WHEN SUM(quantite_commandee*prix_unitaire) > 10000 THEN 'VIP'
    ELSE 'Standard'
END AS segment
FROM ventes
GROUP BY nom_client;

/* =========================================================
   6. SOUS-REQUÊTES (SUBQUERIES)
   ========================================================= */

/* Supérieur à la moyenne */
SELECT *
FROM ventes
WHERE montant_vente > (
    SELECT AVG(montant_vente) FROM ventes
);

/* Clients au-dessus de la moyenne */
SELECT nom_client
FROM ventes
GROUP BY nom_client
HAVING SUM(montant_vente) > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(montant_vente) AS total
        FROM ventes
        GROUP BY nom_client
    ) t
);



/* =========================================================
   7. CTE (COMMON TABLE EXPRESSIONS)
   ========================================================= */

WITH ventes_client AS (
    SELECT nom_client, SUM(montant_vente) AS total
    FROM ventes
    GROUP BY nom_client
)
SELECT *
FROM ventes_client
ORDER BY total DESC;



/* =========================================================
   8. FONCTIONS FENÊTRES (WINDOW FUNCTIONS)
   ========================================================= */

/* Classement */
SELECT nom_client, montant_vente,
RANK() OVER (ORDER BY montant_vente DESC) AS rang
FROM ventes;

/* Cumul */
SELECT annee, montant_vente,
SUM(montant_vente) OVER (ORDER BY annee) AS cumul
FROM ventes;

/* Moyenne mobile */
SELECT annee, montant_vente,
AVG(montant_vente) OVER (ORDER BY annee ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
FROM ventes;



/* =========================================================
   9. ANALYSE AVANCÉE (CAS RÉELS)
   ========================================================= */

/* Meilleur client */
SELECT nom_client, SUM(montant_vente) AS total
FROM ventes
GROUP BY nom_client
ORDER BY total DESC
LIMIT 1;

/* Meilleur produit */
SELECT ligne_produit, SUM(montant_vente)
FROM ventes
GROUP BY ligne_produit
ORDER BY SUM(montant_vente) DESC
LIMIT 1;

/* Meilleure année */
SELECT annee, SUM(montant_vente)
FROM ventes
GROUP BY annee
ORDER BY SUM(montant_vente) DESC;

