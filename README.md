# Infraestructura GitOps — Terraform + Ansible + Jenkins

Pipeline de **infraestructura como código** que simula el ciclo completo de un despliegue corporativo:

1. **Terraform** aprovisiona un servidor (simulado con el provider `local`, sin costo de nube) y genera el inventario de Ansible.
2. **Ansible** configura la aplicación y reinicia el servicio web **solo si la configuración cambió** (handlers).
3. **Jenkins** orquesta todo con validación, plan, aprobación manual y despliegue.

```
 Git push ──► Jenkins
              ├─ 1. Lint        terraform fmt/validate · ansible --syntax-check
              ├─ 2. Plan        terraform plan -out=tfplan
              ├─ 3. Aprobación  input manual (gatekeeper)
              ├─ 4. Apply       terraform apply tfplan ──► servidor + hosts.ini
              └─ 5. Configurar  ansible-playbook -i hosts.ini playbook.yml
```

## Estructura

```
infraestructura-gitops/
├── Jenkinsfile
├── terraform/
│   ├── versions.tf            # versión de Terraform y provider
│   ├── variables.tf           # entorno, SO e IP (con validación)
│   ├── main.tf                # servidor simulado + inventario Ansible
│   ├── outputs.tf
│   └── templates/
│       └── hosts.ini.tftpl    # plantilla del inventario
└── ansible/
    ├── ansible.cfg
    └── playbook.yml           # configuración + handler de reinicio
```

## Requisitos

- Terraform >= 1.5
- Ansible (ansible-core) — en Windows, úsalo desde WSL
- Jenkins con el plugin *Pipeline* (opcional, para la orquestación)

## Ejecución local

```bash
# 1. Infraestructura
cd terraform
terraform init
terraform plan
terraform apply          # crea salida/servidor_produccion.txt y ../ansible/hosts.ini

# 2. Configuración
cd ../ansible
ansible-playbook -i hosts.ini playbook.yml
```

Cambiar de entorno:

```bash
terraform apply -var="entorno=staging" -var="ip_servidor=10.0.2.10"
```

Si ejecutas el playbook dos veces seguidas, la segunda vez el handler **no** se dispara: Ansible es idempotente y solo reinicia el servicio cuando la configuración realmente cambia.

Para limpiar: `terraform destroy`.

## Jenkins

1. Crea un job tipo **Pipeline** → *Pipeline script from SCM* → apunta a este repositorio.
2. Ejecuta con **Build with Parameters**:
   - `SIMULAR = true` (por defecto): solo imprime los comandos. Útil si el agente no tiene Terraform/Ansible.
   - `SIMULAR = false`: ejecuta los comandos reales. Funciona en agentes Windows (`bat`) y Linux (`sh`).
3. En la etapa 3, revisa el plan y pulsa **Aprobar y desplegar**.

## Conceptos aplicados

| Concepto | Dónde |
|---|---|
| Infraestructura como código | `terraform/` |
| Dependencias explícitas (`depends_on`) | `main.tf` |
| Plantillas (`templatefile`) | `templates/hosts.ini.tftpl` |
| Validación de variables | `variables.tf` |
| Gestión de configuración idempotente | `ansible/playbook.yml` |
| Reinicio condicional (handlers) | `ansible/playbook.yml` |
| CI/CD con aprobación manual | `Jenkinsfile` |
| Plan inmutable (`-out=tfplan`) | `Jenkinsfile` |

## Autor

Joshua Bobadilla — Ingeniería de Sistemas, Universidad Libre (Bogotá)
