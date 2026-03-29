# ==============================================================================
# APPLICATION SHINY : SIMULATEUR DE RISQUE & CARTOGRAPHIE
# ==============================================================================

library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(sf)
library(stringr)
library(tidyr)

# --- 1. PRÉ-CHARGEMENT ET PRÉPARATION DES DONNÉES ---
# (S'exécute une seule fois pour ne pas saturer la mémoire)

contrats <- readRDS("contrats_exploration_ok.rds")
sinistres <- readRDS("base_complete_clean.rds")

# Préparation de la table géographique globale
data_geo <- contrats %>%
  mutate(departement = str_sub(ctINSEE, 1, 2)) %>%
  filter(departement %in% sprintf("%02d", 1:95)) %>%
  count(departement, name = "total_contrats") %>%
  left_join(
    sinistres %>%
      mutate(departement = str_sub(ctINSEE, 1, 2)) %>%
      filter(departement %in% sprintf("%02d", 1:95)) %>%
      count(departement, name = "total_sinistres"),
    by = "departement"
  ) %>%
  mutate(
    total_sinistres = replace_na(total_sinistres, 0),
    frequence_pct = round((total_sinistres / total_contrats) * 100, 2)
  )

# Chargement de la carte de France
france_sf <- st_read("ARRONDISSEMENT.shp", quiet = TRUE)
carte_data_base <- france_sf %>% left_join(data_geo, by = c("CODE_DEPT" = "departement"))

# ==============================================================================
# INTERFACE UTILISATEUR (UI)
# ==============================================================================
ui <- dashboardPage(
  skin = "red", # Une couleur dynamique pour le risque
  dashboardHeader(title = "ENSAssuRances - Risques"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Simulateur de Profil", tabName = "simulateur", icon = icon("calculator")),
      menuItem("Cartographie", tabName = "carte", icon = icon("map-location-dot"))
    )
  ),
  
  dashboardBody(
    tabItems(
      
      # --- ONGLET 1 : SIMULATEUR DE RISQUE ---
      tabItem(tabName = "simulateur",
              h2("Évaluation du Risque Client (Souscription)"),
              fluidRow(
                box(title = "Saisie du Profil", status = "primary", solidHeader = TRUE, width = 4,
                    numericInput("age", "Âge du conducteur :", value = 30, min = 18, max = 99),
                    numericInput("permis", "Années de permis :", value = 10, min = 0, max = 80),
                    numericInput("din", "Puissance du véhicule (DIN) :", value = 110, min = 50, max = 500),
                    selectInput("dept", "Département (Zone INSEE) :", 
                                choices = sprintf("%02d", 1:95), selected = "75"),
                    actionButton("simuler", "Évaluer le Risque", icon = icon("check"), class = "btn-success")
                ),
                
                box(title = "Diagnostic Actuariel", status = "warning", solidHeader = TRUE, width = 8,
                    h3(textOutput("score_titre")),
                    p(textOutput("score_desc"), style = "font-size: 16px;"),
                    hr(),
                    fluidRow(
                      valueBoxOutput("jauge_risque", width = 6),
                      valueBoxOutput("info_zone", width = 6)
                    )
                )
              )
      ),
      
      # --- ONGLET 2 : CARTOGRAPHIE ---
      tabItem(tabName = "carte",
              h2("Cartographie Interactive des Risques"),
              fluidRow(
                box(title = "Paramètres d'affichage", status = "primary", width = 4,
                    selectInput("critere_carte", "Que voulez-vous visualiser ?",
                                choices = c("Fréquence de sinistralité (%)" = "frequence_pct",
                                            "Volume de Contrats" = "total_contrats",
                                            "Volume de Sinistres" = "total_sinistres"))
                ),
                box(title = "Carte de France", status = "success", solidHeader = TRUE, width = 8,
                    plotOutput("plot_carte", height = "600px")
                )
              )
      )
    )
  )
)

