locals {
common_tags = {
        Project = var.project_name # Project first letter caps vunte nice ani
        Environment = var.environment
        Terraform = true
    }
    common_name_suffix = "${var.project_name}-${var.environment}" # roboshop-dev
    az_names = slice(data.aws_availability_zones.available.names, 0, 2 )
    # see slice funtion works
    #https://developer.hashicorp.com/terraform/language/functions/slice

  }
# Prefix means before word

# Examples:
# unhappy (not happy)
# preheat (heat before)
# dislike (opposite of like) 

# Suffix  after word

# Examples:
# quickly (adverb form)
# happiness (state of being)
# stronger (comparative