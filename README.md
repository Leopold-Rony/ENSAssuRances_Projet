# 🚗 Projet ENSAssuRances : Ingénierie des Données et Analyse des Risques

📊 **Consulter le rapport final interactif :** [Cliquez ici pour voir le rapport sur RPubs]((https://rpubs.com/leopold_Rony))

## 📖 Contexte du projet
Ce projet a été réalisé dans le cadre du cours *"Ingénierie des données avec Python et RStudio"* (Prof. Solym Manou-Abi - ENSAR / Université de Poitiers). 
L'objectif est d'agir en tant que Data Analyst / Actuaire pour la compagnie **ENSAssuRances** afin d'analyser un portefeuille de contrats automobiles et d'identifier les facteurs de risque de sinistralité.

## 🎯 Objectifs
Le projet est divisé en plusieurs volets stratégiques :
1. **Ingénierie des données (Data Prep) :** Nettoyage, gestion des valeurs manquantes et des doublons, restructuration (pivot) et jointures complexes entre les bases de contrats et de sinistres.
2. **Analyse Exploratoire et Visualisation :** - Évolution temporelle de la sinistralité (effet Covid-19).
   - Profilage du parc automobile (Segments, Énergie, Option Petit Rouleur).
   - Analyse du risque humain (Âge, Sexe, Antécédents).
3. **Analyse Statistique du Risque :** Passage d'une analyse en volume à une analyse en **fréquence** pour identifier le risque réel par type de véhicule.
4. **Cartographie Spatiale (SIG) :** Création d'une carte de France choroplèthe mettant en évidence les départements à plus forte sinistralité.
5. **Machine Learning & Outils Interactifs (En cours) :** Apprentissage non supervisé (ACP, ACM, Clustering) et déploiement d'applications interactives (R Shiny / Streamlit).

## 🛠️ Technologies et Packages utilisés
* **Langage :** R (et Python pour la suite)
* **Environnement :** RStudio
* **Manipulation de données :** `dplyr`, `tidyr`, `stringr`, `lubridate`
* **Visualisation :** `ggplot2`
* **Cartographie spatiale :** `sf` (traitement de Shapefiles IGN / GEOFLA)
* **Reporting :** R Markdown

## 📂 Structure du dépôt
* `01_Analyse_Exploratoire.Rmd` : Audit initial des données brutes.
* `02_Data_Cleaning.Rmd` : Scripts de nettoyage et création de la clé de jointure unifiée.
* `03_Visualisations.Rmd` : Génération des graphiques analytiques et de la cartographie spatiale.
* `04_Machine_Learning.Rmd` : *(À venir)* ACP, ACM et algorithmes de clustering.
* Les jeux de données bruts et intermédiaires (au format `.rds`) ont été exclus du suivi Git pour des raisons de performance et de confidentialité.

---
*Projet réalisé en 2026.*
