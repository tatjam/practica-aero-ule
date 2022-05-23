# Se integra el coeficiente de presiones a lo largo del perfil
# teniendo en cuenta su geometría, obteniendo el coeficiente de 
# sustentación
include "cargadatos.nim"
include "NACA.nim"
include "mincuadrados.nim"
import ggplotnim
import std/strformat

# Descomposicion de cP en x, y dados los puntos
# Utilizamos la técnica de interpolacion que se detalla en el escrito
proc segmento(p0: (float, float), p1: (float, float), cP0: float, cP1: float): (float, float, float) = 
    # Vector segmento
    let seg = (p1[0] - p0[0], p1[1] - p0[1])
    # Vector normal al segmento
    let normal = (-seg[1], seg[0])
    let dist = sqrt(seg[0] * seg[0] + seg[1] * seg[1])
    # Vector normalizado normal al segmento
    let nrm = (normal[0] / dist, normal[1] / dist)

    # Ahora, interpolando cP (simplemente la media ya que siempre totamos
    # el centro del segmento como punto de aplicacion de fuerzas)
    let cPint = 0.5 * (cP0 + cP1)

    # Finalmente, la fuerza es tambien proporcional a la longitud del segmento
    let fuerza = -cPint * dist
    
    var momento = 0.0
    # Las fuerzas en el eje y contribuyen respecto a la posicion x
    momento -= fuerza * nrm[1] * (0.5 * (p0[0] + p1[0]) - 0.25)
    # Las fuerzas en el eje x son mas simples ya que se toman respecto a y_c = 0
    momento += fuerza * nrm[0] * 0.5 * (p0[1] + p1[1])

    # Cambios de signos para coincidir con el esquema
    return (-fuerza * nrm[0], fuerza * nrm[1], momento)

# Se obtienen valores en los ejes del perfil (x, y, M)
proc obtenerFNeta(datos: DatosParaA): (float, float, float) =
    var contrib_X: float = 0
    var contrib_Y: float = 0
    var contrib_M: float = 0
    # Iteramos extrados
    for i in 1..14:
        var (x, y, M) = segmento((xc[i - 1], yc[i - 1]), (xc[i], yc[i]), datos.Datos[i - 1], datos.Datos[i])
        contrib_X += x
        contrib_Y += y
        contrib_M += M

    # Primer segmento del intrados, invertido
    var (x, y, M) = segmento((xc[0], yc[0]), (xc[15], yc[15]), datos.Datos[0], datos.Datos[15])
    contrib_X -= x
    contrib_Y -= y
    contrib_M -= M

    # Iteramos resto del intrados, invertidos
    for i in 16..29:
        var (x, y, M) = segmento((xc[i - 1], yc[i - 1]), (xc[i], yc[i]), datos.Datos[i - 1], datos.Datos[i])
        contrib_X -= x
        contrib_Y -= y
        contrib_M -= M

    return (contrib_X, contrib_Y, contrib_M)


