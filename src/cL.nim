# Se integra el coeficiente de presiones a lo largo del perfil
# teniendo en cuenta su geometría, obteniendo el coeficiente de 
# sustentación
include "cargadatos.nim"
include "NACA.nim"
import sugar

# Se obtienen valores en los ejes del perfil (x, y)
proc obtenerFNeta(datos: DatosParaA): (float, float) =
    var contrib_X: float = 0, contrib_Y: float = 0
    # Iteramos extrados e intrados, con cuidado con los puntos
    return (contrib_X, contrib_Y)

for datoParaRe in datos:
    for datosParaA in datoParaRe.Datos:
        let cL = obtenerCL(datosParaA)
        