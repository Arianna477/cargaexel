pipeline {
    agent any 
    
    environment {
        // Tu proyecto principal
        PROYECTO = 'Monolito4bm/Monolito4bm.csproj'
        // Tu nuevo proyecto de pruebas
        PROYECTO_TEST = 'Monolito4bm.Test/Monolito4bm.Test.csproj'
        // Tu script de base de datos
        SCRIPT_SQL = 'BaseDeDatos/script_bd.sql'
    }
    
    stages {
        stage('Descargar Código') {
            steps {
                echo 'Descargando la última versión de GitHub...'
                checkout scm
            }
        }
        
        stage('Construir Base de Datos') {
            steps {
                echo 'Ejecutando script SQL para crear tablas y datos...'
                sh '/opt/mssql-tools/bin/sqlcmd -S host.docker.internal -U jenkis -P jenkis -i ${SCRIPT_SQL}'
            }
        }
        
        stage('Restaurar Paquetes') {
            steps {
                echo 'Restaurando dependencias de NuGet...'
                sh 'dotnet restore ${PROYECTO}'
                sh 'dotnet restore ${PROYECTO_TEST}'
            }
        }
        
        stage('Compilar Solución') {
            steps {
                echo 'Compilando código web y pruebas...'
                sh 'dotnet build ${PROYECTO} --configuration Release --no-restore'
                sh 'dotnet build ${PROYECTO_TEST} --configuration Release --no-restore'
            }
        }
        
        stage('Ejecutar Pruebas') {
            steps {
                echo 'Corriendo pruebas y generando archivo XML para la gráfica...'
                // Usamos TRX en lugar de JUnit
                sh 'dotnet test ${PROYECTO_TEST} --no-build --configuration Release --logger "trx;LogFileName=resultados_pruebas.trx"'
            }
        }
        
        stage('Publicar Aplicación') {
            steps {
                echo 'Generando la carpeta con los archivos listos para IIS...'
                sh 'dotnet publish ${PROYECTO} -c Release -o ./publish_output'
            }
        }
        
        stage('Desplegar en IIS') {
            steps {
                echo 'Aviso: Copia manual requerida a C:\\inetpub\\wwwroot\\Monolito'
            }
        }
    }
    post {
        always {
            echo 'Dibujando la gráfica...'
            // Cambiamos el comando junit por mstest
            mstest testResultsFile:"**/*.trx", keepLongStdio: true
        }
    }
}
