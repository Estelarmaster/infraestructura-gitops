# ---------------------------------------------------------------------------
# 1. Servidor simulado
#    Usamos el provider "local" para simular la creación de una VM (como una
#    instancia EC2 en AWS) sin costo: Terraform escribe un archivo con los
#    datos del "servidor".
# ---------------------------------------------------------------------------
resource "local_file" "servidor" {
  filename = "${path.module}/salida/servidor_${var.entorno}.txt"

  content = <<-EOT
    Servidor: srv-${var.entorno}-01
    Sistema operativo: ${var.sistema_operativo}
    IP: ${var.ip_servidor}
    Entorno: ${var.entorno}
  EOT
}

# ---------------------------------------------------------------------------
# 2. Puente Terraform -> Ansible
#    Generamos el inventario (hosts.ini) que Ansible usará en la etapa de
#    configuración. depends_on garantiza que el servidor exista primero.
# ---------------------------------------------------------------------------
resource "local_file" "inventario_ansible" {
  filename = "${path.module}/../ansible/hosts.ini"

  content = templatefile("${path.module}/templates/hosts.ini.tftpl", {
    entorno     = var.entorno
    ip_servidor = var.ip_servidor
  })

  depends_on = [local_file.servidor]
}
