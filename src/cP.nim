# Se genera una serie de gráficos del cP a lo largo del intrados 
# para cada combinacion de Reynolds y alfa. El directorio de salida es
# resultados/cP/cP_[REYNOLDS]_[ALFA].png

include "cargadatos.nim"
include "NACA.nim"

# El calculo del cP es muy simple ya que simplemente:
# c_P = (P - P_0) / (1/2 * Rho_0 * V_0^2)
# Observamos que los datos que calculamos en base son P - P_0
# y que rho_0 es constante. V_0 se puede calcular utilizando el N. Reynolds:
# v = (Re * mu) / (rho * L) (mu es la viscosidad, una constante)
# De esta forma simplificamos los datos, siendo solo necesario el n. reynolds

