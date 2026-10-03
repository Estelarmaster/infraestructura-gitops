// Pipeline GitOps: Terraform (infraestructura) + Ansible (configuracion)
// Funciona en agentes Windows (bat) y Linux/macOS (sh).
// Si SIMULAR = true, solo imprime los comandos (util si el agente no tiene
// Terraform/Ansible instalados).

def ejecutar(String comando) {
    if (params.SIMULAR) {
        echo "Simulando: ${comando}"
    } else if (isUnix()) {
        sh comando
    } else {
        bat comando
    }
}

pipeline {
    agent any

    parameters {
        booleanParam(name: 'SIMULAR', defaultValue: true, description: 'Solo imprimir los comandos, sin ejecutarlos')
    }

    options {
        disableConcurrentBuilds()
    }

    environment {
        TF_DIR      = 'terraform'
        ANSIBLE_DIR = 'ansible'
        TF_IN_AUTOMATION = 'true'
    }

    stages {
        stage('1. Auditoria de codigo (lint)') {
            steps {
                dir(env.TF_DIR) {
                    ejecutar('terraform init -input=false')
                    ejecutar('terraform fmt -check')
                    ejecutar('terraform validate')
                }
                dir(env.ANSIBLE_DIR) {
                    ejecutar('ansible-playbook --syntax-check -i localhost, playbook.yml')
                }
            }
        }

        stage('2. Planificacion (terraform plan)') {
            steps {
                dir(env.TF_DIR) {
                    ejecutar('terraform plan -input=false -out=tfplan')
                }
            }
        }

        stage('3. Aprobacion manual') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: '¿El terraform plan es correcto? ¿Aprobar la infraestructura?',
                          ok: 'Aprobar y desplegar'
                }
            }
        }

        stage('4. Aprovisionamiento (terraform apply)') {
            steps {
                dir(env.TF_DIR) {
                    ejecutar('terraform apply -input=false tfplan')
                }
            }
        }

        stage('5. Configuracion (Ansible)') {
            steps {
                dir(env.ANSIBLE_DIR) {
                    echo 'Esperando 5 s a que el servidor este listo...'
                    sleep 5
                    ejecutar('ansible-playbook -i hosts.ini playbook.yml')
                }
            }
        }
    }

    post {
        success { echo 'Despliegue completado correctamente.' }
        failure { echo 'El pipeline fallo. Revisa la etapa marcada en rojo.' }
    }
}
