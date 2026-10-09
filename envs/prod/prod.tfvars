# prod - General Purpose database, 2+ API replicas, 35-day backups, alerts, purge-protected Key Vault.
# No secrets in this file. Apply with:  terraform apply -var-file=prod.tfvars   (add -var api_bootstrap=true on the FIRST apply)
#
# Two values below are deliberate placeholders. Validation blocks make `terraform plan` FAIL until they are replaced,
# so production cannot be deployed half-configured.

environment = "prod"
cost_center = "homeschool-engineering"

# CHANGE ME before the first apply (see dev.tfvars).
unique_suffix = "x7k2"

vnet_address_space = "10.30.0.0/16"

registry_sku       = "Standard"
log_retention_days = 90
log_daily_quota_gb = -1

postgres_sku_name              = "GP_Standard_D2ds_v5"
postgres_storage_mb            = 65536
postgres_backup_retention_days = 35
postgres_geo_redundant_backup  = false # cannot be changed later; enable now if cross-region restore is required
# Zone-redundant HA roughly doubles the database compute cost, so it is off by default. To turn it on later set
# postgres_high_availability_mode = "ZoneRedundant" (brief downtime while the standby is created).
postgres_high_availability_mode = null

key_vault_purge_protection_enabled   = true # irreversible
key_vault_soft_delete_retention_days = 90

container_apps_zone_redundant = true # fixed at creation
api_min_replicas              = 2
api_max_replicas              = 10
log_level                     = "INFO"

# The API refuses to start in prod unless OTP_PROVIDER=webhook with an https URL. The token is not set here: overwrite
# the otp-webhook-token secret in Key Vault after the first apply, then restart the API revision.
otp_provider    = "webhook"
otp_webhook_url = "https://sms-gateway.REPLACE-ME.invalid/send" # CHANGE ME: real https URL of the SMS gateway
seed_publish    = false                                         # review seeded content in the admin console before publishing

# Custom domains, once they exist (https only, no wildcard):
# extra_cors_origins = ["https://www.example.in", "https://admin.example.in"]

# Activity pictures (Blob Storage). Geo-redundant in prod; soft delete keeps a removed picture recoverable.
storage_replication_type = "GRS"
storage_soft_delete_days = 14

static_web_app_sku                  = "Standard"
static_web_app_preview_environments = false

enable_alerts = true
alert_email   = "ops@REPLACE-ME.invalid" # CHANGE ME

# Email (forgot-password, "Email me a code"): Gmail SMTP with an app password. No password in this file: after the first
# apply, overwrite the smtp-password secret in Key Vault with the account's app password, then restart the API revision.
email_provider = "smtp"
smtp_host      = "smtp.gmail.com"
smtp_port      = 587
smtp_security  = "starttls"
smtp_username  = "verification@learnnests.org"
email_from     = "LearnNest <verification@learnnests.org>"
