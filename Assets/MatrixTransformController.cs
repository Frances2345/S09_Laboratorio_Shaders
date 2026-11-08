using UnityEngine;

public class MatrixTransformController : MonoBehaviour
{
    public Vector3 posicion;
    public Vector3 rotacion;
    public Vector3 escala = Vector3.one;

    private Material mat;

    void Start()
    {
        mat = GetComponent<Renderer>().material;
    }

    void Update()
    {
        // Construye la matriz TRS (Translation, Rotation, Scale)
        Matrix4x4 matriz = Matrix4x4.TRS(posicion, Quaternion.Euler(rotacion), escala);

        // Envía la matriz al shader cuadro a cuadro mediante el uniform _Transf
        mat.SetMatrix("_Transf", matriz);
    }
}