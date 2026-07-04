# Seguridad

## Secretos

**Nunca commitees** al repositorio:

- `terraform.tfvars` con credenciales, tokens o passwords reales
- Archivos de state (`terraform.tfstate`, `*.tfstate.backup`)
- Claves AWS, kubeconfig, certificados privados
- API tokens (FortiGate, GitHub, etc.)

Usá variables de entorno, AWS SSO o archivos locales gitignored.

## Buenas prácticas

1. Copiá valores de ejemplo en tfvars; los reales quedan fuera del repo
2. Revisá `terraform plan` antes de `apply`, especialmente en producción
3. Principio de mínimo privilegio en roles IAM
4. Rotá credenciales periódicamente

## Consideraciones del proyecto

- Credenciales SMTP en Secrets Manager: no commitear `tmp/decoded_output.txt`
- Policy IAM restringe envío a la IP configurada en `cluster_ip`

## Reporte de vulnerabilidades

Si encontrás un problema de seguridad, abrí un [GitHub Security Advisory](https://github.com/ghcetraro/terraform_aws_ses_smtp/security/advisories/new) o contactá al mantenedor del repo. No abras issues públicos con detalles explotables.
