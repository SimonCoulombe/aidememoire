library(tidyverse)
library(MASS)

set.seed(42)  # For reproducibility

# Function to generate sample data
generate_sample_data <- function(n_april = 1000, n_may = 1200) {
  
  # Helper function to generate correlated variables
  generate_correlated_vars <- function(n, means, sigma) {
    mvrnorm(n = n, mu = means, Sigma = sigma)
  }
  
  # ==== APRIL DATA ====
  cat("Generating April data (n =", n_april, ")...\n")
  
  # Demographics for April
  april_gender <- sample(c("Male", "Female"), n_april, replace = TRUE, prob = c(0.45, 0.55))
  april_age <- round(rnorm(n_april, mean = 35, sd = 8))
  april_age <- pmax(20, pmin(50, april_age))  # Constrain to 20-50
  
  # Additional demographic variables
  april_income <- round(rnorm(n_april, mean = 65000, sd = 15000))
  april_education <- sample(c("High School", "Bachelor", "Master", "PhD"), 
                            n_april, replace = TRUE, prob = c(0.3, 0.4, 0.25, 0.05))
  april_region <- sample(c("North", "South", "East", "West"), 
                         n_april, replace = TRUE, prob = c(0.25, 0.25, 0.25, 0.25))
  
  # Behavioral variables (correlated with demographics)
  april_website_visits <- rpois(n_april, lambda = ifelse(april_gender == "Male", 3, 2.5))
  april_email_opens <- rpois(n_april, lambda = ifelse(april_age > 40, 4, 2.5))
  april_social_media <- sample(c("Facebook", "Instagram", "LinkedIn", "Twitter", "None"), 
                               n_april, replace = TRUE, prob = c(0.3, 0.2, 0.2, 0.1, 0.2))
  
  # Product interest scores (0-10)
  april_product_interest <- round(runif(n_april, min = 1, max = 10))
  april_price_sensitivity <- round(runif(n_april, min = 1, max = 10))
  
  # Communication preferences
  april_contact_method <- sample(c("Email", "Phone", "SMS", "Mail"), 
                                 n_april, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1))
  april_time_to_respond <- round(rexp(n_april, rate = 0.2))  # Days
  
  # Seasonal/contextual variables
  april_weather_score <- round(rnorm(n_april, mean = 6, sd = 2))  # Spring weather
  april_competitor_activity <- round(runif(n_april, min = 1, max = 5))
  
  # Financial variables
  april_credit_score <- round(rnorm(n_april, mean = 720, sd = 80))
  april_debt_to_income <- round(runif(n_april, min = 0.1, max = 0.6), 2)
  
  # Purchase history
  april_previous_purchases <- rpois(n_april, lambda = 1.2)
  april_customer_tenure <- round(runif(n_april, min = 0, max = 60))  # Months
  
  # Quote-specific variables
  april_quote_amount <- round(rnorm(n_april, mean = 15000, sd = 5000))
  april_discount_offered <- round(runif(n_april, min = 0, max = 0.2), 2)
  april_sales_rep_experience <- round(runif(n_april, min = 1, max = 10))
  
  # Channel variables
  april_lead_source <- sample(c("Online", "Referral", "Direct", "Partner"), 
                              n_april, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1))
  april_device_type <- sample(c("Desktop", "Mobile", "Tablet"), 
                              n_april, replace = TRUE, prob = c(0.5, 0.4, 0.1))
  
  # Calculate closing probability for April (baseline behavior)
  april_logit <- -1.5 +  # Base intercept
    ifelse(april_gender == "Male", 0.3, 0) +  # Men more likely to buy
    (april_age - 35) * 0.02 +  # Older people slightly more likely
    (april_income - 65000) * 0.000008 +  # Higher income more likely
    ifelse(april_education %in% c("Master", "PhD"), 0.2, 0) +
    april_product_interest * 0.15 +
    -april_price_sensitivity * 0.08 +
    april_website_visits * 0.1 +
    ifelse(april_lead_source == "Referral", 0.4, 0) +
    april_discount_offered * 1.5 +
    (april_sales_rep_experience - 5) * 0.05
  
  april_prob <- plogis(april_logit)  # Convert to probability
  april_closed <- rbinom(n_april, 1, april_prob)
  
  april_data <- tibble(
    gender = april_gender,
    age = april_age,
    income = april_income,
    education = april_education,
    region = april_region,
    website_visits = april_website_visits,
    email_opens = april_email_opens,
    social_media = april_social_media,
    product_interest = april_product_interest,
    price_sensitivity = april_price_sensitivity,
    contact_method = april_contact_method,
    time_to_respond = april_time_to_respond,
    weather_score = april_weather_score,
    competitor_activity = april_competitor_activity,
    credit_score = april_credit_score,
    debt_to_income = april_debt_to_income,
    previous_purchases = april_previous_purchases,
    customer_tenure = april_customer_tenure,
    quote_amount = april_quote_amount,
    discount_offered = april_discount_offered,
    sales_rep_experience = april_sales_rep_experience,
    lead_source = april_lead_source,
    device_type = april_device_type,
    closed = as.logical(april_closed)
  )
  
  # ==== MAY DATA ====
  cat("Generating May data (n =", n_may, ")...\n")
  
  # Demographics for May - MORE MEN (composition effect)
  may_gender <- sample(c("Male", "Female"), n_may, replace = TRUE, prob = c(0.60, 0.40))  # More men!
  may_age <- round(rnorm(n_may, mean = 36, sd = 8))  # Slightly older
  may_age <- pmax(20, pmin(50, may_age))
  
  # Additional demographic variables (similar to April)
  may_income <- round(rnorm(n_may, mean = 66000, sd = 15000))  # Slightly higher
  may_education <- sample(c("High School", "Bachelor", "Master", "PhD"), 
                          n_may, replace = TRUE, prob = c(0.28, 0.42, 0.25, 0.05))
  may_region <- sample(c("North", "South", "East", "West"), 
                       n_may, replace = TRUE, prob = c(0.25, 0.25, 0.25, 0.25))
  
  # Behavioral variables
  may_website_visits <- rpois(n_may, lambda = ifelse(may_gender == "Male", 3.2, 2.7))  # Slightly higher
  may_email_opens <- rpois(n_may, lambda = ifelse(may_age > 40, 4.5, 2.7))  # Higher for older people
  may_social_media <- sample(c("Facebook", "Instagram", "LinkedIn", "Twitter", "None"), 
                             n_may, replace = TRUE, prob = c(0.28, 0.22, 0.22, 0.08, 0.2))
  
  # Product interest scores
  may_product_interest <- round(runif(n_may, min = 1, max = 10))
  may_price_sensitivity <- round(runif(n_may, min = 1, max = 10))
  
  # Communication preferences
  may_contact_method <- sample(c("Email", "Phone", "SMS", "Mail"), 
                               n_may, replace = TRUE, prob = c(0.42, 0.28, 0.22, 0.08))
  may_time_to_respond <- round(rexp(n_may, rate = 0.22))  # Slightly faster response
  
  # Seasonal/contextual variables
  may_weather_score <- round(rnorm(n_may, mean = 7.5, sd = 2))  # Better weather in May
  may_competitor_activity <- round(runif(n_may, min = 1, max = 5))
  
  # Financial variables
  may_credit_score <- round(rnorm(n_may, mean = 725, sd = 80))  # Slightly better
  may_debt_to_income <- round(runif(n_may, min = 0.1, max = 0.58), 2)
  
  # Purchase history
  may_previous_purchases <- rpois(n_may, lambda = 1.3)  # Slightly more loyal customers
  may_customer_tenure <- round(runif(n_may, min = 0, max = 62))
  
  # Quote-specific variables
  may_quote_amount <- round(rnorm(n_may, mean = 15200, sd = 5000))
  may_discount_offered <- round(runif(n_may, min = 0, max = 0.22), 2)  # Slightly higher discounts
  may_sales_rep_experience <- round(runif(n_may, min = 1, max = 10))
  
  # Channel variables
  may_lead_source <- sample(c("Online", "Referral", "Direct", "Partner"), 
                            n_may, replace = TRUE, prob = c(0.38, 0.32, 0.2, 0.1))
  may_device_type <- sample(c("Desktop", "Mobile", "Tablet"), 
                            n_may, replace = TRUE, prob = c(0.48, 0.42, 0.1))
  
  # Calculate closing probability for May - DIFFERENT BEHAVIOR (rate effect)
  may_logit <- -1.4 +  # Slightly higher base intercept (general improvement)
    ifelse(may_gender == "Male", 0.35, 0) +  # Men even more likely to buy in May
    (may_age - 35) * 0.035 +  # OLDER PEOPLE MUCH MORE LIKELY in May (rate effect!)
    (may_income - 65000) * 0.00001 +  # Income effect slightly stronger
    ifelse(may_education %in% c("Master", "PhD"), 0.25, 0) +
    may_product_interest * 0.16 +
    -may_price_sensitivity * 0.07 +  # Less price sensitive in May
    may_website_visits * 0.12 +
    ifelse(may_lead_source == "Referral", 0.45, 0) +
    may_discount_offered * 1.6 +  # Discounts more effective in May
    (may_sales_rep_experience - 5) * 0.06 +
    ifelse(may_weather_score > 7, 0.2, 0)  # Good weather helps in May
  
  may_prob <- plogis(may_logit)
  may_closed <- rbinom(n_may, 1, may_prob)
  
  may_data <- tibble(
    gender = may_gender,
    age = may_age,
    income = may_income,
    education = may_education,
    region = may_region,
    website_visits = may_website_visits,
    email_opens = may_email_opens,
    social_media = may_social_media,
    product_interest = may_product_interest,
    price_sensitivity = may_price_sensitivity,
    contact_method = may_contact_method,
    time_to_respond = may_time_to_respond,
    weather_score = may_weather_score,
    competitor_activity = may_competitor_activity,
    credit_score = may_credit_score,
    debt_to_income = may_debt_to_income,
    previous_purchases = may_previous_purchases,
    customer_tenure = may_customer_tenure,
    quote_amount = may_quote_amount,
    discount_offered = may_discount_offered,
    sales_rep_experience = may_sales_rep_experience,
    lead_source = may_lead_source,
    device_type = may_device_type,
    closed = as.logical(may_closed)
  )
  
  # Print summary statistics
  cat("\n=== DATA GENERATION SUMMARY ===\n")
  cat("April closing rate:", round(mean(april_data$closed) * 100, 1), "%\n")
  cat("May closing rate:", round(mean(may_data$closed) * 100, 1), "%\n")
  cat("Total change:", round((mean(may_data$closed) - mean(april_data$closed)) * 100, 1), "percentage points\n")
  
  cat("\nGender distribution:\n")
  cat("April - Male:", round(mean(april_data$gender == "Male") * 100, 1), "%, Female:", 
      round(mean(april_data$gender == "Female") * 100, 1), "%\n")
  cat("May - Male:", round(mean(may_data$gender == "Male") * 100, 1), "%, Female:", 
      round(mean(may_data$gender == "Female") * 100, 1), "%\n")
  
  cat("\nAge distribution:\n")
  cat("April - Mean age:", round(mean(april_data$age), 1), "\n")
  cat("May - Mean age:", round(mean(may_data$age), 1), "\n")
  
  cat("\nClosing rates by gender:\n")
  april_gender_rates <- april_data %>% group_by(gender) %>% summarise(rate = mean(closed), .groups = 'drop')
  may_gender_rates <- may_data %>% group_by(gender) %>% summarise(rate = mean(closed), .groups = 'drop')
  
  for(g in c("Male", "Female")) {
    apr_rate <- april_gender_rates$rate[april_gender_rates$gender == g]
    may_rate <- may_gender_rates$rate[may_gender_rates$gender == g]
    cat(g, "- April:", round(apr_rate * 100, 1), "%, May:", round(may_rate * 100, 1), "%\n")
  }
  
  cat("\nClosing rates by age group:\n")
  april_age_rates <- april_data %>% 
    mutate(age_group = cut(age, breaks = c(20, 30, 40, 50), labels = c("20-29", "30-39", "40-50"))) %>%
    group_by(age_group) %>% summarise(rate = mean(closed), .groups = 'drop')
  
  may_age_rates <- may_data %>% 
    mutate(age_group = cut(age, breaks = c(20, 30, 40, 50), labels = c("20-29", "30-39", "40-50"))) %>%
    group_by(age_group) %>% summarise(rate = mean(closed), .groups = 'drop')
  
  for(ag in c("20-29", "30-39", "40-50")) {
    apr_rate <- april_age_rates$rate[april_age_rates$age_group == ag]
    may_rate <- may_age_rates$rate[may_age_rates$age_group == ag]
    if(length(apr_rate) > 0 && length(may_rate) > 0) {
      cat(ag, "- April:", round(apr_rate * 100, 1), "%, May:", round(may_rate * 100, 1), "%\n")
    }
  }
  
  return(list(april = april_data, may = may_data))
}