# ==============================================================================
# SERVEUR (Traitements R en arrière-plan)
# ==============================================================================
server <- function(input, output) {
  
  # --- LOGIQUE DU SIMULATEUR ---
  # On utilise eventReactive pour que le calcul ne se lance que quand on clique sur le bouton
  evaluation <- eventReactive(input$simuler, {
    
    # Récupération des données saisies
    age_client <- input$age
    permis_client <- input$permis
    din_client <- input$din
    dept_client <- input$dept
    
    # 1. Vérification du risque géographique
    freq_dept <- data_geo %>% filter(departement == dept_client) %>% pull(frequence_pct)
    if(length(freq_dept) == 0) freq_dept <- 19.3 # Moyenne nationale par défaut
    risque_geo_haut <- freq_dept > 21.0
    
    # 2. Vérification du profil (basé sur nos analyses K-Means et ACP)
    risque_jeune <- (age_client < 25)
    risque_puissance <- (din_client > 150)
    
    # 3. Calcul du Score final (Heuristique métier)
    score <- 0
    if (risque_jeune) score <- score + 2
    if (risque_puissance) score <- score + 1
    if (risque_geo_haut) score <- score + 1
    if (permis_client < 2) score <- score + 1
    
    # 4. Traduction en niveau de risque
    niveau <- "Standard"
    couleur <- "green"
    icon_val <- "shield-check"
    desc <- "Ce profil présente des caractéristiques standard. La tarification de base peut être appliquée."
    
    if (score >= 3) {
      niveau <- "Risque Élevé"
      couleur <- "red"
      icon_val <- "triangle-exclamation"
      desc <- "Attention : Cumul de facteurs aggravants (ex: jeune âge + véhicule puissant ou zone à forte fréquence). Surprime recommandée."
    } else if (score == 2) {
      niveau <- "Risque Modéré"
      couleur <- "orange"
      icon_val <- "circle-exclamation"
      desc <- "Profil à surveiller. Certains critères dépassent la moyenne du portefeuille."
    }
    
    list(niveau = niveau, couleur = couleur, icon = icon_val, desc = desc, freq = freq_dept)
  })
  
  # Affichage des résultats du simulateur
  output$score_titre <- renderText({
    paste("Résultat de l'évaluation :", evaluation()$niveau)
  })
  
  output$score_desc <- renderText({
    evaluation()$desc
  })
  
  output$jauge_risque <- renderValueBox({
    valueBox(evaluation()$niveau, "Niveau de Risque Global", 
             color = evaluation()$couleur, icon = icon(evaluation()$icon))
  })
  
  output$info_zone <- renderValueBox({
    valueBox(paste0(evaluation()$freq, " %"), "Fréquence sinistres de sa zone", 
             color = "blue", icon = icon("map"))
  })
  
  
  # --- LOGIQUE DE LA CARTE ---
  output$plot_carte <- renderPlot({
    
    # Choix de la variable et de la légende selon le menu déroulant
    var_choisie <- input$critere_carte
    titre_legende <- switch(var_choisie,
                            "frequence_pct" = "Fréquence (%)",
                            "total_contrats" = "Nb Contrats",
                            "total_sinistres" = "Nb Sinistres")
    
    # Couleurs différentes selon ce qu'on affiche
    low_col <- ifelse(var_choisie == "frequence_pct", "#f1c40f", "#ecf0f1")
    high_col <- ifelse(var_choisie == "frequence_pct", "#c0392b", "#2980b9")
    
    # Création de la carte avec ggplot2 (comme dans le Volet 3 !)
    ggplot(carte_data_base) +
      geom_sf(aes_string(fill = var_choisie), color = "black", linewidth = 0.1) +
      scale_fill_gradient(low = low_col, high = high_col, name = titre_legende, na.value = "#bdc3c7") +
      theme_void() +
      theme(legend.position = "right", legend.title = element_text(face = "bold"))
  })
}

shinyApp(ui = ui, server = server)