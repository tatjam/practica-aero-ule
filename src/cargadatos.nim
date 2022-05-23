import std/parsecsv
import std/strutils
import std/strscans
import std/algorithm
import os

# Datos experimentales:
# Temperatura (K)
let T = 296.85
# Presion (Pa)
let P = 91900
# Longitud (m)
let L = 0.25
# Viscosidad (kg m^-1 s^-1)
let mu = 1.8e-5
# Densidad (kg m^-3)
let rho = 1.079


# Set de datos para un alfa dado
type DatosParaA = tuple
    Angulo: float
    XFOIL_CL: float
    XFOIL_CD: float 
    XFOIL_CM: float
    # Valores de cP calculados con la formula desarrollada
    Datos: array[30, float]
    # Varianza de cP
    Varianzas: array[30, float]
    XFOIL_Datos: array[30, float]

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

    
type DatosXFoil = tuple
    x: seq[float]
    y: seq[float]
    cp: seq[float]
    cL: float
    cD: float
    cM: float


proc cargarXFoil(path: string): DatosXFoil =
    var x: seq[float]
    var y: seq[float]
    var cp: seq[float]
    var cL: float
    var cD: float
    var cM: float
    var numli = 0

    for line in lines(path):
        var vx, vy, vcp: float
        if numli == 2:
            discard scanf(line, "$scL = $f cM = $f cD = $f", cL, cM, cD)
        elif numli >= 4:
            # La lectura es muy simple gracias a scanf
            discard scanf(line, "$s$f $s$f $s$f", vx, vy, vcp)
            x.add(vx)
            y.add(vy)
            cp.add(vcp)
        numli += 1


    return (x: x, y: y, cp: cp, cL: cL, cD: cD, cM: cM)



proc cargarDatosParaA(path: string, angulo: float): DatosParaA =
    var todosdatos: seq[array[30, float]]
    var datos: array[30, float]
    var varianzas: array[30, float]
    for i in 0..29:
        datos[i] = 0.0
        varianzas[i] = 0.0

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
        var sub: array[30, float]
        for i in 0..29:
            # Calculamos ya directamente cP
            # P de estagnacion + P estatica
            let P0 = parseFloat(limpiarLinea(p.row[37]))
            # P estatica
            let Pinf = parseFloat(limpiarLinea(p.row[38]))
            # P en el punto de evaluacon
            let Pi = parseFloat(limpiarLinea(p.row[7 + i]))
            sub[i] = (Pi - Pinf) / (P0 - Pinf) 
            datos[i] += sub[i]
        numdatos += 1
        todosdatos.add(sub)
        
    for i in 0..29:
        datos[i] /= float(numdatos)

    # Calculo de la varianza
    for sub in todosdatos:
        for i in 0..29:
            var dev = sub[i] - datos[i]
            varianzas[i] += dev * dev
    
    # Corregimos el punto 30 utilizando la presion anterior debido a datos erroneos
    datos[29] = datos[28]
    

    echo "\t - Se leyeron ", numdatos, " datos para un angulo de ", angulo, "º que se extienden ", tiempos[tiempos.len - 1], "s"

    # Cargamos ahora los datos de xfoil, mismo nombre de carpeta pero empieza en datos_xfoil en vez de datos
    var XFOIL_path = "datos_xfoil/" & substr(path, 6)
    let XFOIL_datos = cargarXFoil(XFOIL_path)
    var XFOIL_datoscp: array[30, float]

    # Los valores siempre son los mismos por lo que utilizo un mapeo directo
    # es aproximado pero apropiado para elaborar el grafico ya que son pequeñas discrepancias
    let mapeo = [89, 65, 58, 55, 52, 45, 42, 40, 37, 
    35, 33, 29, 21, 14, 6, 94, 100, 104, 107, 111, 114, 117, 119, 
    122, 124, 126, 134, 142, 149, 153]
    for i in 0..29:
        XFOIL_datoscp[i] = XFOIL_datos.cp[mapeo[i]]


    return (Angulo: angulo, XFOIL_CL: XFOIL_datos.cL, XFOIL_CD: XFOIL_datos.cD, XFOIL_CM: XFOIL_datos.cM, Datos: datos,
        Varianzas: varianzas, XFOIL_Datos: XFOIL_datoscp)

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
            if scanf(subpath, "$*\\$*\\$i.csv", anterior, anterior, grados):
                # Convertimos los grados a float
                let angulo = float(grados)
                datos.add(cargarDatosParaA(subpath, angulo))
        else: discard

    # Ahora ordenamos los datos por angulo
    proc comp(x, y: DatosParaA): int = cmp(x.Angulo, y.Angulo)
    datos.sort(comp)
    return (Reynolds: re, Datos: datos)



var datos: seq[DatosParaRe]

# Cargamos cada numero de reynolds utilizando los nombres de las carpetas
for kind, path in walkDir("datos/"):
    case kind:
    of pcDir:
        datos.add(cargarReynolds(path))
    else: discard

# A partir de aqui ya estan preparados los datos para su estudio