# Generate the data
sample_data <- generate_sample_data(n_april = 1000, n_may = 1200)
april_data <- sample_data$april
may_data <- sample_data$may



library(tidymodels)
library(tidyverse)

library(glmnet)
library(vip)
library(probably)

# Closing Ratio Decomposition using tidymodels and tidyverse
# This implements Oaxaca-Blinder decomposition for high-dimensional data


# Main decomposition function
decompose_closing_ratio <- function(april_data, may_data, outcome_col = "closed", 
                                    model_type = "logistic") {
  
  # Step 1: Prepare data
  april_prep <- april_data %>% 
    mutate(month = "april", .before = 1)
  
  may_prep <- may_data %>% 
    mutate(month = "may", .before = 1)
  
  combined_data <- bind_rows(april_prep, may_prep)
  
  # Step 2: Create recipe for preprocessing
  recipe_obj <- recipe(as.formula(paste(outcome_col, "~ . -month")), 
                       data = combined_data) %>%
    step_dummy(all_nominal_predictors()) %>%
    step_normalize(all_numeric_predictors()) %>%
    step_zv(all_predictors()) %>%  # remove zero variance
    step_corr(all_numeric_predictors(), threshold = 0.95)  # remove highly correlated
  
  # Step 3: Fit models for each month separately
  april_split <- april_prep %>% initial_split(prop = 1)
  may_split <- may_prep %>% initial_split(prop = 1)
  
  # Model specifications
  if (model_type == "logistic") {
    model_spec <- logistic_reg(penalty = tune(), mixture = tune()) %>%
      set_engine("glmnet") %>%
      set_mode("classification")
  } else if (model_type == "random_forest") {
    model_spec <- rand_forest(mtry = tune(), min_n = tune()) %>%
      set_engine("ranger", importance = "impurity") %>%
      set_mode("classification")
  }
  
  # Create workflow
  wf <- workflow() %>%
    add_recipe(recipe_obj) %>%
    add_model(model_spec)
  
  # Tune and fit April model
  april_folds <- vfold_cv(training(april_split), v = 5, strata = all_of(outcome_col))
  
  tune_grid <- if (model_type == "logistic") {
    grid_regular(penalty(), mixture(), levels = 5)
  } else {
    grid_regular(mtry(range = c(5, 15)), min_n(), levels = 5)
  }
  
  april_tune <- wf %>%
    tune_grid(resamples = april_folds, grid = tune_grid, 
              metrics = metric_set(roc_auc, accuracy))
  
  april_best <- april_tune %>% select_best("roc_auc")
  april_final <- wf %>% finalize_workflow(april_best) %>% fit(training(april_split))
  
  # Fit May model
  may_folds <- vfold_cv(training(may_split), v = 5, strata = all_of(outcome_col))
  may_tune <- wf %>%
    tune_grid(resamples = may_folds, grid = tune_grid, 
              metrics = metric_set(roc_auc, accuracy))
  
  may_best <- may_tune %>% select_best("roc_auc")
  may_final <- wf %>% finalize_workflow(may_best) %>% fit(training(may_split))
  
  # Step 4: Generate predictions for decomposition
  april_pred_april <- predict(april_final, april_prep, type = "prob")$.pred_TRUE
  may_pred_may <- predict(may_final, may_prep, type = "prob")$.pred_TRUE
  may_pred_april <- predict(april_final, may_prep, type = "prob")$.pred_TRUE  # Counterfactual
  
  # Step 5: Calculate actual rates
  actual_april <- mean(april_prep[[outcome_col]] == TRUE)
  actual_may <- mean(may_prep[[outcome_col]] == TRUE)
  
  # Step 6: Decomposition
  composition_effect <- mean(may_pred_april) - mean(april_pred_april)
  rate_effect <- actual_may - mean(may_pred_april)
  total_change <- actual_may - actual_april
  
  # Step 7: Variable importance
  april_vip <- april_final %>% 
    extract_fit_parsnip() %>% 
    vip(num_features = 20) %>% 
    pluck("data") %>%
    as_tibble() %>%
    mutate(month = "april")
  
  may_vip <- may_final %>% 
    extract_fit_parsnip() %>% 
    vip(num_features = 20) %>% 
    pluck("data") %>%
    as_tibble() %>%
    mutate(month = "may")
  
  # Return comprehensive results
  list(
    decomposition = tibble(
      metric = c("Total Change", "Composition Effect", "Rate Effect"),
      value = c(total_change, composition_effect, rate_effect),
      percentage_points = value * 100
    ),
    actual_rates = tibble(
      month = c("April", "May"),
      actual_rate = c(actual_april, actual_may)
    ),
    variable_importance = bind_rows(april_vip, may_vip),
    models = list(april = april_final, may = may_final),
    predictions = tibble(
      month = rep(c("april", "may"), c(nrow(april_prep), nrow(may_prep))),
      actual = c(april_prep[[outcome_col]], may_prep[[outcome_col]]),
      predicted_april_model = c(april_pred_april, may_pred_april),
      predicted_may_model = c(rep(NA, nrow(april_prep)), may_pred_may)
    )
  )
}