for datoParaRe in datos:

    var alphas: seq[float]
    var cLs: seq[float]
    var cDs: seq[float]
    var cMs: seq[float]
    var XFOIL_cLs: seq[float]
    var XFOIL_cDs: seq[float]
    var XFOIL_cMs: seq[float]
    var cL_pot: seq[float]

    for datosParaA in datoParaRe.Datos:
        let (xNet, yNet, mNet) = obtenerFNeta(datosParaA)
        # Ahora, para alinearlo con los ejes L y D
        let alpha = degToRad(datosParaA.Angulo)
        #let L = -xNet * sin(alpha) + yNet * cos(alpha)
        #let D = -xNet * cos(alpha) + yNet * sin(alpha)
        let L = yNet * cos(alpha) - xNet * sin(alpha)
        let D = xNet * cos(alpha) + yNet * sin(alpha)
        # Nota, L y D ya estan adimensioanadas ya que las hemos
        # calculado utilizando cP y la longitud del perfil es 1.0 al estar
        # tambien normalizada
        alphas.add(datosParaA.Angulo)
        cLs.add(L)
        cL_pot.add(2.0 * PI * alpha)
        cDs.add(D)
        cMs.add(mNet)
        XFOIL_cLs.add(datosParaA.XFOIL_CL)
        XFOIL_cDs.add(datosParaA.XFOIL_CD)
        XFOIL_cMs.add(datosParaA.XFOIL_CM)

    # Analisis por minimos cuadrados de la curva cL y la polar
    let sol_cL = minCuadrados(alphas, cLs, 1)
    let sol_polar = minCuadrados(cLs, cDs, 2)

    let cLstr = fmt"$$c_l(\alpha) = {sol_cL[0]} + {sol_cL[1]}\alpha$$"
    let polarstr = fmt"$$c_d(c_l) = {sol_polar[0]} + {sol_polar[1]} c_l + {sol_polar[2]} c_l^2$$"
    # Guardamos los numeros a un fichero para incluir en el informe
    writeFile(fmt"resultados/mincuadrados_cL_{datoParaRe.Reynolds}.tex", clstr)
    writeFile(fmt"resultados/mincuadrados_polar_{datoParaRe.Reynolds}.tex", polarstr)

    echo sol_cL
    echo sol_polar
    var cLlinea: seq[float]
    var polarlinea: seq[float]
    for alpha in alphas:
        cLlinea.add(sol_cL[0] + sol_cL[1] * alpha)
    for cL in cLs:
        polarlinea.add(sol_polar[0] + sol_polar[1] * cL + sol_polar[2] * cL * cL)

    let df = seqsToDf({"$\\alpha$": alphas, "$c_l$": cLs, "$c_d$": cDs, "$c_{m}$": cMs,
    "$c_{li}$": cLlinea, "$c_{di}$": polarlinea, "$c_l^X$": XFOIL_cLs,
    "$c_d^X$": XFOIL_cDs, "$c_{m}^X$": XFOIL_cMs, "$c_{lp}$": cL_pot})
    let namecL = fmt"resultados/cLcD/cL_{datoParaRe.Reynolds}.tex"

    ggplot(df) + 
        geom_line(aes("$\\alpha$", "$c_l$")) + 
        geom_line(aes("$\\alpha$", "$c_{li}$"), color=color(1, 0, 0)) + 
        geom_line(aes("$\\alpha$", "$c_l^X$"), color=color(0, 0, 1), lineType=ltDashed) + 
        geom_line(aes("$\\alpha$", "$c_{lp}$"), color=color(0, 0.6, 0), lineType=ltDotDash) + 
        ggsave(namecL, onlyTikZ=true)

    let namecD = fmt"resultados/cLcD/cD_{datoParaRe.Reynolds}.tex"
    ggplot(df) + 
        geom_line(aes("$\\alpha$", "$c_d$")) + 
        geom_line(aes("$\\alpha$", "$c_d^X$"), color=color(0, 0, 255), lineType=ltDashed) + 
        ggsave(namecD, onlyTikZ=true)
    
    let namePolar = fmt"resultados/cLcD/polar_{datoParaRe.Reynolds}.tex"
    ggplot(df) + 
        geom_line(aes("$c_l$", "$c_d$")) + 
        geom_line(aes("$c_l$", "$c_{di}$"), color=color(255, 0, 0)) + 
        geom_line(aes("$c_l^X$", "$c_d^X$"), color=color(0, 0, 255), lineType=ltDashed) + 
        ggsave(namePolar, onlyTikZ=true)
    
    let nameM = fmt"resultados/cLcD/cM_{datoParaRe.Reynolds}.tex"
    ggplot(df) + 
        geom_line(aes("$\\alpha$", "$c_{m}$")) +
        geom_line(aes("$\\alpha$", "$c_{m}^X$"), color=color(0, 0, 255), lineType=ltDashed) +
        ggsave(nameM, onlyTikZ=true)

        

        