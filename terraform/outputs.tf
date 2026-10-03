output "servidor_archivo" {
  description = "Ruta del archivo que representa el servidor simulado"
  value       = local_file.servidor.filename
}

output "inventario_ansible" {
  description = "Ruta del inventario generado para Ansible"
  value       = local_file.inventario_ansible.filename
}
