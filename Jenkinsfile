pipeline {
    agent any 
    environment {
        PROYECTO = 'Monolito4bm/Monolito4bm.csproj'
    }
    stages {
        stage('Descargar Código') {
            steps {
                echo 'Descargando la última versión de GitHub...'
                checkout scm
            }
        }
        stage('Restaurar Paquetes') {
            steps {
                echo 'Restaurando dependencias de NuGet...'
                sh 'dotnet restore ${PROYECTO}'
            }
        }
        stage('Compilar Solución') {
            steps {
                echo 'Compilando Monolito4bm...'
                sh 'dotnet build ${PROYECTO} --configuration Release --no-restore'
            }
        }
        stage('Ejecutar Pruebas') {
            steps {
                echo 'Corriendo pruebas unitarias...'
                // Si no tienes pruebas, puedes borrar este stage o comentarlo
                sh 'dotnet test ${PROYECTO} --no-build --verbosity normal'
            }
        }
        stage('Publicar Aplicación') {
            steps {
                echo 'Generando la carpeta con los archivos listos para IIS...'
                // Generará los archivos en la carpeta "publish_output" en la raíz
                sh 'dotnet publish ${PROYECTO} -c Release -o ./publish_output'
            }
        }
        
        stage('Desplegar en IIS') {
            steps {
                echo 'Enviando archivos al Servidor Windows...'
                // Pendiente de configurar según cómo pases los archivos a Windows
            }
        }
    }
}
