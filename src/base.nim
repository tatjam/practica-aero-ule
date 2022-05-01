import std/parsecsv
import std/strutils
import std/strscans
import os

# Temperatura (K)
let T = 296.85
# Presion (Pa)
let P = 91900

# Set de datos para un alfa dado
type DatosParaA = tuple
    Angulo: float
    # Media de las presiones relativas respecto a la presión dada por el tubo pitot
    # que asumimos como valor 0
    Datos: array[30, float]

# Set de datos para un Re dado
type DatosParaRe = tuple
    Reynolds: float
    Datos: seq[DatosParaA]

proc limpiarLinea(linea: string): string = 
    # Eliminamos todos los espacios
    var final: string
    for ch in linea:
        if ch != ' ' and ch != '\t':
            final.add(ch)
    return final

    

proc cargarDatosParaA(path: string, angulo: float): DatosParaA =
    var datos: array[30, float]
    var presionEstatica: seq[float]
    var tiempos: seq[float]

    var p: CsvParser
    p.open(path)
    # Medias para cada canal
    var numdatos: int = 0
    while p.readRow():
        # [fecha], [hora], [tiempo exacto], 250, 10, 32, 111, [30 medidas de presion], pitot estanc, pitot estatica
        # Tan solo nos interesan las medidas (las dos ultimas son del pitot) y el tiempo exacto:
        let texacto = parseFloat(limpiarLinea(p.row[2]))
        tiempos.add(texacto)
        tiempos[tiempos.len - 1] -= tiempos[0]
        for i in 0..29:
            # Calculamos ya directamente la presio "0" y la restamos
            let pitot = parseFloat(limpiarLinea(p.row[38]))
            datos[i] += parseFloat(limpiarLinea(p.row[7 + i])) - pitot
        numdatos += 1
        
    for i in 0..29:
        datos[i] /= float(numdatos)

    echo "\t - Se leyeron ", numdatos, " datos para un angulo de ", angulo, "º que se extienden ", tiempos[tiempos.len - 1], "s"
    
    return (Angulo: angulo, Datos: datos)


proc cargarReynolds(path: string): DatosParaRe =
    var re: float
    var anterior: string
    discard scanf(path, "$*\\RE $f", anterior, re)  
    echo "Cargando directorio (", path, ") para un Reynolds = ", re
    var datos: seq[DatosParaA]
    # Leamos ahora cada subfichero que contiene los datos para cada angulo
    for kind, subpath in walkDir(path):
        case kind:
        of pcFile:
            var grados: int
            if scanf(subpath, "$*\\$*\\$i GRADOS.csv", anterior, anterior, grados):
                # Convertimos los grados a float
                let angulo = float(grados)
                datos.add(cargarDatosParaA(subpath, angulo))
        else: discard
    return (Reynolds: re, Datos: datos)





var datos: seq[DatosParaRe]

# Cargamos cada numero de reynolds utilizando los nombres de las carpetas
for kind, path in walkDir("datos/"):
    case kind:
    of pcDir:
        datos.add(cargarReynolds(path))
    else: discard

# A partir de aqui ya estan preparados los datos para su estudio