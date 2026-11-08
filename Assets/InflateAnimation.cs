using UnityEngine;

public class InflateAnimation : MonoBehaviour
{
    private Material mat;

    void Start()
    {
        mat = GetComponent<Renderer>().material;
    }

    void Update()
    {
        // Modifica dinámicamente el uniform _Inflar de ida y vuelta usando PingPong
        float valor = Mathf.PingPong(Time.time * 0.2f, 0.4f);
        mat.SetFloat("_Inflar", valor);
    }
}