# Variable-level decomposition function
detailed_variable_decomposition <- function(april_data, may_data, outcome_col = "closed") {
  
  # Get predictor columns
  pred_cols <- setdiff(names(april_data), outcome_col)
  
  # Function to analyze single variable
  analyze_variable <- function(var_name) {
    
    var_data <- tibble(
      month = c(rep("april", nrow(april_data)), rep("may", nrow(may_data))),
      variable_value = c(april_data[[var_name]], may_data[[var_name]]),
      outcome = c(april_data[[outcome_col]], may_data[[outcome_col]])
    ) %>%
      filter(!is.na(variable_value))
    
    if (is.numeric(var_data$variable_value)) {
      # For numeric: create quantile bins
      breaks <- var_data$variable_value %>% 
        quantile(probs = seq(0, 1, 0.25), na.rm = TRUE) %>% 
        unique()
      
      var_data <- var_data %>%
        mutate(group = cut(variable_value, breaks = breaks, include.lowest = TRUE))
      
    } else {
      # For categorical: use as-is
      var_data <- var_data %>%
        mutate(group = as.character(variable_value))
    }
    
    # Calculate rates and weights by group and month
    group_stats <- var_data %>%
      group_by(month, group) %>%
      summarise(
        n = n(),
        rate = mean(outcome == TRUE, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      group_by(month) %>%
      mutate(weight = n / sum(n)) %>%
      ungroup()
    
    # Pivot to get april and may side by side
    april_stats <- group_stats %>% 
      filter(month == "april") %>%
      select(group, rate_april = rate, weight_april = weight)
    
    may_stats <- group_stats %>% 
      filter(month == "may") %>%
      select(group, rate_may = rate, weight_may = weight)
    
    # Join and calculate effects
    combined_stats <- full_join(april_stats, may_stats, by = "group") %>%
      replace_na(list(rate_april = 0, weight_april = 0, rate_may = 0, weight_may = 0)) %>%
      mutate(
        composition_contribution = (weight_may - weight_april) * rate_april,
        rate_contribution = weight_may * (rate_may - rate_april)
      )
    
    # Summarize for this variable
    tibble(
      variable = var_name,
      composition_effect = sum(combined_stats$composition_contribution, na.rm = TRUE),
      rate_effect = sum(combined_stats$rate_contribution, na.rm = TRUE),
      total_effect = composition_effect + rate_effect,
      n_groups = nrow(combined_stats)
    )
  }
  
  # Apply to all variables
  map_dfr(pred_cols, analyze_variable) %>%
    arrange(desc(abs(total_effect)))
}

# Visualization function
plot_decomposition <- function(decomp_results) {
  
  # Main decomposition plot
  p1 <- decomp_results$decomposition %>%
    ggplot(aes(x = metric, y = percentage_points, fill = metric)) +
    geom_col(alpha = 0.8) +
    geom_text(aes(label = paste0(round(percentage_points, 2), "pp")), 
              vjust = -0.5) +
    scale_fill_viridis_d() +
    theme_minimal() +
    labs(
      title = "Closing Ratio Decomposition",
      subtitle = "Change from April to May (percentage points)",
      x = NULL, y = "Percentage Points"
    ) +
    theme(legend.position = "none")
  
  # Variable importance comparison
  p2 <- decomp_results$variable_importance %>%
    slice_head(n = 10) %>%
    ggplot(aes(x = Importance, y = reorder(Variable, Importance), fill = month)) +
    geom_col(position = "dodge", alpha = 0.8) +
    scale_fill_manual(values = c("april" = "steelblue", "may" = "orange")) +
    theme_minimal() +
    labs(
      title = "Top 10 Variable Importance by Month",
      x = "Importance", y = NULL,
      fill = "Month"
    )
  
  list(decomposition = p1, variable_importance = p2)
}

# Summary function
summarize_results <- function(decomp_results, detailed_results = NULL) {
  
  cat("=== CLOSING RATIO DECOMPOSITION SUMMARY ===\n\n")
  
  decomp <- decomp_results$decomposition
  total_change <- decomp$percentage_points[decomp$metric == "Total Change"]
  comp_effect <- decomp$percentage_points[decomp$metric == "Composition Effect"]
  rate_effect <- decomp$percentage_points[decomp$metric == "Rate Effect"]
  
  cat("Total change:", round(total_change, 2), "percentage points\n")
  cat("  - Due to customer mix changes:", round(comp_effect, 2), "pp (", 
      round(100 * comp_effect/total_change, 1), "%)\n")
  cat("  - Due to behavior changes:", round(rate_effect, 2), "pp (", 
      round(100 * rate_effect/total_change, 1), "%)\n\n")
  
  if (!is.null(detailed_results)) {
    cat("TOP 5 VARIABLES BY TOTAL EFFECT:\n")
    detailed_results %>%
      head(5) %>%
      mutate(across(c(composition_effect, rate_effect, total_effect), ~ round(.x * 100, 2))) %>%
      select(variable, composition_effect, rate_effect, total_effect) %>%
      print()
  }
  
  cat("\nActual closing rates:\n")
  print(decomp_results$actual_rates)
}

# Example usage:
# results <- decompose_closing_ratio(april_data, may_data, "closed", "logistic")
# detailed <- detailed_variable_decomposition(april_data, may_data, "closed")
# plots <- plot_decomposition(results)
# summarize_results(results, detailed)
