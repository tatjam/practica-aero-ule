import manu
import std/math

# Aproximacion por minimos cuadrados de una serie de datos, devolviendo los 
# coeficientes de un polinomio en la forma:
# a + b*x + c*x*x + ...
# Como se detalla en iniciación a los métodos numéricos de José Antonio Ezquerro
proc minCuadrados(x: openArray[float], y: openArray[float], orden: int): seq[float] =
    assert x.len == y.len 
    assert orden >= 1

    var M = matrix[float](x.len, orden + 1)
    var yM = matrix[float](x.len, 1)
    var xM = matrix[float](x.len, 1)
    for i in 0..orden:
        for v in 0..(x.len - 1):
            M[v, i] = pow(x[v], float(i))
            xM[v, 0] = x[v]
            yM[v, 0] = y[v]


    let Mt = transpose(M)

    let A = Mt * M
    let b = Mt * yM
    # Ahora, A*v = b, v contendra las soluciones
    # para el polinomio a + b*x + c*x*x + ...
    let v = solve(A, b)
    var seqSalida: seq[float]
    for i in 0..orden:
        seqSalida.add(v[i, 0])

    return seqSalida
