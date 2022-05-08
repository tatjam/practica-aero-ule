# Se integra el coeficiente de presiones a lo largo del perfil
# teniendo en cuenta su geometría, obteniendo el coeficiente de 
# sustentación
include "cargadatos.nim"
include "NACA.nim"
import ggplotnim
import std/strformat

# Descomposicion de cP en x, y dados los puntos
# Utilizamos la técnica de interpolacion que se detalla en el escrito
proc segmento(p0: (float, float), p1: (float, float), cP0: float, cP1: float): (float, float) = 
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
    
    return (cPint * nrm[0], cPint * nrm[1])

# Se obtienen valores en los ejes del perfil (x, y)
proc obtenerFNeta(datos: DatosParaA): (float, float) =
    var contrib_X: float = 0
    var contrib_Y: float = 0
    # Iteramos extrados
    for i in 1..14:
        var (x, y) = segmento((xc[i - 1], yc[i - 1]), (xc[i], yc[i]), datos.Datos[i - 1], datos.Datos[i])
        contrib_X += x
        contrib_Y += y

    # Primer segmento del intrados, invertido
    var (x, y) = segmento((xc[0], yc[0]), (xc[15], yc[15]), datos.Datos[0], datos.Datos[15])
    contrib_X -= x
    contrib_Y -= y

    # Iteramos resto del intrados, invertidos
    for i in 16..29:
        var (x, y) = segmento((xc[i - 1], yc[i - 1]), (xc[i], yc[i]), datos.Datos[i - 1], datos.Datos[i])
        contrib_X -= x
        contrib_Y -= y

    return (contrib_X, contrib_Y)

for datoParaRe in datos:

    var alphas: seq[float]
    var cLs: seq[float]
    var cDs: seq[float]

    for datosParaA in datoParaRe.Datos:
        let (xNet, yNet) = obtenerFNeta(datosParaA)
        # Ahora, para alinearlo con los ejes L y D
        let alpha = degToRad(datosParaA.Angulo)
        echo fmt"{datosParaA.Angulo} deg = {alpha}rad"
        let L = -xNet * sin(alpha) + yNet * cos(alpha)
        let D = -xNet * cos(alpha) + yNet * sin(alpha)
        alphas.add(datosParaA.Angulo)
        cLs.add(L)
        cDs.add(D)
  
    let df = seqsToDf({"$\\alpha$": alphas, "$c_l$": cLs, "$c_d$": cDs})
    let namecL = fmt"resultados/cLcD/cL_{datoParaRe.Reynolds}.tex"
    ggplot(df, aes("$\\alpha$", "$c_l$")) + 
        geom_line() + 
        ggsave(namecL, standalone=true)

    let namecD = fmt"resultados/cLcD/cD_{datoParaRe.Reynolds}.tex"
    ggplot(df, aes("$\\alpha$", "$c_d$")) + 
        geom_line() + 
        ggsave(namecD, standalone=true)
    
    let namePolar = fmt"resultados/cLcD/polar_{datoParaRe.Reynolds}.tex"
    ggplot(df, aes("$c_l$", "$c_d$")) + 
        geom_line() + 
        ggsave(namePolar, standalone=true)

        

        