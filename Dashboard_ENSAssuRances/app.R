# ==============================================================================
# APPLICATION SHINY - ENSAssuRances
# Tableau de bord interactif du portefeuille
# ==============================================================================

library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)

# 1. CHARGEMENT DES DONNÉES (Se fait une seule fois au lancement)
# Assure-toi que l'application est dans le même dossier que tes fichiers .rds
contrats <- readRDS("../contrats_exploration_ok.rds")

# ==============================================================================
# INTERFACE UTILISATEUR (UI)
# ==============================================================================
ui <- dashboardPage(
  skin = "blue", # Couleur professionnelle
  
  # En-tête
  dashboardHeader(title = "ENSAssuRances KPI"),
  
  # Menu latéral
  dashboardSidebar(
    sidebarMenu(
      menuItem("Vue Portefeuille", tabName = "portefeuille", icon = icon("car")),
      menuItem("Segmentation (Clusters)", tabName = "clusters", icon = icon("users"))
    ),
    # Filtres interactifs dans le menu
    hr(),
    h4("Filtres interactifs", style = "margin-left: 15px; color: white;"),
    selectInput("energie", "Énergie du véhicule :", 
                choices = c("Toutes", unique(as.character(contrats$vhEnergy)))),
    selectInput("usage", "Usage du véhicule :", 
                choices = c("Tous", unique(as.character(contrats$ctUsage))))
  ),
  
  # Corps de l'application
  dashboardBody(
    tabItems(
      # --- ONGLET 1 : VUE PORTEFEUILLE ---
      tabItem(tabName = "portefeuille",
              fluidRow(
                # Les 3 KPI principaux (Value Boxes)
                valueBoxOutput("kpi_contrats", width = 4),
                valueBoxOutput("kpi_age_moyen", width = 4),
                valueBoxOutput("kpi_prime", width = 4)
              ),
              fluidRow(
                box(title = "Répartition par Type de Véhicule", status = "primary", solidHeader = TRUE, 
                    plotlyOutput("plot_segment"), width = 6),
                box(title = "Distribution de l'Âge des Conducteurs", status = "warning", solidHeader = TRUE, 
                    plotlyOutput("plot_age"), width = 6)
              )
      ),
      
      # --- ONGLET 2 : RAPPEL DES CLUSTERS ---
      tabItem(tabName = "clusters",
              h2("Rappel de la Segmentation Tarifaire (K-Means)"),
              p("Les algorithmes d'apprentissage non supervisé ont identifié 3 profils distincts :"),
              fluidRow(
                box(title = "Cluster 1 : Jeunes / Véhicules Modestes", status = "success", solidHeader = TRUE, width = 4,
                    h3("40% du portefeuille"),
                    p(strong("Âge moyen :"), " 34.7 ans"),
                    p(strong("Valeur Auto :"), " 8 710 €"),
                    p(strong("Prime moy :"), " 43 €"),
                    icon("graduation-cap", "fa-3x")
                ),
                box(title = "Cluster 2 : Seniors / Classique", status = "info", solidHeader = TRUE, width = 4,
                    h3("34% du portefeuille"),
                    p(strong("Âge moyen :"), " 59.1 ans"),
                    p(strong("Valeur Auto :"), " 9 786 €"),
                    p(strong("Prime moy :"), " 48 €"),
                    icon("user-tie", "fa-3x")
                ),
                box(title = "Cluster 3 : Quadras / Premium", status = "danger", solidHeader = TRUE, width = 4,
                    h3("26% du portefeuille"),
                    p(strong("Âge moyen :"), " 41.2 ans"),
                    p(strong("Valeur Auto :"), " 17 719 €"),
                    p(strong("Prime moy :"), " 48 € (Alerte Risque)"),
                    icon("gem", "fa-3x")
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
  
  # Création d'une base de données "réactive" qui s'adapte aux filtres
  data_filtree <- reactive({
    df <- contrats
    # Filtre Énergie
    if (input$energie != "Toutes") {
      df <- df %>% filter(vhEnergy == input$energie)
    }
    # Filtre Usage
    if (input$usage != "Tous") {
      df <- df %>% filter(ctUsage == input$usage)
    }
    return(df)
  })
  
  # --- Calcul des KPI ---
  output$kpi_contrats <- renderValueBox({
    valueBox(
      format(nrow(data_filtree()), big.mark = " "), 
      "Contrats Actifs", icon = icon("file-signature"), color = "blue"
    )
  })
  
  output$kpi_age_moyen <- renderValueBox({
    valueBox(
      paste0(round(mean(data_filtree()$drv1Age, na.rm = TRUE), 1), " ans"), 
      "Âge Moyen Conducteur", icon = icon("user-clock"), color = "purple"
    )
  })
  
  output$kpi_prime <- renderValueBox({
    valueBox(
      paste0(round(mean(data_filtree()$COT_AssBase, na.rm = TRUE), 0), " €"), 
      "Prime de Base Moyenne", icon = icon("euro-sign"), color = "green"
    )
  })
  
  # --- Graphique 1 : Répartition par Segment (Plotly) ---
  output$plot_segment <- renderPlotly({
    p <- data_filtree() %>%
      count(vhSegment) %>%
      ggplot(aes(x = reorder(vhSegment, -n), y = n, fill = vhSegment)) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      labs(x = "Segment", y = "Nombre") +
      theme(legend.position = "none", axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p) # Rend le graphique interactif (survol à la souris)
  })
  
  # --- Graphique 2 : Distribution de l'âge (Plotly) ---
  output$plot_age <- renderPlotly({
    p <- ggplot(data_filtree(), aes(x = drv1Age)) +
      geom_histogram(fill = "#e67e22", color = "white", bins = 30) +
      theme_minimal() +
      labs(x = "Âge du conducteur", y = "Effectif")
    
    ggplotly(p)
  })
}

# ==============================================================================
# LANCEMENT DE L'APPLICATION
# ==============================================================================
shinyApp(ui = ui, server = server)