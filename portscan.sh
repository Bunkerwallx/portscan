#!/bin/bash

# Escáner de puertos en Bash

# Configuración inicial
read -p "Ingrese el rango de IPs en formato CIDR (por ejemplo, 192.168.1.0/24): " ip_range
read -p "Ingrese el puerto inicial (por ejemplo, 1): " port_start
read -p "Ingrese el puerto final (por ejemplo, 65535): " port_end
read -p "Ingrese el número máximo de hilos (por ejemplo, 100): " max_threads
read -p "¿Habilitar modo verbose? (s/n): " verbose

# Archivo de resultados
output_file="resultados_escaneo_$(date +%Y%m%d_%H%M%S).txt"

# Función para escanear un puerto en una IP específica
escanear_puerto() {
    ip=$1
    puerto=$2
    timeout 1 bash -c "</dev/tcp/$ip/$puerto" &>/dev/null && echo "$ip:$puerto" >> "$output_file"
    if [[ "$verbose" == "s" ]]; then
        echo "[+] $ip:$puerto está abierto"
    fi
}

# Generar tareas para escaneo
generar_tareas() {
    for ip in $(nmap -sL -n "$ip_range" | awk '/Nmap scan report/{print $NF}'); do
        for ((port=$port_start; port<=$port_end; port++)); do
            echo "$ip $port"
        done
    done
}

# Iniciar escaneo
echo "[+] Escaneando el rango de IPs: $ip_range"
echo "[+] Escaneando el rango de puertos: $port_start-$port_end"
echo "[+] Número máximo de hilos: $max_threads"

# Generar lista de tareas y ejecutar con parallel
inicio=$(date +%s)
generar_tareas | parallel -j "$max_threads" --colsep ' ' escanear_puerto
fin=$(date +%s)

# Calcular duración
duracion=$((fin - inicio))
echo "[+] Escaneo completado en $duracion segundos"

# Mostrar resultados
echo "[+] Resultados guardados en: $output_file"
