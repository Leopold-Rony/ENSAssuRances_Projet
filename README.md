# 🚗 Projet ENSAssuRances : Ingénierie des Données et Analyse des Risques

📊 **Consulter les rapports interactifs :** [Cliquez ici pour voir mon profil RPubs](https://rpubs.com/leopold_Rony)

## 📖 Contexte du projet
Ce projet a été réalisé dans le cadre du cours *"Ingénierie des données avec Python et RStudio"* (Prof. Solym Manou-Abi - ENSAR / Université de Poitiers). 
L'objectif est d'agir en tant que Data Analyst / Actuaire pour la compagnie **ENSAssuRances** afin d'analyser un portefeuille de 300 000 contrats automobiles, d'identifier les facteurs de risque de sinistralité et de proposer une segmentation tarifaire.

## 🎯 Objectifs et Réalisations
Le projet est divisé en 6 volets stratégiques :
1. **Ingénierie des données (Data Prep) :** Nettoyage, gestion des valeurs manquantes et des doublons, restructuration et jointures complexes entre les bases de contrats et de sinistres (Big Data).
2. **Analyse Exploratoire et Visualisation :** - Évolution temporelle de la sinistralité (mise en évidence de l'effet Covid-19).
   - Profilage du parc automobile (Segments, Énergies, Options).
3. **Analyse Statistique du Risque :** Passage d'une logique de volume à une logique de **fréquence** pour identifier le risque réel par type de véhicule et profil humain.
4. **Cartographie Spatiale (SIG) :** Création d'une carte de France choroplèthe mettant en évidence les départements à plus forte sinistralité (justification d'un zonier tarifaire).
5. **Machine Learning (Apprentissage Non Supervisé) :** - **ACP (Analyse en Composantes Principales) :** Étude des corrélations entre les variables quantitatives (Âge, Valeur du véhicule, Puissance).
   - **ACM (Analyse des Correspondances Multiples) :** Identification des profils qualitatifs à risque.
   - **Clustering (K-Means) :** Segmentation algorithmique des 300 000 assurés en 3 profils tarifaires distincts ("Jeunes Actifs", "Seniors", "Quadras Premium").
6. **Outils Interactifs (Dashboards) :** Création d'applications **R Shiny** pour le pilotage du portefeuille et la simulation d'évaluation des risques à la souscription.

## 🛠️ Technologies et Packages utilisés
* **Langage :** R
* **Environnement :** RStudio
* **Manipulation de données :** `dplyr`, `tidyr`, `stringr`, `lubridate`
* **Visualisation & Cartographie :** `ggplot2`, `sf`, `plotly`
* **Machine Learning :** `FactoMineR`, `factoextra`, `cluster`
* **Applications Web :** `shiny`, `shinydashboard`
* **Reporting :** R Markdown

## 📂 Structure du dépôt
* `01_Analyse_Exploratoire.Rmd` : Audit initial des données brutes.
* `02_Data_Cleaning.Rmd` : Scripts de nettoyage et création de la clé de jointure unifiée.
* `03_Visualisations.Rmd` : Génération des graphiques analytiques et de la cartographie spatiale.
* `04_ACP.Rmd` : Analyse en Composantes Principales (Variables quantitatives).
* `05_ACM.Rmd` : Analyse des Correspondances Multiples (Variables qualitatives).
* `06_Clustering.Rmd` : Segmentation tarifaire (Algorithme K-Means).
* `/Dashboard_ENSAssuRances` : Application web de pilotage des KPI.
* `/App_Tarification` : Simulateur de risque et cartographie interactive.

*(Note : Les jeux de données bruts, les shapefiles et les bases intermédiaires au format `.rds` ont été exclus du suivi Git pour des raisons d'optimisation et de confidentialité).*

---
*Projet réalisé en 2026 par Léopold Rony jason Mopita.*