# Política para la aplicación
path "database/creds/app-role" {
  capabilities = ["read"]
}

path "secret/data/app/*" {
  capabilities = ["read"]
}

# Política para renovación de leases
path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/revoke" {
  capabilities = ["update"]
}
